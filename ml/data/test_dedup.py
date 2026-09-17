"""Test de ml/data/dedup.py::grouper_par_similarite (tâche P3.6).

Pas de dépendance à pytest ni à de vraies images : un hash perceptuel synthétique
suffit, seule la soustraction (distance de Hamming) compte pour la fonction testée.

Usage :
    ml/.venv/Scripts/python ml/data/test_dedup.py
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from dedup import grouper_par_similarite  # noqa: E402


class HashSynthetique:
    """Remplace imagehash.ImageHash : seule `a - b` (distance de Hamming) est utilisée."""

    def __init__(self, valeur: int) -> None:
        self.valeur = valeur

    def __sub__(self, autre: "HashSynthetique") -> int:
        return abs(self.valeur - autre.valeur)


def test_regroupe_les_hashes_proches() -> None:
    hashes = {
        "a.jpg": HashSynthetique(0),
        "b.jpg": HashSynthetique(1),  # quasi-doublon de a (distance 1)
        "c.jpg": HashSynthetique(20),  # isolé
    }
    groupes = grouper_par_similarite(hashes, seuil=4)
    assert groupes == [["a.jpg", "b.jpg"]], groupes


def test_aucun_groupe_sans_doublon() -> None:
    hashes = {"a.jpg": HashSynthetique(0), "b.jpg": HashSynthetique(50)}
    assert grouper_par_similarite(hashes, seuil=4) == []


def test_chaque_fichier_dans_un_seul_groupe() -> None:
    hashes = {
        "a.jpg": HashSynthetique(0),
        "b.jpg": HashSynthetique(1),
        "c.jpg": HashSynthetique(2),
    }
    groupes = grouper_par_similarite(hashes, seuil=4)
    vus = [fichier for groupe in groupes for fichier in groupe]
    assert sorted(vus) == sorted(set(vus)), "un fichier apparaît dans plusieurs groupes"
    assert groupes == [["a.jpg", "b.jpg", "c.jpg"]], groupes


def main() -> int:
    tests = [
        test_regroupe_les_hashes_proches,
        test_aucun_groupe_sans_doublon,
        test_chaque_fichier_dans_un_seul_groupe,
    ]
    for test in tests:
        test()
        print(f"ok  {test.__name__}")
    print(f"\n{len(tests)} test(s) réussi(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
