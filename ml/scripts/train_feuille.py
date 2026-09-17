#!/usr/bin/env python3
"""Entraîne un classifieur « feuille » sur les jeux publics consolidés (P4, hors plan P3).

Remplace le notebook Model/entrainementIA.ipynb (3 classes, 120 images Kaggle,
sans classe saine) par un modèle couvrant les classes feuille disponibles dans
les jeux publics déjà rassemblés (ml/label_map.yaml), plus une classe
« pas_riz » (ml/scripts/fetch_negatives.py) qui sert de porte minimale : sans
elle, un classifieur purement softmax force toujours une réponse confiante,
même sur une photo hors sujet (voir ml/reports/entrainement_feuille_2026-09-17.md).

Approche, pensée pour tourner sur CPU (pas de GPU utilisable sur cette
machine, voir docs/architecture-decisions.md ADR-008) : les features
MobileNetV2 (gelé) sont calculées une seule fois par image et **mises en
cache sur disque, par chemin de fichier** (ml/models/feuille_v2/cache/) — la
première extraction sur ~19 500 images a pris près de 3h en CPU ; ajouter une
classe ne doit recalculer que ses images, jamais tout refaire. Le réseau de
base reste gelé (pas de fine-tuning) : c'est ce qui rend le cache valide, et
donc l'itération rapide sur cette machine.

Depuis le rapport du 2026-09-17, deux défauts identifiés ont été corrigés ici
(pas de nouvel entraînement lancé, seulement le code) :

1. **Sur-confiance du softmax**, cause directe du constat du rapport (37/50
   photos hors sujet à ≥ 0,70 de confiance, pire que le modèle actuel) :
   - `--label-smoothing` (défaut 0,05) : la vraie classe ne vaut plus une
     cible dure à 1,0, ce qui empêche le softmax de pousser ses logits à
     l'infini pour être « sûr ».
   - `--mixup-alpha` (défaut 0,2, Zhang et al. 2018) : mélange convexe de
     paires d'exemples et de leurs étiquettes, fait *dans l'espace des
     features déjà en cache* (vecteurs 1280-d) — coût quasi nul, pas de
     nouvelle passe dans MobileNetV2. Le ré-équilibrage des classes rares se
     fait alors par tirage pondéré (probabilité inversement proportionnelle à
     l'effectif) plutôt que par poids de perte, qui n'a pas de sens sur un
     exemple mélangé entre deux classes.
   - **Calibration par température** (Guo et al. 2017), ajustée après coup sur
     les logits de validation puis *intégrée au graphe exporté* (division des
     logits par T avant le softmax final) : les probabilités affichées à
     l'app deviennent plus honnêtes sans rien changer côté Dart. ECE et score
     de Brier avant/après sont journalisés dans metrics.json pour suivre si
     cela s'améliore d'un entraînement à l'autre — la porte séparée (P4.2)
     reste le vrai garde-fou, la calibration ne fait que rendre les scores
     moins trompeurs en attendant.

2. **Contrat de prétraitement incohérent avec l'app**, qui aurait cassé un
   déploiement silencieusement : `lib/core/ai/tflite_service.dart` normalise
   déjà les pixels en [0, 1] (`pixel.rNormalized`) avant de les donner à
   l'interprète TFLite. Le graphe exporté ici suppose désormais la même
   entrée (`Rescaling(scale=2.0, offset=-1.0)`, [0,1] → [-1,1]) au lieu de
   pixels bruts [0, 255] : un modèle qui suppose l'inverse recevrait, une fois
   déployé, une entrée déjà divisée par 255 et produirait des probabilités
   silencieusement fausses (aucune erreur, juste un modèle cassé). Voir aussi
   `ml/scripts/eval_off_topic.py`, qui applique le même contrat et peut
   maintenant évaluer n'importe quel modèle candidat via `--model`/`--labels`.

Autres ajouts, tous par défaut sans effet sur le résultat sauf mention
contraire : graine unique (`--seed`) propagée à TensorFlow/Keras en plus de
numpy pour un entraînement reproductible ; `--kfold` (défaut 0 = désactivé)
pour une validation croisée peu coûteuse (features en cache, seule la petite
tête dense est réentraînée K fois) qui donne une moyenne/écart-type par
classe — utile pour juger si les classes rares (cercosporiose, echaudure)
sont vraiment faibles ou juste mal tombées dans le découpage 80/20 ; tête
dense qui sort des logits (`from_logits=True` dans la perte) plutôt qu'un
softmax, pratique standard plus stable numériquement et prérequis de la
calibration par température.

Prérequis : ml/scripts/extract_datasets.py puis ml/scripts/prepare_training_data.py
(et pour la classe pas_riz : ml/scripts/fetch_negatives.py, images copiées à la
main ou par script dans <data-root>/prepared/feuille/pas_riz/).

Usage :
    ml/.venv/Scripts/python ml/scripts/train_feuille.py
    ml/.venv/Scripts/python ml/scripts/train_feuille.py --data-root D:/agrimada-ml --epochs 40
    ml/.venv/Scripts/python ml/scripts/train_feuille.py --mixup-alpha 0 --label-smoothing 0  # comportement d'avant, pour comparer
    ml/.venv/Scripts/python ml/scripts/train_feuille.py --kfold 5  # + validation croisée diagnostique
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from datetime import date
from pathlib import Path
from typing import Iterator

import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

ROOT = Path(__file__).resolve().parents[2]
MODELS_DIR = ROOT / "ml" / "models" / "feuille_v2"
CACHE_FILE = MODELS_DIR / "cache" / "features.npz"
REPORTS_DIR = ROOT / "ml" / "reports"
HORS_SUJET_DIR = ROOT / "ml" / "data" / "raw" / "hors_sujet"
IMG_SIZE = 224
FEATURE_DIM = 1280  # sortie de MobileNetV2 avec pooling='avg'
IMAGE_EXT = (".jpg", ".jpeg", ".png")


def lister_images(prepared_dir: Path) -> tuple[list[str], list[str], np.ndarray]:
    """Liste les images par classe (nom du sous-dossier). Ne dépend d'aucun
    ordre de shuffle interne à Keras : la même liste est reproduite à
    l'identique tant que les fichiers ne changent pas, condition nécessaire
    pour que le cache de features reste valide d'un run à l'autre."""
    if not prepared_dir.is_dir():
        sys.exit(f"{prepared_dir} introuvable : lancer d'abord prepare_training_data.py")
    class_names = sorted(p.name for p in prepared_dir.iterdir() if p.is_dir())
    if len(class_names) < 2:
        sys.exit(f"Moins de 2 classes trouvées sous {prepared_dir}.")

    paths: list[str] = []
    labels: list[int] = []
    for i, classe in enumerate(class_names):
        fichiers = sorted(
            p for p in (prepared_dir / classe).iterdir() if p.suffix.lower() in IMAGE_EXT
        )
        for p in fichiers:
            paths.append(str(p.resolve()))
            labels.append(i)
    return class_names, paths, np.array(labels, dtype=np.int64)


def split_stratifie(labels: np.ndarray, val_ratio: float, seed: int) -> tuple[np.ndarray, np.ndarray]:
    """Découpe train/validation classe par classe, pour qu'une classe rare
    (ex. cercosporiose, 117 images) soit bien représentée des deux côtés."""
    rng = np.random.default_rng(seed)
    train_idx: list[int] = []
    val_idx: list[int] = []
    for classe in np.unique(labels):
        idx = np.where(labels == classe)[0].copy()
        rng.shuffle(idx)
        n_val = max(1, round(len(idx) * val_ratio))
        val_idx.extend(idx[:n_val].tolist())
        train_idx.extend(idx[n_val:].tolist())
    return np.array(train_idx), np.array(val_idx)


def k_fold_indices(labels: np.ndarray, k: int, seed: int) -> list[np.ndarray]:
    """Découpe des positions [0, len(labels)) en k blocs stratifiés par classe
    (répartition round-robin après mélange). Sert la validation croisée
    diagnostique (--kfold) : peu coûteuse ici puisque les features sont déjà
    en cache, seule la tête dense (quelques secondes) est réentraînée K fois."""
    rng = np.random.default_rng(seed)
    blocs: list[list[int]] = [[] for _ in range(k)]
    for classe in np.unique(labels):
        idx = np.where(labels == classe)[0].copy()
        rng.shuffle(idx)
        for position, i in enumerate(idx):
            blocs[position % k].append(int(i))
    return [np.array(b, dtype=np.int64) for b in blocs]


class CacheFeatures:
    """Cache disque des features MobileNetV2, clé = chemin absolu de l'image.

    Format : un .npz avec un tableau `paths` (chaînes) et `features`
    (float32, N x FEATURE_DIM), dans le même ordre. Rechargé et réécrit en
    entier à chaque sauvegarde (quelques dizaines de Mo, quelques secondes) :
    largement suffisant vu la fréquence d'appel (une fois par session
    d'entraînement, pas par epoch).
    """

    def __init__(self, chemin: Path):
        self.chemin = chemin
        self.index: dict[str, int] = {}
        self.features = np.zeros((0, FEATURE_DIM), dtype=np.float32)
        if chemin.exists():
            data = np.load(chemin, allow_pickle=False)
            paths = data["paths"]
            self.features = data["features"]
            self.index = {p: i for i, p in enumerate(paths)}

    def manquants(self, paths: list[str]) -> list[str]:
        return [p for p in paths if p not in self.index]

    def ajouter(self, paths: list[str], features: np.ndarray) -> None:
        depart = len(self.index)
        for i, p in enumerate(paths):
            self.index[p] = depart + i
        self.features = np.concatenate([self.features, features], axis=0)

    def recuperer(self, paths: list[str]) -> np.ndarray:
        return np.stack([self.features[self.index[p]] for p in paths])

    def sauvegarder(self) -> None:
        self.chemin.parent.mkdir(parents=True, exist_ok=True)
        paths_ordonnes = sorted(self.index, key=self.index.get)
        np.savez(self.chemin, paths=np.array(paths_ordonnes), features=self.features)


def charger_image(chemin: str) -> np.ndarray:
    """Pixels bruts [0, 255], format attendu par
    tf.keras.applications.mobilenet_v2.preprocess_input (extraction de
    features uniquement — pas le contrat d'entrée du modèle exporté, voir
    evaluer_hors_sujet)."""
    image = tf.keras.utils.load_img(chemin, target_size=(IMG_SIZE, IMG_SIZE))
    return tf.keras.utils.img_to_array(image)


def extraire_features_manquantes(
    base_model: keras.Model, cache: CacheFeatures, paths: list[str], batch_size: int
) -> None:
    a_calculer = cache.manquants(paths)
    if not a_calculer:
        print("Cache complet : aucune nouvelle image à passer dans MobileNetV2.")
        return
    print(f"{len(a_calculer)} image(s) à calculer (sur {len(paths)}), {len(paths) - len(a_calculer)} déjà en cache.")
    for depart in range(0, len(a_calculer), batch_size):
        lot_paths = a_calculer[depart : depart + batch_size]
        lot_images = np.stack([charger_image(p) for p in lot_paths])
        preprocessed = tf.keras.applications.mobilenet_v2.preprocess_input(lot_images)
        features = base_model(preprocessed, training=False).numpy()
        cache.ajouter(lot_paths, features)
        if depart % (batch_size * 20) == 0:
            print(f"  {depart + len(lot_paths)}/{len(a_calculer)}")
    cache.sauvegarder()


def matrice_confusion(y_true: np.ndarray, y_pred: np.ndarray, n_classes: int) -> np.ndarray:
    matrice = np.zeros((n_classes, n_classes), dtype=int)
    for vrai, predit in zip(y_true, y_pred):
        matrice[vrai, predit] += 1
    return matrice


def metriques_par_classe(matrice: np.ndarray, class_names: list[str]) -> list[dict]:
    resultats = []
    for i, nom in enumerate(class_names):
        tp = matrice[i, i]
        fp = matrice[:, i].sum() - tp
        fn = matrice[i, :].sum() - tp
        support = matrice[i, :].sum()
        precision = tp / (tp + fp) if (tp + fp) > 0 else 0.0
        rappel = tp / (tp + fn) if (tp + fn) > 0 else 0.0
        f1 = 2 * precision * rappel / (precision + rappel) if (precision + rappel) > 0 else 0.0
        resultats.append(
            {"classe": nom, "support": int(support), "precision": precision, "rappel": rappel, "f1": f1}
        )
    return resultats


# --- Tête dense : construction, poids par échantillon, mixup en espace features ---


def construire_tete(n_classes: int) -> keras.Model:
    """Sort des logits (pas de softmax) : la calibration par température a
    besoin des logits, et `from_logits=True` dans la perte est de toute façon
    la pratique recommandée pour la stabilité numérique."""
    return keras.Sequential(
        [
            layers.Input(shape=(FEATURE_DIM,)),
            layers.Dense(256, activation="relu"),
            layers.Dropout(0.4),
            layers.Dense(n_classes),
        ]
    )


def poids_echantillon(labels: np.ndarray, n_classes: int) -> np.ndarray:
    """Un poids par exemple, inversement proportionnel à l'effectif de sa
    classe — même formule que l'ancien `class_weight`, mais passée en
    `sample_weight` : ça marche à l'identique avec des cibles one-hot (requis
    pour `label_smoothing`) sans dépendre du comportement de Keras face à un
    `class_weight` en présence de cibles 2D."""
    effectifs = np.bincount(labels, minlength=n_classes)
    poids_par_classe = len(labels) / (n_classes * np.maximum(effectifs, 1))
    return poids_par_classe[labels].astype(np.float32)


def generer_lots_mixup(
    X: np.ndarray,
    y_onehot: np.ndarray,
    poids_tirage: np.ndarray,
    batch_size: int,
    alpha: float,
    seed: int,
) -> Iterator[tuple[np.ndarray, np.ndarray]]:
    """Génère des lots mélangés (mixup, Zhang et al. 2018) dans l'espace des
    features déjà en cache : coût quasi nul (vecteurs 1280-d), pas de nouvelle
    passe dans MobileNetV2. Le ré-équilibrage des classes rares se fait par
    tirage pondéré (`poids_tirage`, typiquement `poids_echantillon`) plutôt
    que par poids de perte, qui n'a pas de sens sur un exemple mélangé entre
    deux classes différentes."""
    rng = np.random.default_rng(seed)
    proba = poids_tirage / poids_tirage.sum()
    n = len(X)
    while True:
        i = rng.choice(n, size=batch_size, p=proba)
        j = rng.choice(n, size=batch_size, p=proba)
        lam = rng.beta(alpha, alpha, size=batch_size).astype(np.float32) if alpha > 0 else np.ones(batch_size, dtype=np.float32)
        lam = lam.reshape(-1, 1)
        X_mix = lam * X[i] + (1 - lam) * X[j]
        y_mix = lam * y_onehot[i] + (1 - lam) * y_onehot[j]
        yield X_mix.astype(np.float32), y_mix.astype(np.float32)


def entrainer_tete(
    X_train: np.ndarray,
    y_train: np.ndarray,
    X_val: np.ndarray,
    y_val: np.ndarray,
    n_classes: int,
    args: argparse.Namespace,
    verbose: int = 2,
) -> tuple[keras.Model, keras.callbacks.History]:
    """Entraîne une tête dense depuis des features déjà en cache. Utilisée
    pour l'entraînement principal et pour chaque pli de la validation croisée
    (--kfold), avec les mêmes réglages de régularisation à chaque fois."""
    tete = construire_tete(n_classes)
    tete.compile(
        optimizer="adam",
        loss=keras.losses.CategoricalCrossentropy(from_logits=True, label_smoothing=args.label_smoothing),
        metrics=[keras.metrics.CategoricalAccuracy(name="accuracy")],
    )
    y_train_oh = tf.one_hot(y_train, n_classes).numpy()
    y_val_oh = tf.one_hot(y_val, n_classes).numpy()
    poids = poids_echantillon(y_train, n_classes)
    callbacks = [
        keras.callbacks.EarlyStopping(monitor="val_loss", patience=6, restore_best_weights=True),
        keras.callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.3, patience=3, min_lr=1e-6),
    ]

    if args.mixup_alpha > 0:
        pas_par_epoch = max(1, len(X_train) // args.head_batch_size)
        generateur = generer_lots_mixup(
            X_train, y_train_oh, poids, args.head_batch_size, args.mixup_alpha, args.seed
        )
        historique = tete.fit(
            generateur,
            steps_per_epoch=pas_par_epoch,
            epochs=args.epochs,
            validation_data=(X_val, y_val_oh),
            callbacks=callbacks,
            verbose=verbose,
        )
    else:
        historique = tete.fit(
            X_train,
            y_train_oh,
            sample_weight=poids,
            validation_data=(X_val, y_val_oh),
            epochs=args.epochs,
            batch_size=args.head_batch_size,
            callbacks=callbacks,
            verbose=verbose,
        )
    return tete, historique


# --- Calibration par température (Guo et al. 2017) ---


def softmax_temperature(logits: np.ndarray, temperature: float) -> np.ndarray:
    z = logits / temperature
    z = z - z.max(axis=1, keepdims=True)
    exp = np.exp(z)
    return exp / exp.sum(axis=1, keepdims=True)


def ajuster_temperature(logits_val: np.ndarray, y_val: np.ndarray, plage: tuple[float, float] = (0.05, 5.0), pas: int = 200) -> float:
    """Cherche le T minimisant la perte de log-vraisemblance négative sur la
    validation, par recherche en grille (pas de dépendance à scipy — le
    problème est convexe en pratique et une grille fine suffit)."""
    meilleure_t, meilleure_perte = 1.0, np.inf
    for t in np.linspace(plage[0], plage[1], pas):
        probs = softmax_temperature(logits_val, t)
        perte = -np.log(np.clip(probs[np.arange(len(y_val)), y_val], 1e-12, 1.0)).mean()
        if perte < meilleure_perte:
            meilleure_perte, meilleure_t = perte, t
    return float(meilleure_t)


def erreur_calibration_attendue(probs: np.ndarray, y_true: np.ndarray, n_bins: int = 15) -> float:
    """ECE (Guo et al. 2017) : écart moyen, pondéré par les effectifs, entre
    la confiance déclarée (proba de la classe prédite) et le taux de succès
    réel, par tranche de confiance. 0 = parfaitement calibré. C'est la mesure
    directe du défaut constaté le 2026-09-17 (confiance élevée sur du hors
    sujet) ; la porte séparée (P4.2) reste nécessaire, l'ECE sert seulement à
    suivre si la calibration s'améliore d'un entraînement à l'autre."""
    confiances = probs.max(axis=1)
    predictions = probs.argmax(axis=1)
    corrects = (predictions == y_true).astype(np.float64)
    bornes = np.linspace(0.0, 1.0, n_bins + 1)
    ece = 0.0
    for basse, haute in zip(bornes[:-1], bornes[1:]):
        dans_bin = (confiances > basse) & (confiances <= haute)
        if not dans_bin.any():
            continue
        ece += (dans_bin.sum() / len(confiances)) * abs(confiances[dans_bin].mean() - corrects[dans_bin].mean())
    return float(ece)


