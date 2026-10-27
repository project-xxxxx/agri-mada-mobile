"""Tests des fonctions pures de train_feuille.py (calibration, mixup, k-fold).

Comme ml/data/test_dedup.py : pas de dépendance à pytest, données synthétiques
uniquement (aucune vraie image, aucun jeu de données requis). Le seul test qui
appelle réellement `tete.fit()` (`test_entrainer_tete_smoke`) le fait sur des
features aléatoires minuscules (quelques dizaines d'exemples, 3 epochs) : ce
n'est pas un entraînement du modèle, seulement une vérification que le
branchement (générateur mixup, perte à partir de logits, callbacks) ne casse
pas — ça prend une poignée de secondes, aucune image n'est lue.

Usage :
    ml/.venv/Scripts/python ml/scripts/test_train_feuille.py
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))

from train_feuille import (  # noqa: E402
    ajuster_temperature,
    entrainer_tete,
    erreur_calibration_attendue,
    generer_lots_mixup,
    k_fold_indices,
    poids_echantillon,
    score_brier,
    softmax_temperature,
)


def test_poids_echantillon_favorise_les_classes_rares() -> None:
    labels = np.array([0, 0, 0, 0, 1, 1, 2])  # classe 0 : 4, classe 1 : 2, classe 2 : 1
    poids = poids_echantillon(labels, n_classes=3)
    assert poids.shape == (7,)
    assert poids[labels == 2][0] > poids[labels == 1][0] > poids[labels == 0][0]


def test_softmax_temperature_est_un_simplexe() -> None:
    logits = np.array([[2.0, 0.5, -1.0], [0.1, 0.1, 0.1]])
    for t in (0.5, 1.0, 3.0):
        probs = softmax_temperature(logits, t)
        assert np.allclose(probs.sum(axis=1), 1.0)
        assert (probs >= 0).all()


def test_temperature_plus_grande_adoucit_la_confiance() -> None:
    logits = np.array([[5.0, 0.0, 0.0]])
    confiance_froide = softmax_temperature(logits, 1.0)[0, 0]
    confiance_chaude = softmax_temperature(logits, 4.0)[0, 0]
    assert confiance_chaude < confiance_froide


def test_ajuster_temperature_corrige_un_surconfiance_connue() -> None:
    # Construction où T=1 est *exactement* calibré par définition : les
    # étiquettes sont tirées des probabilités elles-mêmes, et
    # softmax(log(p)) == p. Un facteur de sur-confiance connu appliqué aux
    # logits doit donc être retrouvé (à peu près) par la recherche de T.
    rng = np.random.default_rng(0)
    n, k = 3000, 4
    vraies_probs = rng.dirichlet(alpha=[2, 1, 1, 1], size=n)
    y_true = np.array([rng.choice(k, p=vraies_probs[i]) for i in range(n)])
    logits_calibres = np.log(vraies_probs + 1e-12)

    facteur_surconfiance = 3.0
    logits_surconfiants = logits_calibres * facteur_surconfiance  # même argmax, confiance exagérée

    temperature = ajuster_temperature(logits_surconfiants, y_true)
    assert 2.0 < temperature < 4.0, f"T={temperature} devrait ~retrouver le facteur {facteur_surconfiance}"

    ece_avant = erreur_calibration_attendue(softmax_temperature(logits_surconfiants, 1.0), y_true)
    ece_apres = erreur_calibration_attendue(softmax_temperature(logits_surconfiants, temperature), y_true)
    assert ece_apres < ece_avant


def test_erreur_calibration_nulle_si_parfaitement_calibre() -> None:
    # Deux exemples avec 100% de confiance, tous deux corrects : la confiance
    # déclarée (1.0) égale le taux de succès réel (1.0) dans ce bin -> ECE = 0.
    probs = np.array([[1.0, 0.0], [1.0, 0.0]])
    y_true = np.array([0, 0])
    assert erreur_calibration_attendue(probs, y_true) == 0.0


def test_score_brier_zero_si_prediction_parfaite() -> None:
    probs = np.eye(3)[np.array([0, 1, 2, 0])]
    y_true = np.array([0, 1, 2, 0])
    assert score_brier(probs, y_true, 3) == 0.0


def test_score_brier_penalise_une_confiance_totale_fausse() -> None:
    probs = np.array([[1.0, 0.0, 0.0]])
    y_true = np.array([1])
    assert score_brier(probs, y_true, 3) == 2.0  # (1-0)^2 + (0-1)^2 + (0-0)^2


def test_mixup_alpha_zero_revient_a_un_tirage_sans_melange() -> None:
    X = np.arange(20, dtype=np.float32).reshape(10, 2)
    y_onehot = np.eye(4)[[0, 0, 1, 1, 2, 2, 3, 3, 0, 1]]
    poids = np.ones(10, dtype=np.float32)

    generateur = generer_lots_mixup(X, y_onehot, poids, batch_size=5, alpha=0.0, seed=1)
    X_lot, y_lot = next(generateur)

    assert X_lot.shape == (5, 2)
    assert y_lot.shape == (5, 4)
    assert np.allclose(y_lot.sum(axis=1), 1.0)  # toujours un simplexe, même sans mélange
    for ligne in X_lot:
        assert any(np.allclose(ligne, x) for x in X), "alpha=0 doit reproduire une ligne existante telle quelle"


def test_mixup_alpha_positif_reste_un_simplexe() -> None:
    X = np.random.default_rng(2).normal(size=(30, 5)).astype(np.float32)
    y_onehot = np.eye(3)[np.random.default_rng(3).integers(0, 3, size=30)]
    poids = poids_echantillon(np.argmax(y_onehot, axis=1), n_classes=3)

    generateur = generer_lots_mixup(X, y_onehot, poids, batch_size=8, alpha=0.3, seed=4)
    for _ in range(3):
        X_lot, y_lot = next(generateur)
        assert X_lot.shape == (8, 5)
        assert np.allclose(y_lot.sum(axis=1), 1.0)
        assert (y_lot >= 0).all()


def test_k_fold_indices_partitionne_sans_chevauchement() -> None:
    labels = np.array([0] * 10 + [1] * 7 + [2] * 3)
    plis = k_fold_indices(labels, k=4, seed=0)
    assert len(plis) == 4

    toutes_positions = np.concatenate(plis)
    assert sorted(toutes_positions.tolist()) == list(range(len(labels))), "chaque position doit apparaître exactement une fois"


def test_k_fold_indices_equilibre_quand_divisible() -> None:
    # Round-robin par classe : parfaitement équilibré seulement quand chaque
    # effectif de classe est un multiple de k (sinon les restes par classe
    # peuvent s'accumuler sur les mêmes plis, voir le test ci-dessus pour la
    # seule garantie générale : une partition complète, sans chevauchement).
    labels = np.array([0] * 8 + [1] * 8 + [2] * 8)
    plis = k_fold_indices(labels, k=4, seed=0)
    tailles = [len(p) for p in plis]
    assert tailles == [6, 6, 6, 6]


def test_entrainer_tete_smoke_synthetique() -> None:
    """Vérifie le branchement (générateur mixup, perte from_logits, callbacks)
    sur des données factices minuscules — pas un entraînement réel, juste un
    test de câblage rapide (quelques secondes, aucune image)."""
    import argparse

    rng = np.random.default_rng(42)
    n_classes, dim = 3, 1280
    X_train = rng.normal(size=(60, dim)).astype(np.float32)
    y_train = rng.integers(0, n_classes, size=60)
    X_val = rng.normal(size=(15, dim)).astype(np.float32)
    y_val = rng.integers(0, n_classes, size=15)

    for mixup_alpha in (0.0, 0.2):
        args = argparse.Namespace(
            epochs=3, head_batch_size=16, label_smoothing=0.05, mixup_alpha=mixup_alpha, seed=42
        )
        tete, historique = entrainer_tete(X_train, y_train, X_val, y_val, n_classes, args, verbose=0)
        assert "val_loss" in historique.history
        logits = tete.predict(X_val, verbose=0)
        assert logits.shape == (15, n_classes)


def main() -> int:
    tests = [
        test_poids_echantillon_favorise_les_classes_rares,
        test_softmax_temperature_est_un_simplexe,
        test_temperature_plus_grande_adoucit_la_confiance,
        test_ajuster_temperature_corrige_un_surconfiance_connue,
        test_erreur_calibration_nulle_si_parfaitement_calibre,
        test_score_brier_zero_si_prediction_parfaite,
        test_score_brier_penalise_une_confiance_totale_fausse,
        test_mixup_alpha_zero_revient_a_un_tirage_sans_melange,
        test_mixup_alpha_positif_reste_un_simplexe,
        test_k_fold_indices_partitionne_sans_chevauchement,
        test_k_fold_indices_equilibre_quand_divisible,
        test_entrainer_tete_smoke_synthetique,
    ]
    for test in tests:
        test()
        print(f"ok  {test.__name__}")
    print(f"\n{len(tests)} test(s) réussi(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
