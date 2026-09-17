"""Évalue un modèle sur des photos hors sujet (tâche P1.2).

Critère du plan : sur 50 photos hors sujet (sol, mains, maïs, herbes…), aucune
n'est affichée comme « probable ». Le script reproduit exactement le calcul de
l'app :
  - prétraitement de lib/core/ai/tflite_service.dart (224 × 224, plus proche
    voisin, pixels RGB divisés par 255, [0,1]) ;
  - seuils lus dans lib/core/ai/diagnosis_certainty.dart.

Par défaut évalue le modèle embarqué (assets/model/), mais `--model`/`--labels`
permettent de pointer vers n'importe quel modèle candidat, par ex. :

    ml/.venv/Scripts/python ml/scripts/eval_off_topic.py \
        --model ml/models/feuille_v2/model.tflite --labels ml/models/feuille_v2/labels.txt

Ce contrat d'entrée ([0,1], pas de pixels bruts) n'est valide que si le modèle
a été exporté en conséquence — voir la note en tête de ml/scripts/train_feuille.py
(Rescaling embarqué dans le graphe, calé sur ce que l'app envoie réellement).

Depuis ADR-014, le modèle embarqué est feuille_v2, entraîné sur Paddy Doctor et
Mendeley hx6f852hw4 : la contre-épreuve sur le riz ci-dessous réutilise donc ses
images d'entraînement et n'est plus valable pour lui (vocabulaire différent en
plus, voir l'avertissement). Seul le groupe « hors_sujet » reste une mesure
honnête ; pour le riz, utiliser ml/scripts/comparer_integration.py, qui évalue
sur la validation jamais vue.

Contre-épreuve sur des feuilles de riz réelles (Paddy Doctor, Mendeley
hx6f852hw4), lues directement dans les archives : un seuil qui écarterait tout
le hors-sujet mais aussi toutes les vraies maladies ne servirait à rien. Les
indicateurs qui en dépendent (« riz_probable_faux », « maladies_bon_nom_pct »)
supposent que les labels du modèle évalué recoupent le vocabulaire anglais de
RICE_SETS (« Bacterial leaf blight », « Brown spot ») : c'est le cas du modèle
embarqué, PAS de ml/models/feuille_v2 (taxonomie interne, ex. « blb », « bls »).
Le script avertit explicitement plutôt que de laisser ces indicateurs mentir
en silence pour un autre vocabulaire.

    ml/.venv/Scripts/python ml/scripts/eval_off_topic.py
"""

from __future__ import annotations

import argparse
import csv
import io
import json
import re
import zipfile
from dataclasses import dataclass
from datetime import date
from pathlib import Path

import numpy as np
from PIL import Image, ImageOps
import tensorflow as tf

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_MODEL = ROOT / "assets" / "model" / "agrimada_model.tflite"
DEFAULT_LABELS = ROOT / "assets" / "model" / "labels.txt"
THRESHOLDS_SOURCE = ROOT / "lib" / "core" / "ai" / "diagnosis_certainty.dart"
OFF_TOPIC_MANIFEST = ROOT / "ml" / "data" / "eval" / "hors_sujet.csv"
REPORTS = ROOT / "ml" / "reports"
INPUT_SIZE = 224
PER_CLASS = 100

# (archive, dossier dans l'archive, groupe évalué, étiquette attendue ou None)
RICE_SETS = [
    ("ml/data/raw/paddy_doctor/paddy-disease-classification.zip", "train_images/bacterial_leaf_blight/", "riz_blb", "Bacterial leaf blight"),
    ("ml/data/raw/paddy_doctor/paddy-disease-classification.zip", "train_images/brown_spot/", "riz_tache_brune", "Brown spot"),
    ("ml/data/raw/paddy_doctor/paddy-disease-classification.zip", "train_images/normal/", "riz_sain", None),
    ("ml/data/raw/mendeley_hx6f852hw4/Original/Original Images.zip", "Original Images/Bacterial Leaf Blight/", "riz_blb", "Bacterial leaf blight"),
    ("ml/data/raw/mendeley_hx6f852hw4/Original/Original Images.zip", "Original Images/Brown Spot/", "riz_tache_brune", "Brown spot"),
    ("ml/data/raw/mendeley_hx6f852hw4/Original/Original Images.zip", "Original Images/Healthy Rice Leaf/", "riz_sain", None),
]