def score_brier(probs: np.ndarray, y_true: np.ndarray, n_classes: int) -> float:
    y_onehot = np.eye(n_classes, dtype=np.float64)[y_true]
    return float(np.mean(np.sum((probs - y_onehot) ** 2, axis=1)))


def evaluer_hors_sujet(modele_inference: keras.Model, class_names: list[str]) -> dict | None:
    """Reprend le jeu hors_sujet de P1.2 (50 photos, aucune n'est du riz, jamais
    utilisées à l'entraînement même quand pas_riz existe : fetch_negatives.py
    exclut leurs sha256) pour vérifier si le modèle évite le défaut du modèle
    actuel (ADR-006) : proposer une maladie avec une confiance élevée sur une
    photo hors sujet. Si la classe pas_riz existe, on regarde en plus combien
    de ces photos sont bien classées pas_riz : la vraie mesure de la porte.

    `modele_inference` attend des pixels normalisés en [0, 1] (même contrat
    que lib/core/ai/tflite_service.dart) : `charger_image` renvoie des pixels
    bruts [0, 255] (utile ailleurs pour mobilenet_v2.preprocess_input), d'où
    la division par 255 ici."""
    if not HORS_SUJET_DIR.is_dir():
        return None
    chemins = sorted(p for p in HORS_SUJET_DIR.rglob("*") if p.suffix.lower() in (".jpg", ".jpeg", ".png"))
    if not chemins:
        return None

    lot = np.stack([charger_image(str(p)) for p in chemins]) / 255.0
    probabilites = modele_inference.predict(lot, verbose=0)
    confiances = probabilites.max(axis=1)
    predictions = np.argmax(probabilites, axis=1)

    seuils = [0.70, 0.90, 0.999]
    resultat = {
        "n_photos": len(chemins),
        "confiance_moyenne": float(confiances.mean()),
        "confiance_max": float(confiances.max()),
        "au_dessus_du_seuil": {str(seuil): int((confiances >= seuil).sum()) for seuil in seuils},
    }
    if "pas_riz" in class_names:
        idx_pas_riz = class_names.index("pas_riz")
        resultat["classees_pas_riz"] = int((predictions == idx_pas_riz).sum())
    return resultat


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--data-root", type=Path, default=Path("D:/agrimada-ml"))
    parser.add_argument("--epochs", type=int, default=40)
    parser.add_argument("--batch-size", type=int, default=32, help="taille de lot pour l'extraction des features MobileNetV2")
    parser.add_argument("--head-batch-size", type=int, default=64, help="taille de lot pour l'entraînement de la tête dense")
    parser.add_argument("--val-ratio", type=float, default=0.2)
    parser.add_argument("--seed", type=int, default=123)
    parser.add_argument("--label-smoothing", type=float, default=0.05, help="lissage des étiquettes (0 = désactivé, comportement d'avant)")
    parser.add_argument("--mixup-alpha", type=float, default=0.2, help="paramètre beta du mixup en espace features (0 = désactivé, comportement d'avant)")
    parser.add_argument("--kfold", type=int, default=0, help="nombre de plis pour une validation croisée diagnostique (0 = désactivé)")
    args = parser.parse_args()

    keras.utils.set_random_seed(args.seed)
    print(f"TensorFlow {tf.__version__}, GPU dispo : {bool(tf.config.list_physical_devices('GPU'))}")

    class_names, paths, labels = lister_images(args.data_root / "prepared" / "feuille")
    n_classes = len(class_names)
    print(f"{n_classes} classes, {len(paths)} images : {class_names}")

    base_model = tf.keras.applications.MobileNetV2(
        input_shape=(IMG_SIZE, IMG_SIZE, 3), include_top=False, weights="imagenet", pooling="avg"
    )
    base_model.trainable = False

    cache = CacheFeatures(CACHE_FILE)
    extraire_features_manquantes(base_model, cache, paths, args.batch_size)

    train_idx, val_idx = split_stratifie(labels, args.val_ratio, args.seed)
    X_train, y_train = cache.recuperer([paths[i] for i in train_idx]), labels[train_idx]
    X_val, y_val = cache.recuperer([paths[i] for i in val_idx]), labels[val_idx]
    print(f"train: {X_train.shape}, val: {X_val.shape}")

    effectifs = np.bincount(y_train, minlength=n_classes)

    tete, historique = entrainer_tete(X_train, y_train, X_val, y_val, n_classes, args)

    logits_val = tete.predict(X_val, verbose=0)
    y_pred = np.argmax(logits_val, axis=1)
    matrice = matrice_confusion(y_val, y_pred, n_classes)
    metriques = metriques_par_classe(matrice, class_names)
    exactitude_globale = float((y_val == y_pred).mean())
    macro_f1 = float(np.mean([m["f1"] for m in metriques]))
    print(f"\nExactitude sur la validation : {exactitude_globale:.4f} (macro-F1 : {macro_f1:.4f})")

    # --- Calibration par température : ajustée sur les logits de validation,
    # puis intégrée au graphe exporté (division des logits par T avant le
    # softmax final) pour que l'app reçoive des probabilités moins trompeuses
    # sans rien changer côté Dart. ---
    temperature = ajuster_temperature(logits_val, y_val)
    probs_brutes = softmax_temperature(logits_val, 1.0)
    probs_calibrees = softmax_temperature(logits_val, temperature)
    ece_avant = erreur_calibration_attendue(probs_brutes, y_val)
    ece_apres = erreur_calibration_attendue(probs_calibrees, y_val)
    brier_avant = score_brier(probs_brutes, y_val, n_classes)
    brier_apres = score_brier(probs_calibrees, y_val, n_classes)
    print(f"Température calibrée : {temperature:.3f} (ECE {ece_avant:.4f} -> {ece_apres:.4f}, Brier {brier_avant:.4f} -> {brier_apres:.4f})")

    # --- Validation croisée diagnostique (optionnelle) : utile pour juger si
    # les classes rares (cercosporiose, echaudure) sont vraiment faibles ou
    # juste mal tombées dans ce découpage 80/20 précis. ---
    validation_croisee = None
    if args.kfold and args.kfold > 1:
        print(f"\nValidation croisée à {args.kfold} plis (tête réentraînée {args.kfold} fois, features déjà en cache)...")
        tous_indices = np.concatenate([train_idx, val_idx])
        tous_labels = labels[tous_indices]
        plis = k_fold_indices(tous_labels, args.kfold, args.seed)
        f1_par_classe: dict[str, list[float]] = {nom: [] for nom in class_names}
        exactitudes: list[float] = []
        for p in range(args.kfold):
            idx_val_pli = tous_indices[plis[p]]
            idx_train_pli = tous_indices[np.concatenate([plis[q] for q in range(args.kfold) if q != p])]
            X_tr, y_tr = cache.recuperer([paths[i] for i in idx_train_pli]), labels[idx_train_pli]
            X_va, y_va = cache.recuperer([paths[i] for i in idx_val_pli]), labels[idx_val_pli]
            tete_p, _ = entrainer_tete(X_tr, y_tr, X_va, y_va, n_classes, args, verbose=0)
            pred_p = np.argmax(tete_p.predict(X_va, verbose=0), axis=1)
            matrice_p = matrice_confusion(y_va, pred_p, n_classes)
            for m in metriques_par_classe(matrice_p, class_names):
                f1_par_classe[m["classe"]].append(m["f1"])
            exactitude_pli = float((y_va == pred_p).mean())
            exactitudes.append(exactitude_pli)
            print(f"  pli {p + 1}/{args.kfold} : exactitude {exactitude_pli:.4f}")
        validation_croisee = {
            "k": args.kfold,
            "exactitude": {"moyenne": float(np.mean(exactitudes)), "ecart_type": float(np.std(exactitudes))},
            "f1_par_classe": {
                nom: {"moyenne": float(np.mean(v)), "ecart_type": float(np.std(v))}
                for nom, v in f1_par_classe.items()
            },
        }

    # --- Modèle d'inférence complet (pixels [0,1] -> probabilités calibrées) ---
    # Contrat d'entrée : identique à lib/core/ai/tflite_service.dart
    # (pixel.rNormalized, déjà en [0,1]), voir la note en tête de fichier.
    entrees = layers.Input(shape=(IMG_SIZE, IMG_SIZE, 3))
    x = layers.Rescaling(scale=2.0, offset=-1.0)(entrees)  # [0,1] -> [-1,1]
    x = base_model(x, training=False)
    logits = tete(x)
    logits_calibres = layers.Rescaling(scale=1.0 / temperature, offset=0.0)(logits)
    sorties = layers.Softmax()(logits_calibres)
    modele_inference = keras.Model(entrees, sorties)

    resultat_hors_sujet = evaluer_hors_sujet(modele_inference, class_names)

    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    modele_inference.export(str(MODELS_DIR / "saved_model"))
    converter = tf.lite.TFLiteConverter.from_saved_model(str(MODELS_DIR / "saved_model"))
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    (MODELS_DIR / "model.tflite").write_bytes(tflite_model)
    (MODELS_DIR / "labels.txt").write_text("\n".join(class_names) + "\n", encoding="utf-8")

    metriques_json = {
        "date": date.today().isoformat(),
        "framework": f"tensorflow {tf.__version__}",
        "classes": class_names,
        "effectifs_entrainement": {class_names[i]: int(n) for i, n in enumerate(effectifs)},
        "exactitude_validation": exactitude_globale,
        "macro_f1": macro_f1,
        "par_classe": metriques,
        "hors_sujet": resultat_hors_sujet,
        "epochs_effectues": len(historique.history["loss"]),
        "regularisation": {
            "label_smoothing": args.label_smoothing,
            "mixup_alpha": args.mixup_alpha,
            "seed": args.seed,
        },
        "calibration": {
            "temperature": temperature,
            "ece_avant": ece_avant,
            "ece_apres": ece_apres,
            "brier_avant": brier_avant,
            "brier_apres": brier_apres,
        },
        "validation_croisee": validation_croisee,
    }
    (MODELS_DIR / "metrics.json").write_text(json.dumps(metriques_json, indent=2, ensure_ascii=False), encoding="utf-8")

    with (MODELS_DIR / "confusion_matrix.csv").open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow([""] + class_names)
        for i, nom in enumerate(class_names):
            writer.writerow([nom] + list(matrice[i]))

    print(f"\nModèle et métriques écrits dans {MODELS_DIR}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
