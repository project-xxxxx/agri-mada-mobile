"""Tests des fonctions pures de l'architecture à trois étages (P4.2).

Couvre ml/scripts/train_feuille_multilabel.py (seuils, décision, poids,
température sigmoïde) et le routage de ml/scripts/eval_chaine.py (porte puis
organe). Même convention que test_train_feuille.py : sans pytest, données
synthétiques, aucune image lue, aucun modèle entraîné.

Usage :
    ml/.venv/Scripts/python ml/scripts/test_architecture_3_etages.py
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))

from eval_chaine import decider_chaine  # noqa: E402
from train_feuille_multilabel import (  # noqa: E402
    ajuster_temperature_sigmoide,
    choisir_seuil,
    decision,
    poids_par_groupe,
    sigmoid,
)


class _TeteFixe:
    """Remplace une tête Keras : renvoie des logits imposés, quelle que soit l'entrée."""

    def __init__(self, logits: np.ndarray) -> None:
        self.logits = logits

    def predict(self, X: np.ndarray, verbose: int = 0) -> np.ndarray:
        return self.logits


def test_decision_saine_quand_rien_ne_depasse_son_seuil() -> None:
    probs = np.array([[0.10, 0.20], [0.05, 0.01]])
    seuils = np.array([0.5, 0.5])
    assert list(decision(probs, seuils)) == [-1, -1]


def test_decision_retient_la_plus_forte_marge_relative() -> None:
    # Classe 0 : 0.60 / seuil 0.50 = 1.2 ; classe 1 : 0.30 / seuil 0.20 = 1.5.
    # La classe 1 l'emporte malgré une probabilité brute plus basse.
    probs = np.array([[0.60, 0.30]])
    seuils = np.array([0.50, 0.20])
    assert decision(probs, seuils)[0] == 1


def test_decision_ignore_une_classe_sous_son_seuil_meme_si_plus_forte() -> None:
    probs = np.array([[0.45, 0.25]])
    seuils = np.array([0.50, 0.20])
    assert decision(probs, seuils)[0] == 1


def test_choisir_seuil_separe_des_scores_parfaitement_ordonnes() -> None:
    probs = np.array([0.9, 0.8, 0.7, 0.3, 0.2, 0.1])
    y = np.array([1, 1, 1, 0, 0, 0])
    seuil, m = choisir_seuil(probs, y)
    assert 0.3 < seuil <= 0.7
    assert m["f1"] == 1.0


def test_choisir_seuil_sans_positif_ne_plante_pas() -> None:
    seuil, m = choisir_seuil(np.array([0.2, 0.4]), np.array([0, 0]))
    assert m["f1"] == 0.0
    assert 0.0 < seuil < 1.0


def test_poids_par_groupe_favorise_les_groupes_rares() -> None:
    groupes = np.array([0, 0, 0, 0, 1, 1, 2])
    poids = poids_par_groupe(groupes)
    assert poids[groupes == 2][0] > poids[groupes == 1][0] > poids[groupes == 0][0]


def test_temperature_sigmoide_proche_de_un_si_deja_calibre() -> None:
    rng = np.random.default_rng(0)
    logits = rng.normal(0, 2, size=(4000, 3))
    y = (rng.random(logits.shape) < sigmoid(logits)).astype(np.float32)
    t = ajuster_temperature_sigmoide(logits, y)
    assert 0.8 < t < 1.25, t


def test_chaine_rejete_avant_de_regarder_l_organe() -> None:
    # Logits de porte : [pas_riz, riz_exploitable]. La porte rejette la
    # première photo ; l'étage B, pourtant très sûr d'une maladie, n'est pas écouté.
    porte = _TeteFixe(np.array([[5.0, -5.0], [-5.0, 5.0], [-5.0, 5.0]]))
    feuille = _TeteFixe(np.array([[9.0, -9.0], [-9.0, -9.0], [-9.0, 9.0]]))
    decisions = decider_chaine(
        np.zeros((3, 4)), porte, 1.0, 0.5, feuille, 1.0, ["blb", "bls"], np.array([0.5, 0.5])
    )
    assert decisions == ["pas_riz", "feuille_saine", "bls"]


def main() -> int:
    tests = [
        test_decision_saine_quand_rien_ne_depasse_son_seuil,
        test_decision_retient_la_plus_forte_marge_relative,
        test_decision_ignore_une_classe_sous_son_seuil_meme_si_plus_forte,
        test_choisir_seuil_separe_des_scores_parfaitement_ordonnes,
        test_choisir_seuil_sans_positif_ne_plante_pas,
        test_poids_par_groupe_favorise_les_groupes_rares,
        test_temperature_sigmoide_proche_de_un_si_deja_calibre,
        test_chaine_rejete_avant_de_regarder_l_organe,
    ]
    for test in tests:
        test()
        print(f"ok  {test.__name__}")
    print(f"\n{len(tests)} test(s) réussi(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