@dataclass(frozen=True)
class Thresholds:
    probable_min_score: float
    probable_min_margin: float
    possible_min_score: float
    min_vegetation: float = 0.0

    def certainty(self, ranked: list[tuple[str, float]], vegetation: float = 1.0) -> str:
        if vegetation < self.min_vegetation:
            return "incertain"
        best = ranked[0][1]
        second = ranked[1][1] if len(ranked) > 1 else 0.0
        if best >= self.probable_min_score and best - second >= self.probable_min_margin:
            return "probable"
        if best >= self.possible_min_score:
            return "possible"
        return "incertain"


def read_app_thresholds() -> Thresholds:
    source = THRESHOLDS_SOURCE.read_text(encoding="utf-8")

    def value(name: str) -> float:
        match = re.search(rf"{name}\s*=\s*([0-9.]+)", source)
        if not match:
            raise SystemExit(f"Seuil {name} introuvable dans {THRESHOLDS_SOURCE.name}")
        return float(match.group(1))

    return Thresholds(
        value("probableMinScore"),
        value("probableMinMargin"),
        value("possibleMinScore"),
        value("minVegetationRatio"),
    )


def _model_input_image(data: bytes) -> Image.Image:
    image = ImageOps.exif_transpose(Image.open(io.BytesIO(data))).convert("RGB")
    return image.resize((INPUT_SIZE, INPUT_SIZE), Image.NEAREST)


def preprocess(data: bytes) -> np.ndarray:
    return (np.asarray(_model_input_image(data), dtype=np.float32) / 255.0)[np.newaxis, ...]


def vegetation_ratio(data: bytes) -> float:
    """Part des pixels de teinte végétale (jaune-vert à vert, assez saturés)."""
    hsv = np.asarray(_model_input_image(data).convert("HSV"), dtype=np.float32)
    hue_degrees = hsv[..., 0] * 360.0 / 255.0
    saturation = hsv[..., 1] / 255.0
    value = hsv[..., 2] / 255.0
    plant = (hue_degrees >= 25) & (hue_degrees <= 160) & (saturation >= 0.18) & (value >= 0.15)
    return float(plant.mean())


class Model:
    def __init__(self, model_path: Path, labels_path: Path) -> None:
        self.labels = [l.strip() for l in labels_path.read_text(encoding="utf-8").splitlines() if l.strip()]
        self.interpreter = tf.lite.Interpreter(model_path=str(model_path))
        self.interpreter.allocate_tensors()
        self.input = self.interpreter.get_input_details()[0]
        self.output = self.interpreter.get_output_details()[0]

    def rank(self, data: bytes) -> list[tuple[str, float]]:
        self.interpreter.set_tensor(self.input["index"], preprocess(data))
        self.interpreter.invoke()
        scores = self.interpreter.get_tensor(self.output["index"])[0].astype(float)
        return sorted(zip(self.labels, scores), key=lambda item: item[1], reverse=True)[:3]


def off_topic_samples() -> list[dict]:
    with OFF_TOPIC_MANIFEST.open(encoding="utf-8") as handle:
        rows = list(csv.DictReader(handle))
    return [
        {"groupe": "hors_sujet", "categorie": row["categorie"], "fichier": row["fichier"],
         "attendu": None, "data": (ROOT / row["fichier"]).read_bytes()}
        for row in rows
    ]


