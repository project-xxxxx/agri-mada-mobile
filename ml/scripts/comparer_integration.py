#!/usr/bin/env python3
"""Compare ce que l'agriculteur verrait avec le modèle embarqué et avec feuille_v2 (P4.5).

Reproduit le parcours de scan de l'app pour une photo de feuille :
  1. prétraitement de lib/core/ai/tflite_service.dart (224 × 224, plus proche
     voisin, pixels [0,1]) — fonctions reprises de eval_off_topic.py ;
  2. top 3 du modèle ;
  3. fusion d'une observation seule, sans questionnaire
     (lib/core/ai/diagnosis_fusion.dart : 0,5 × log de la probabilité bornée
     à [0,05 ; 0,95], puis softmax) ;
  4. certitude avec les seuils de lib/core/ai/diagnosis_certainty.dart.

Trois configurations :
  A. modèle embarqué, parcours actuel — le nom de la première classe est
     affiché dès qu'une photo passe par le modèle, même « incertain », et le
     contrôle de végétation d'ADR-006 n'est plus appliqué dans la fusion ;
  B. modèle embarqué, garde-fous rétablis — rien n'est nommé si la certitude
     est « incertain » ou si la photo a moins de 10 % de pixels végétaux ;
  C. feuille_v2, garde-fous rétablis — et rien n'est nommé si la première
     classe est pas_riz.

Données : la validation de train_feuille.py (même découpage, jamais vue par
feuille_v2 ; indépendante aussi pour le modèle embarqué, entraîné sur un autre
jeu) et les 50 photos hors sujet de P1.2.

Usage :
    ml/.venv/Scripts/python ml/scripts/comparer_integration.py
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from collections import Counter
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "ml" / "scripts"))
from eval_off_topic import OFF_TOPIC_MANIFEST, Model, read_app_thresholds, vegetation_ratio  # noqa: E402
from train_feuille import lister_images, split_stratifie  # noqa: E402

FEUILLE_V2 = ROOT / "ml" / "models" / "feuille_v2"
# Ancien modèle embarqué (3 classes), archivé avant son remplacement par
# feuille_v2 dans assets/model/ (ADR-014).
EMBARQUE_V1 = ROOT / "ml" / "models" / "embarque_v1"
RAPPORT = ROOT / "ml" / "reports" / f"comparaison_integration_{date.today().isoformat()}.json"

# Étiquettes du modèle embarqué -> id de taxonomie (None : pas de classe équivalente).
EMBARQUE_VERS_TAXONOMIE = {"Bacterial leaf blight": "blb", "Brown spot": "helminthosporiose", "Leaf smut": None}
SAINES = {"feuille_saine", "healthy", "normal"}


def fusion_une_observation(top3: list[tuple[str, float]]) -> list[tuple[str, float]]:
    logs = {label: 0.5 * math.log(min(max(p, 0.05), 0.95)) for label, p in top3}
    maximum = max(logs.values())
    exps = {label: math.exp(v - maximum) for label, v in logs.items()}
    total = sum(exps.values())
    return sorted(((label, e / total) for label, e in exps.items()), key=lambda x: x[1], reverse=True)


def certitude(classement: list[tuple[str, float]], seuils) -> str:
    best = classement[0][1]
    second = classement[1][1] if len(classement) > 1 else 0.0
    if best >= seuils.probable_min_score and best - second >= seuils.probable_min_margin:
        return "probable"
    return "possible" if best >= seuils.possible_min_score else "incertain"


def vue_agriculteur(top3, vegetation: float, seuils, garde_fous: bool, traduire) -> str:
    """« rien » (aucune maladie nommée), « sain », ou l'id de la maladie nommée
    (« autre » si le modèle nomme une classe sans équivalent dans la taxonomie)."""
    fusion = fusion_une_observation(top3)
    cert = certitude(fusion, seuils)
    premier = fusion[0][0]
    if garde_fous and (cert == "incertain" or vegetation < seuils.min_vegetation or premier == "pas_riz"):
        return "rien"
    if premier in SAINES:
        return "sain"
    return traduire(premier) or "autre"


def resumer(vues: list[str], attendus: list[str]) -> dict:
    par_groupe: dict[str, Counter] = {}
    for vue, attendu in zip(vues, attendus):
        if attendu == "hors_sujet" or attendu == "pas_riz":
            issue = "maladie_nommee" if vue not in ("rien", "sain") else vue
        elif attendu == "feuille_saine":
            issue = "fausse_alerte" if vue not in ("rien", "sain") else vue
        else:
            issue = "bon_nom" if vue == attendu else ("rien_ou_sain" if vue in ("rien", "sain") else "mauvais_nom")
        par_groupe.setdefault(attendu, Counter())[issue] += 1

    malades = [g for g in par_groupe if g not in ("hors_sujet", "pas_riz", "feuille_saine")]
    total_malades = Counter()
    for g in malades:
        total_malades.update(par_groupe[g])
    communes = Counter()
    for g in ("blb", "helminthosporiose"):
        communes.update(par_groupe.get(g, Counter()))
    return {
        "hors_sujet": dict(par_groupe.get("hors_sujet", {})),
        "pas_riz_validation": dict(par_groupe.get("pas_riz", {})),
        "feuilles_saines": dict(par_groupe.get("feuille_saine", {})),
        "toutes_maladies": dict(total_malades),
        "blb_et_helminthosporiose": dict(communes),
        "par_maladie": {g: dict(par_groupe[g]) for g in sorted(malades)},
    }


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--data-root", type=Path, default=Path("D:/agrimada-ml"))
    args = parser.parse_args()

    seuils = read_app_thresholds()
    class_names, paths, labels = lister_images(args.data_root / "prepared" / "feuille")
    _, val_idx = split_stratifie(labels, 0.2, 123)

    import csv

    with OFF_TOPIC_MANIFEST.open(encoding="utf-8") as handle:
        hors_sujet = [ROOT / row["fichier"] for row in csv.DictReader(handle)]
    images = [(Path(paths[i]), class_names[labels[i]]) for i in val_idx] + [(p, "hors_sujet") for p in hors_sujet]
    print(f"{len(images)} photos ({len(val_idx)} de validation, {len(hors_sujet)} hors sujet)")

    embarque = Model(EMBARQUE_V1 / "model.tflite", EMBARQUE_V1 / "labels.txt")
    candidat = Model(FEUILLE_V2 / "model.tflite", FEUILLE_V2 / "labels.txt")

    vues = {"A_embarque_parcours_actuel": [], "B_embarque_garde_fous": [], "C_feuille_v2_garde_fous": []}
    attendus = []
    for n, (chemin, attendu) in enumerate(images, start=1):
        data = chemin.read_bytes()
        veg = vegetation_ratio(data)
        top_e = embarque.rank(data)
        top_c = candidat.rank(data)
        vues["A_embarque_parcours_actuel"].append(vue_agriculteur(top_e, veg, seuils, False, EMBARQUE_VERS_TAXONOMIE.get))
        vues["B_embarque_garde_fous"].append(vue_agriculteur(top_e, veg, seuils, True, EMBARQUE_VERS_TAXONOMIE.get))
        vues["C_feuille_v2_garde_fous"].append(vue_agriculteur(top_c, veg, seuils, True, lambda label: label))
        attendus.append(attendu)
        if n % 500 == 0:
            print(f"  {n}/{len(images)}")

    resultats = {nom: resumer(v, attendus) for nom, v in vues.items()}
    RAPPORT.write_text(
        json.dumps({"date": date.today().isoformat(), "seuils_app": seuils.__dict__, "resultats": resultats}, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )

    def ligne(nom: str, cle: str, issue: str) -> str:
        groupe = resultats[nom][cle]
        total = sum(groupe.values()) or 1
        return f"{groupe.get(issue, 0)}/{total} ({100 * groupe.get(issue, 0) / total:.0f} %)"

    print("\n                                   A embarqué actuel   B embarqué + garde-fous   C feuille_v2 + garde-fous")
    for titre, cle, issue in [
        ("Hors sujet : maladie nommée", "hors_sujet", "maladie_nommee"),
        ("Feuilles saines : fausse alerte", "feuilles_saines", "fausse_alerte"),
        ("BLB + tache brune : bon nom", "blb_et_helminthosporiose", "bon_nom"),
        ("BLB + tache brune : mauvais nom", "blb_et_helminthosporiose", "mauvais_nom"),
        ("Toutes maladies : bon nom", "toutes_maladies", "bon_nom"),
        ("Toutes maladies : mauvais nom", "toutes_maladies", "mauvais_nom"),
    ]:
        print(f"  {titre:<33} " + "   ".join(f"{ligne(nom, cle, issue):<22}" for nom in vues))
    print(f"\nRapport : {RAPPORT.relative_to(ROOT).as_posix()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
