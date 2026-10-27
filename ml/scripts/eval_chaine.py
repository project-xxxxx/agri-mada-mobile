#!/usr/bin/env python3
"""Évalue la chaîne à trois étages (P4.2) contre le modèle plat feuille_v2.

Étage A : ml/models/porte_v1 (pas_riz / riz_exploitable).
Étage B : ml/models/feuille_multilabel_v1 (une sigmoïde par problème, seuils
par classe ; « saine » quand rien ne dépasse son seuil).
Étage C : ici une décision déterministe (porte, puis organe) pour mesurer la
chaîne ; la fusion avec le questionnaire et le contexte de parcelle reste
celle de lib/core/ai/diagnosis_fusion.dart (P2.4), à brancher en P4.5.

Mesures sur la même validation que feuille_v2 (même découpage stratifié à 13
classes, même graine), donc comparables à son metrics.json, puis sur les 50
photos hors sujet de P1.2, jamais vues à l'entraînement.

Usage :
    ml/.venv/Scripts/python ml/scripts/eval_chaine.py
"""

from __future__ import annotations

import argparse
import json
import sys
from datetime import date
from pathlib import Path

import numpy as np
import tensorflow as tf
from tensorflow import keras

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "ml" / "scripts"))
from train_feuille import (  # noqa: E402
    CACHE_FILE,
    HORS_SUJET_DIR,
    IMG_SIZE,
    CacheFeatures,
    charger_image,
    lister_images,
    matrice_confusion,
    metriques_par_classe,
    softmax_temperature,
    split_stratifie,
)
from train_feuille_multilabel import decision, sigmoid  # noqa: E402

MODELS = ROOT / "ml" / "models"
RAPPORT = ROOT / "ml" / "reports" / f"eval_chaine_{date.today().isoformat()}.json"


def charger_etage(dossier: Path) -> tuple[keras.Model, dict]:
    for fichier in ("tete.keras", "metrics.json"):
        if not (dossier / fichier).exists():
            sys.exit(f"{dossier / fichier} introuvable : relancer l'entraînement de {dossier.name}.")
    return keras.models.load_model(dossier / "tete.keras"), json.loads((dossier / "metrics.json").read_text(encoding="utf-8"))


