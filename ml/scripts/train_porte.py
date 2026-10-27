#!/usr/bin/env python3
"""Entraîne la porte d'entrée (étage A de P4.2) : riz_exploitable / pas_riz.

Modèle séparé du classifieur de maladies, conformément à l'architecture à
trois étages du plan de correction (P4.2), au lieu de la classe `pas_riz`
mélangée aux 12 classes de maladies dans ml/models/feuille_v2 (où rejeter une
photo hors sujet et choisir entre deux maladies partagent le même softmax).

Périmètre volontairement réduit par rapport au plan (voir ADR-013) : le plan
prévoit une porte à 8 sorties (6 organes + pas_riz + photo_inexploitable).
Aucun jeu public ne contient de photo de collet, racines ou plante entière,
et tige/panicule en ont très peu : un classifieur d'organe entraîné sur ces
données échouerait en silence sur les organes absents. L'app choisit déjà
l'organe par l'agriculteur (P2.1) et juge déjà la photo inexploitable par des
seuils de netteté et d'exposition (P2.2) : la porte se limite donc à « est-ce
du riz exploitable ou pas ».

Aucune nouvelle passe dans MobileNetV2 : réutilise le cache de features de
ml/scripts/train_feuille.py (mêmes images, mêmes chemins), seul le
regroupement des étiquettes change.

Prérequis : ml/scripts/train_feuille.py lancé au moins une fois (cache de
features complet, classe pas_riz incluse).

Usage :
    ml/.venv/Scripts/python ml/scripts/train_porte.py
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from datetime import date
from pathlib import Path

import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "ml" / "scripts"))
from train_feuille import (  # noqa: E402
    CACHE_FILE,
    IMG_SIZE,
    CacheFeatures,
    ajuster_temperature,
    entrainer_tete,
    erreur_calibration_attendue,
    evaluer_hors_sujet,
    extraire_features_manquantes,
    lister_images,
    matrice_confusion,
    metriques_par_classe,
    score_brier,
    softmax_temperature,
    split_stratifie,
)

MODELS_DIR = ROOT / "ml" / "models" / "porte_v1"
CLASSES_PORTE = ["pas_riz", "riz_exploitable"]


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--data-root", type=Path, default=Path("D:/agrimada-ml"))
    parser.add_argument("--epochs", type=int, default=40)
    parser.add_argument("--batch-size", type=int, default=32)
    parser.add_argument("--head-batch-size", type=int, default=64)
    parser.add_argument("--val-ratio", type=float, default=0.2)
    parser.add_argument("--seed", type=int, default=123)
    parser.add_argument("--label-smoothing", type=float, default=0.05)
    parser.add_argument("--mixup-alpha", type=float, default=0.2)
    args = parser.parse_args()

    keras.utils.set_random_seed(args.seed)

    class_names_feuille, paths, labels_feuille = lister_images(args.data_root / "prepared" / "feuille")
    if "pas_riz" not in class_names_feuille:
        sys.exit("Classe pas_riz absente : lancer d'abord fetch_negatives.py puis add_negative_class.py.")
    idx_pas_riz = class_names_feuille.index("pas_riz")
    # 0 = pas_riz, 1 = riz_exploitable (n'importe quelle classe de feuille de riz, saine ou non).
    labels = np.where(labels_feuille == idx_pas_riz, 0, 1).astype(np.int64)
    print(f"{len(paths)} images : {int((labels == 0).sum())} pas_riz, {int((labels == 1).sum())} riz_exploitable")

    base_model = tf.keras.applications.MobileNetV2(
        input_shape=(IMG_SIZE, IMG_SIZE, 3), include_top=False, weights="imagenet", pooling="avg"
    )
    base_model.trainable = False

    cache = CacheFeatures(CACHE_FILE)
    extraire_features_manquantes(base_model, cache, paths, args.batch_size)

    # Découpage stratifié sur les 13 classes d'origine (et non sur les 2 de la
    # porte) : mêmes images de validation que feuille_v2, ce qui permettra plus
    # tard d'évaluer la chaîne porte -> maladie sur un jeu commun.
    train_idx, val_idx = split_stratifie(labels_feuille, args.val_ratio, args.seed)
    X_train, y_train = cache.recuperer([paths[i] for i in train_idx]), labels[train_idx]
    X_val, y_val = cache.recuperer([paths[i] for i in val_idx]), labels[val_idx]

    tete, historique = entrainer_tete(X_train, y_train, X_val, y_val, len(CLASSES_PORTE), args)

    logits_val = tete.predict(X_val, verbose=0)
    y_pred = np.argmax(logits_val, axis=1)
    matrice = matrice_confusion(y_val, y_pred, len(CLASSES_PORTE))
    metriques = metriques_par_classe(matrice, CLASSES_PORTE)
    exactitude = float((y_val == y_pred).mean())

    # Critères P4.6 du plan (mesurés ici sur des photos publiques, pas malgaches) :
    # au moins 95 % des photos hors sujet rejetées, au plus 5 % du riz exploitable rejeté.
    rappel_pas_riz = metriques[0]["rappel"]
    taux_riz_rejete = 1.0 - metriques[1]["rappel"]
    print(f"\nExactitude : {exactitude:.4f}")
    print(f"pas_riz rejetées : {rappel_pas_riz:.1%} (cible plan ≥ 95 %)")
    print(f"riz exploitable rejeté à tort : {taux_riz_rejete:.1%} (cible plan ≤ 5 %)")

    temperature = ajuster_temperature(logits_val, y_val)
    probs_brutes = softmax_temperature(logits_val, 1.0)
    probs_calibrees = softmax_temperature(logits_val, temperature)
    calibration = {
        "temperature": temperature,
        "ece_avant": erreur_calibration_attendue(probs_brutes, y_val),
        "ece_apres": erreur_calibration_attendue(probs_calibrees, y_val),
        "brier_avant": score_brier(probs_brutes, y_val, len(CLASSES_PORTE)),
        "brier_apres": score_brier(probs_calibrees, y_val, len(CLASSES_PORTE)),
    }
    print(f"Température : {temperature:.3f} (ECE {calibration['ece_avant']:.4f} -> {calibration['ece_apres']:.4f})")

    entrees = layers.Input(shape=(IMG_SIZE, IMG_SIZE, 3))
    x = layers.Rescaling(scale=2.0, offset=-1.0)(entrees)  # [0,1] -> [-1,1], contrat de tflite_service.dart
    x = base_model(x, training=False)
    logits = tete(x)
    sorties = layers.Softmax()(layers.Rescaling(scale=1.0 / temperature, offset=0.0)(logits))
    modele_inference = keras.Model(entrees, sorties)

    resultat_hors_sujet = evaluer_hors_sujet(modele_inference, CLASSES_PORTE)
    if resultat_hors_sujet:
        n = resultat_hors_sujet["n_photos"]
        rejetees = resultat_hors_sujet.get("classees_pas_riz", 0)
        print(f"Jeu hors sujet P1.2 (jamais vu) : {rejetees}/{n} rejetées ({rejetees / n:.1%})")

    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    tete.save(MODELS_DIR / "tete.keras")  # pour ml/scripts/eval_chaine.py, sur features en cache
    modele_inference.export(str(MODELS_DIR / "saved_model"))
    converter = tf.lite.TFLiteConverter.from_saved_model(str(MODELS_DIR / "saved_model"))
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    (MODELS_DIR / "model.tflite").write_bytes(converter.convert())
    (MODELS_DIR / "labels.txt").write_text("\n".join(CLASSES_PORTE) + "\n", encoding="utf-8")

    metriques_json = {
        "date": date.today().isoformat(),
        "framework": f"tensorflow {tf.__version__}",
        "etage": "A (porte)",
        "classes": CLASSES_PORTE,
        "effectifs_entrainement": {
            CLASSES_PORTE[i]: int(n) for i, n in enumerate(np.bincount(y_train, minlength=len(CLASSES_PORTE)))
        },
        "exactitude_validation": exactitude,
        "par_classe": metriques,
        "criteres_plan_p4_6": {
            "pas_riz_rejetees": rappel_pas_riz,
            "cible_pas_riz_rejetees": 0.95,
            "riz_exploitable_rejete": taux_riz_rejete,
            "cible_riz_exploitable_rejete_max": 0.05,
            "mesure_sur": "photos publiques (Inde, Bangladesh, Wikimedia), pas un jeu de test malgache",
        },
        "hors_sujet": resultat_hors_sujet,
        "epochs_effectues": len(historique.history["loss"]),
        "regularisation": {"label_smoothing": args.label_smoothing, "mixup_alpha": args.mixup_alpha, "seed": args.seed},
        "calibration": calibration,
    }
    (MODELS_DIR / "metrics.json").write_text(json.dumps(metriques_json, indent=2, ensure_ascii=False), encoding="utf-8")

    with (MODELS_DIR / "confusion_matrix.csv").open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow([""] + CLASSES_PORTE)
        for i, nom in enumerate(CLASSES_PORTE):
            writer.writerow([nom] + list(matrice[i]))

    print(f"\nPorte écrite dans {MODELS_DIR}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