def rice_samples() -> list[dict]:
    samples = []
    for archive, folder, group, expected in RICE_SETS:
        path = ROOT / archive
        if not path.exists():
            print(f"archive absente, ignorée : {archive}")
            continue
        with zipfile.ZipFile(path) as zipped:
            names = sorted(
                n for n in zipped.namelist()
                if n.startswith(folder) and n.lower().endswith((".jpg", ".jpeg", ".png"))
            )
            step = max(1, len(names) // PER_CLASS)
            for name in names[::step][:PER_CLASS]:
                samples.append({"groupe": group, "categorie": Path(archive).parts[3],
                                "fichier": f"{archive}!{name}", "attendu": expected,
                                "data": zipped.read(name)})
    return samples


def summarize(results: list[dict], thresholds: Thresholds) -> dict:
    summary: dict[str, dict] = {}
    for result in results:
        certainty = thresholds.certainty(result["classement"], result["vegetation"])
        group = summary.setdefault(result["groupe"], {"total": 0, "probable": 0, "possible": 0,
                                                       "incertain": 0, "probable_juste": 0})
        group["total"] += 1
        group[certainty] += 1
        if certainty == "probable" and result["classement"][0][0] == result["attendu"]:
            group["probable_juste"] += 1
    return summary


def sweep(results: list[dict], base: Thresholds) -> list[dict]:
    rows = []
    for score in [0.70, 0.80, 0.90, 0.95, 0.97, 0.98, 0.99, 0.995, 0.997, 0.998, 0.999, 0.9995]:
        for margin in [0.20, 0.50, 0.80, 0.90, 0.95]:
            if margin > score:
                continue
            candidate = Thresholds(score, margin, base.possible_min_score, base.min_vegetation)
            summary = summarize(results, candidate)
            off = summary.get("hors_sujet", {"probable": 0, "total": 0})
            positives = [summary[g] for g in ("riz_blb", "riz_tache_brune") if g in summary]
            positive_total = sum(g["total"] for g in positives) or 1
            wrong = sum(
                1 for r in results
                if r["groupe"] != "hors_sujet"
                and candidate.certainty(r["classement"], r["vegetation"]) == "probable"
                and r["classement"][0][0] != r["attendu"]
            )
            rows.append({
                "score_min": score, "ecart_min": margin,
                "hors_sujet_probable": off["probable"],
                "riz_probable_faux": wrong,
                "riz_sain_probable": summary.get("riz_sain", {}).get("probable", 0),
                "maladies_probable_juste_pct": round(100 * sum(g["probable_juste"] for g in positives) / positive_total, 1),
            })
    return rows


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--model", type=Path, default=DEFAULT_MODEL, help="modèle .tflite à évaluer (défaut : modèle embarqué dans l'app)")
    parser.add_argument("--labels", type=Path, default=DEFAULT_LABELS, help="labels.txt associé")
    args = parser.parse_args()

    thresholds = read_app_thresholds()
    model = Model(args.model, args.labels)

    vocabulaire_rice_sets = {expected for *_, expected in RICE_SETS if expected}
    labels_couvrent_rice_sets = bool(vocabulaire_rice_sets & set(model.labels))
    if not labels_couvrent_rice_sets:
        print(
            f"[AVERTISSEMENT] les labels de {args.labels.name} ne recoupent pas le vocabulaire anglais de "
            f"RICE_SETS ({sorted(vocabulaire_rice_sets)}) : « riz_probable_faux » et « maladies_bon_nom_pct » "
            "ci-dessous ne sont PAS fiables pour ce modèle (aucune prédiction ne pourra jamais matcher "
            "« attendu »). Seuls les indicateurs sur le groupe « hors_sujet » restent valides.\n"
        )

    samples = off_topic_samples() + rice_samples()
    results = []
    for sample in samples:
        results.append(
            {k: v for k, v in sample.items() if k != "data"}
            | {"classement": model.rank(sample["data"]), "vegetation": vegetation_ratio(sample["data"])}
        )

    summary = summarize(results, thresholds)
    table = sweep(results, thresholds)
    off_topic_probable = [
        {"fichier": r["fichier"], "categorie": r["categorie"],
         "classement": [(label, round(score, 4)) for label, score in r["classement"]]}
        for r in results
        if r["groupe"] == "hors_sujet" and thresholds.certainty(r["classement"], r["vegetation"]) == "probable"
    ]

    REPORTS.mkdir(parents=True, exist_ok=True)
    stamp = date.today().isoformat()
    payload = {
        "date": stamp,
        "modele": args.model.relative_to(ROOT).as_posix() if args.model.is_relative_to(ROOT) else str(args.model),
        "labels_hors_vocabulaire_rice_sets": not labels_couvrent_rice_sets,
        "seuils_app": thresholds.__dict__,
        "entree_modele": {"dtype": str(model.input["dtype"]), "forme": model.input["shape"].tolist()},
        "resume": summary,
        "hors_sujet_affiches_probable": off_topic_probable,
        "balayage_seuils": table,
    }
    suffixe = "" if args.model == DEFAULT_MODEL else f"_{args.model.parent.name}"
    out = REPORTS / f"eval_hors_sujet_{stamp}{suffixe}.json"
    out.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

    print(json.dumps({"seuils_app": thresholds.__dict__, "resume": summary}, ensure_ascii=False, indent=2))
    print(f"hors sujet affichés « probable » : {len(off_topic_probable)}")
    for row in off_topic_probable[:15]:
        print("  ", row["categorie"], row["classement"])
    print("balayage (score_min, écart_min) -> hors_sujet_probable | riz_probable_faux | riz_sain_probable | maladies probables justes %")
    for row in table:
        if row["ecart_min"] != 0.20:
            continue
        print(f"  {row['score_min']:<7} {row['ecart_min']:<5} -> {row['hors_sujet_probable']:>3} | {row['riz_probable_faux']:>3} | {row['riz_sain_probable']:>3} | {row['maladies_probable_juste_pct']}")
    # Protection complémentaire : contrôle de végétation avant le modèle, puis
    # seuil minimal pour afficher une maladie, même au niveau « possible ».
    def shown(result: dict, gate: float, display_min: float) -> bool:
        return result["vegetation"] >= gate and result["classement"][0][1] >= display_min

    groups = ["hors_sujet", "riz_sain", "riz_blb", "riz_tache_brune"]
    print("\nvégétation (part de pixels végétaux) par catégorie : min / médiane")
    by_category: dict[str, list[float]] = {}
    for r in results:
        by_category.setdefault(r["categorie"] if r["groupe"] == "hors_sujet" else r["groupe"], []).append(r["vegetation"])
    for name, values in sorted(by_category.items()):
        print(f"  {name:<16} {min(values):.2f} / {float(np.median(values)):.2f}")

    print("\ncontrôle végétation + seuil d'affichage -> hors sujet affichés /50 | riz sain affichés /200 | maladies affichées avec le bon nom %")
    gate_rows = []
    for gate in [0.0, 0.05, 0.10, 0.15, 0.20, 0.30]:
        for display_min in [0.50, 0.60, 0.70, 0.80, 0.90]:
            counts = {g: sum(1 for r in results if r["groupe"] == g and shown(r, gate, display_min)) for g in groups}
            disease = [r for r in results if r["groupe"] in ("riz_blb", "riz_tache_brune")]
            right = sum(1 for r in disease if shown(r, gate, display_min) and r["classement"][0][0] == r["attendu"])
            row = {"vegetation_min": gate, "affichage_min": display_min, **counts,
                   "maladies_bon_nom_pct": round(100 * right / max(1, len(disease)), 1)}
            gate_rows.append(row)
            print(f"  {gate:<5} {display_min:<5} -> {counts['hors_sujet']:>3} | {counts['riz_sain']:>3} | {row['maladies_bon_nom_pct']}")
    payload["controle_vegetation"] = gate_rows
    out.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"rapport : {out.relative_to(ROOT).as_posix()}")


if __name__ == "__main__":
    main()