def decider_chaine(
    X: np.ndarray,
    porte: keras.Model,
    t_porte: float,
    seuil_porte: float,
    feuille: keras.Model,
    t_feuille: float,
    sorties: list[str],
    seuils: np.ndarray,
) -> list[str]:
    p_pas_riz = softmax_temperature(porte.predict(X, verbose=0), t_porte)[:, 0]
    probs = sigmoid(feuille.predict(X, verbose=0) / t_feuille)
    choix = decision(probs, seuils)
    return [
        "pas_riz" if p >= seuil_porte else ("feuille_saine" if c == -1 else sorties[c])
        for p, c in zip(p_pas_riz, choix)
    ]


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--data-root", type=Path, default=Path("D:/agrimada-ml"))
    parser.add_argument("--val-ratio", type=float, default=0.2)
    parser.add_argument("--seed", type=int, default=123)
    parser.add_argument("--seuil-porte", type=float, default=0.5, help="probabilité pas_riz au-dessus de laquelle la porte rejette")
    args = parser.parse_args()

    porte, m_porte = charger_etage(MODELS / "porte_v1")
    feuille, m_feuille = charger_etage(MODELS / "feuille_multilabel_v1")
    t_porte = m_porte["calibration"]["temperature"]
    t_feuille = m_feuille["calibration"]["temperature"]
    sorties = m_feuille["sorties"]
    seuils_json = json.loads((MODELS / "feuille_multilabel_v1" / "thresholds.json").read_text(encoding="utf-8"))
    seuils = np.array([seuils_json[s] for s in sorties], dtype=np.float32)

    class_names, paths, labels = lister_images(args.data_root / "prepared" / "feuille")
    _, val_idx = split_stratifie(labels, args.val_ratio, args.seed)
    cache = CacheFeatures(CACHE_FILE)
    manquants = cache.manquants([paths[i] for i in val_idx])
    if manquants:
        sys.exit(f"{len(manquants)} image(s) de validation absentes du cache : relancer train_feuille.py.")
    X_val = cache.recuperer([paths[i] for i in val_idx])
    y_val = labels[val_idx]

    predits = decider_chaine(X_val, porte, t_porte, args.seuil_porte, feuille, t_feuille, sorties, seuils)
    y_pred = np.array([class_names.index(p) for p in predits])
    matrice = matrice_confusion(y_val, y_pred, len(class_names))
    par_classe = metriques_par_classe(matrice, class_names)
    exactitude = float((y_val == y_pred).mean())
    macro_f1 = float(np.mean([m["f1"] for m in par_classe]))

    plat = MODELS / "feuille_v2" / "metrics.json"
    reference = json.loads(plat.read_text(encoding="utf-8")) if plat.exists() else None
    meme_validation = reference is not None and sum(m["support"] for m in reference["par_classe"]) == len(val_idx)

    print(f"Validation : {len(val_idx)} images, 13 classes")
    print(f"Chaîne porte -> feuille : exactitude {exactitude:.4f}, macro-F1 {macro_f1:.4f}")
    if reference:
        print(
            f"Modèle plat feuille_v2  : exactitude {reference['exactitude_validation']:.4f}, "
            f"macro-F1 {reference.get('macro_f1', float('nan')):.4f}"
            + ("" if meme_validation else "  (ATTENTION : validation différente, comparaison invalide)")
        )

    hors_sujet = None
    chemins = sorted(p for p in HORS_SUJET_DIR.rglob("*") if p.suffix.lower() in (".jpg", ".jpeg", ".png")) if HORS_SUJET_DIR.is_dir() else []
    if chemins:
        base = tf.keras.applications.MobileNetV2(
            input_shape=(IMG_SIZE, IMG_SIZE, 3), include_top=False, weights="imagenet", pooling="avg"
        )
        lot = np.stack([charger_image(str(p)) for p in chemins])
        feats = base(tf.keras.applications.mobilenet_v2.preprocess_input(lot), training=False).numpy()
        decisions_hs = decider_chaine(feats, porte, t_porte, args.seuil_porte, feuille, t_feuille, sorties, seuils)
        hors_sujet = {
            "n_photos": len(chemins),
            "rejetees_pas_riz": decisions_hs.count("pas_riz"),
            "prises_pour_feuille_saine": decisions_hs.count("feuille_saine"),
            "maladie_nommee_a_tort": sum(d not in ("pas_riz", "feuille_saine") for d in decisions_hs),
            "detail": {str(p.relative_to(HORS_SUJET_DIR).as_posix()): d for p, d in zip(chemins, decisions_hs)},
        }
        print(
            f"Hors sujet (50 jamais vues) : {hors_sujet['rejetees_pas_riz']} rejetées, "
            f"{hors_sujet['prises_pour_feuille_saine']} prises pour une feuille saine, "
            f"{hors_sujet['maladie_nommee_a_tort']} avec une maladie nommée à tort"
        )

    RAPPORT.parent.mkdir(parents=True, exist_ok=True)
    RAPPORT.write_text(
        json.dumps(
            {
                "date": date.today().isoformat(),
                "seuil_porte": args.seuil_porte,
                "validation": {"n": len(val_idx), "exactitude": exactitude, "macro_f1": macro_f1, "par_classe": par_classe},
                "reference_plate_feuille_v2": {
                    "exactitude": reference["exactitude_validation"] if reference else None,
                    "macro_f1": reference.get("macro_f1") if reference else None,
                    "meme_validation": meme_validation,
                },
                "hors_sujet": hors_sujet,
            },
            indent=2,
            ensure_ascii=False,
        ),
        encoding="utf-8",
    )
    print(f"\nRapport écrit dans {RAPPORT.relative_to(ROOT).as_posix()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
