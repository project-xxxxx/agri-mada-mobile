#!/usr/bin/env python3
"""Entraîne le modèle d'organe « feuille » en multi-étiquette (étage B de P4.2).

Différence avec ml/scripts/train_feuille.py (softmax à 13 classes) :
- une sortie sigmoïde par problème (11 : maladies, ravageurs, carences) ;
  une feuille peut en porter plusieurs à la fois, comme le prévoit le plan ;
- « feuille saine » n'est plus une classe : une feuille est saine quand
  aucune sortie ne dépasse son seuil ;
- les photos pas_riz sont exclues : c'est le rôle de la porte (étage A,
  ml/scripts/train_porte.py), qui passe avant ce modèle ;
- un seuil par classe, choisi sur la validation (meilleur F1), exporté dans
  thresholds.json à côté du modèle.

Limite à connaître (voir ADR-013) : tous les jeux publics sont étiquetés
« une photo = une classe ». Le modèle apprend donc des détecteurs
indépendants, mais n'a jamais vu de feuille portant deux problèmes à la fois :
sa capacité à en signaler deux n'est pas mesurée.

Aucune nouvelle passe dans MobileNetV2 : réutilise le cache de features de
ml/scripts/train_feuille.py.

Usage :
    ml/.venv/Scripts/python ml/scripts/train_feuille_multilabel.py
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
from tensorflow.keras import layers

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "ml" / "scripts"))
from train_feuille import (  # noqa: E402
    CACHE_FILE,
    FEATURE_DIM,
    HORS_SUJET_DIR,
    IMG_SIZE,
    CacheFeatures,
    charger_image,
    extraire_features_manquantes,
    generer_lots_mixup,
    lister_images,
    split_stratifie,
)

MODELS_DIR = ROOT / "ml" / "models" / "feuille_multilabel_v1"
CLASSE_SAINE = "feuille_saine"
CLASSE_PORTE = "pas_riz"


def sigmoid(z: np.ndarray) -> np.ndarray:
    return 1.0 / (1.0 + np.exp(-z))


def poids_par_groupe(groupes: np.ndarray) -> np.ndarray:
    """Même logique que poids_echantillon de train_feuille.py, sur le groupe
    d'origine de chaque photo (une classe de problème, ou « saine »)."""
    n_groupes = int(groupes.max()) + 1
    effectifs = np.bincount(groupes, minlength=n_groupes)
    poids = len(groupes) / (n_groupes * np.maximum(effectifs, 1))
    return poids[groupes].astype(np.float32)


def ajuster_temperature_sigmoide(logits: np.ndarray, y: np.ndarray, pas: int = 200) -> float:
    meilleure_t, meilleure_perte = 1.0, np.inf
    for t in np.linspace(0.05, 5.0, pas):
        p = np.clip(sigmoid(logits / t), 1e-7, 1 - 1e-7)
        perte = -(y * np.log(p) + (1 - y) * np.log(1 - p)).mean()
        if perte < meilleure_perte:
            meilleure_perte, meilleure_t = perte, float(t)
    return meilleure_t


def choisir_seuil(probs: np.ndarray, y: np.ndarray) -> tuple[float, dict]:
    """Seuil maximisant le F1 d'une classe sur la validation."""
    meilleur = (0.5, {"precision": 0.0, "rappel": 0.0, "f1": 0.0})
    for seuil in np.linspace(0.05, 0.95, 91):
        pred = probs >= seuil
        tp = int((pred & (y == 1)).sum())
        fp = int((pred & (y == 0)).sum())
        fn = int((~pred & (y == 1)).sum())
        precision = tp / (tp + fp) if tp + fp else 0.0
        rappel = tp / (tp + fn) if tp + fn else 0.0
        f1 = 2 * precision * rappel / (precision + rappel) if precision + rappel else 0.0
        if f1 > meilleur[1]["f1"]:
            meilleur = (float(seuil), {"precision": precision, "rappel": rappel, "f1": f1})
    return meilleur


def decision(probs: np.ndarray, seuils: np.ndarray) -> np.ndarray:
    """Décision « une réponse par photo », pour comparer à un softmax : -1 si
    aucune sortie ne dépasse son seuil (feuille saine), sinon la classe dont la
    probabilité dépasse le plus son seuil (en rapport)."""
    marges = probs / seuils
    au_dessus = probs >= seuils
    choix = np.argmax(np.where(au_dessus, marges, -np.inf), axis=1)
    return np.where(au_dessus.any(axis=1), choix, -1)


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

    class_names_feuille, tous_paths, tous_labels = lister_images(args.data_root / "prepared" / "feuille")
    if CLASSE_SAINE not in class_names_feuille:
        sys.exit(f"Classe {CLASSE_SAINE} absente de {args.data_root}/prepared/feuille.")
    classes = [c for c in class_names_feuille if c not in (CLASSE_SAINE, CLASSE_PORTE)]
    n_classes = len(classes)

    # Même découpage que train_feuille.py et train_porte.py (13 classes, même
    # graine) puis retrait des pas_riz : la validation reste commune aux trois
    # modèles, ce qui permet d'évaluer la chaîne porte -> feuille.
    train_idx, val_idx = split_stratifie(tous_labels, args.val_ratio, args.seed)
    idx_porte = class_names_feuille.index(CLASSE_PORTE) if CLASSE_PORTE in class_names_feuille else -1
    train_idx = train_idx[tous_labels[train_idx] != idx_porte]
    val_idx = val_idx[tous_labels[val_idx] != idx_porte]

    def multi_hot(indices: np.ndarray) -> np.ndarray:
        y = np.zeros((len(indices), n_classes), dtype=np.float32)
        for ligne, i in enumerate(indices):
            nom = class_names_feuille[tous_labels[i]]
            if nom != CLASSE_SAINE:
                y[ligne, classes.index(nom)] = 1.0
        return y

    base_model = tf.keras.applications.MobileNetV2(
        input_shape=(IMG_SIZE, IMG_SIZE, 3), include_top=False, weights="imagenet", pooling="avg"
    )
    base_model.trainable = False
    cache = CacheFeatures(CACHE_FILE)
    extraire_features_manquantes(base_model, cache, [tous_paths[i] for i in np.concatenate([train_idx, val_idx])], args.batch_size)

    X_train = cache.recuperer([tous_paths[i] for i in train_idx])
    X_val = cache.recuperer([tous_paths[i] for i in val_idx])
    Y_train, Y_val = multi_hot(train_idx), multi_hot(val_idx)
    groupes_train = tous_labels[train_idx]
    print(f"{n_classes} sorties : {classes}")
    print(f"train: {X_train.shape} ({int((Y_train.sum(axis=1) == 0).sum())} saines), val: {X_val.shape}")

    tete = keras.Sequential(
        [
            layers.Input(shape=(FEATURE_DIM,)),
            layers.Dense(256, activation="relu"),
            layers.Dropout(0.4),
            layers.Dense(n_classes),
        ]
    )
    tete.compile(
        optimizer="adam",
        loss=keras.losses.BinaryCrossentropy(from_logits=True, label_smoothing=args.label_smoothing),
        metrics=[keras.metrics.AUC(multi_label=True, from_logits=True, name="auc")],
    )
    callbacks = [
        keras.callbacks.EarlyStopping(monitor="val_loss", patience=6, restore_best_weights=True),
        keras.callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.3, patience=3, min_lr=1e-6),
    ]
    poids = poids_par_groupe(groupes_train)
    if args.mixup_alpha > 0:
        historique = tete.fit(
            generer_lots_mixup(X_train, Y_train, poids, args.head_batch_size, args.mixup_alpha, args.seed),
            steps_per_epoch=max(1, len(X_train) // args.head_batch_size),
            epochs=args.epochs,
            validation_data=(X_val, Y_val),
            callbacks=callbacks,
            verbose=2,
        )
    else:
        historique = tete.fit(
            X_train, Y_train, sample_weight=poids, validation_data=(X_val, Y_val),
            epochs=args.epochs, batch_size=args.head_batch_size, callbacks=callbacks, verbose=2,
        )

    logits_val = tete.predict(X_val, verbose=0)
    temperature = ajuster_temperature_sigmoide(logits_val, Y_val)
    probs_val = sigmoid(logits_val / temperature)

    seuils = np.zeros(n_classes, dtype=np.float32)
    par_classe = []
    for k, nom in enumerate(classes):
        seuil, m = choisir_seuil(probs_val[:, k], Y_val[:, k].astype(int))
        seuils[k] = seuil
        par_classe.append({"classe": nom, "support": int(Y_val[:, k].sum()), "seuil": seuil, **m})
    macro_f1 = float(np.mean([m["f1"] for m in par_classe]))

    # Décision à une réponse, comparable à la partie « feuille » de feuille_v2.
    y_vrai = np.array([classes.index(n) if (n := class_names_feuille[tous_labels[i]]) != CLASSE_SAINE else -1 for i in val_idx])
    y_decide = decision(probs_val, seuils)
    exactitude_decision = float((y_vrai == y_decide).mean())
    saines = y_vrai == -1
    saines_reconnues = float((y_decide[saines] == -1).mean()) if saines.any() else None
    malades_prises_pour_saines = float((y_decide[~saines] == -1).mean()) if (~saines).any() else None
    print(f"\nmacro-F1 (seuils par classe) : {macro_f1:.4f}")
    print(f"Exactitude en décision unique (12 réponses dont « saine ») : {exactitude_decision:.4f}")
    print(f"Feuilles saines reconnues saines : {saines_reconnues:.1%}")
    print(f"Feuilles malades prises pour saines : {malades_prises_pour_saines:.1%}")

    # Photos hors sujet si la porte était court-circuitée : combien déclenchent
    # au moins une maladie. Justifie l'étage A, ne le remplace pas.
    hors_sujet = None
    if HORS_SUJET_DIR.is_dir():
        chemins = sorted(p for p in HORS_SUJET_DIR.rglob("*") if p.suffix.lower() in (".jpg", ".jpeg", ".png"))
        if chemins:
            lot = np.stack([charger_image(str(p)) for p in chemins])
            feats = base_model(tf.keras.applications.mobilenet_v2.preprocess_input(lot), training=False).numpy()
            probs_hs = sigmoid(tete.predict(feats, verbose=0) / temperature)
            declenchees = int((probs_hs >= seuils).any(axis=1).sum())
            hors_sujet = {"n_photos": len(chemins), "au_moins_une_maladie_sans_porte": declenchees}
            print(f"Hors sujet sans porte : {declenchees}/{len(chemins)} déclenchent au moins une maladie")

    entrees = layers.Input(shape=(IMG_SIZE, IMG_SIZE, 3))
    x = layers.Rescaling(scale=2.0, offset=-1.0)(entrees)  # [0,1] -> [-1,1], contrat de tflite_service.dart
    x = base_model(x, training=False)
    x = layers.Rescaling(scale=1.0 / temperature, offset=0.0)(tete(x))
    modele_inference = keras.Model(entrees, layers.Activation("sigmoid")(x))

    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    tete.save(MODELS_DIR / "tete.keras")
    modele_inference.export(str(MODELS_DIR / "saved_model"))
    converter = tf.lite.TFLiteConverter.from_saved_model(str(MODELS_DIR / "saved_model"))
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    (MODELS_DIR / "model.tflite").write_bytes(converter.convert())
    (MODELS_DIR / "labels.txt").write_text("\n".join(classes) + "\n", encoding="utf-8")
    (MODELS_DIR / "thresholds.json").write_text(
        json.dumps({nom: float(s) for nom, s in zip(classes, seuils)}, indent=2, ensure_ascii=False), encoding="utf-8"
    )

    metriques = {
        "date": date.today().isoformat(),
        "framework": f"tensorflow {tf.__version__}",
        "etage": "B (organe feuille, multi-étiquette)",
        "sorties": classes,
        "saine": "aucune sortie au-dessus de son seuil",
        "macro_f1": macro_f1,
        "par_classe": par_classe,
        "decision_unique": {
            "exactitude": exactitude_decision,
            "saines_reconnues_saines": saines_reconnues,
            "malades_prises_pour_saines": malades_prises_pour_saines,
        },
        "hors_sujet_sans_porte": hors_sujet,
        "epochs_effectues": len(historique.history["loss"]),
        "regularisation": {"label_smoothing": args.label_smoothing, "mixup_alpha": args.mixup_alpha, "seed": args.seed},
        "calibration": {"temperature": temperature},
        "limite": "données d'entraînement à une seule étiquette par photo : la détection de problèmes simultanés n'est pas mesurée",
    }
    (MODELS_DIR / "metrics.json").write_text(json.dumps(metriques, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"\nModèle feuille multi-étiquette écrit dans {MODELS_DIR}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
