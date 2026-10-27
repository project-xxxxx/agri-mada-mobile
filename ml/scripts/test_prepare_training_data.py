"""Tests de prepare_training_data.py::deduper_avant_decoupage (dédoublonnage
avant découpage train/val, voir la note en tête de prepare_training_data.py).

Comme ml/data/test_dedup.py : pas de dépendance à pytest. Contrairement à
test_dedup.py (hash synthétique), ce fichier exerce le vrai calcul de hash
perceptuel (Pillow + imagehash) et la vraie suppression de fichiers, sur une
poignée d'images minuscules écrites dans un dossier temporaire — c'est la
partie qui supprime réellement des fichiers, donc la plus utile à vérifier
avant de s'en servir sur de vraies données.

Usage :
    ml/.venv/Scripts/python ml/scripts/test_prepare_training_data.py
"""

from __future__ import annotations

import contextlib
import io
import sys
import tempfile
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))

from prepare_training_data import deduper_avant_decoupage, nettoyer_en_preservant_la_porte  # noqa: E402

try:
    from PIL import Image
except ImportError:  # pragma: no cover
    sys.exit("Pillow requis pour ces tests (voir ml/requirements.txt).")


def _ecrire_image(chemin: Path, seed: int) -> None:
    chemin.parent.mkdir(parents=True, exist_ok=True)
    pixels = np.random.default_rng(seed).integers(0, 256, size=(64, 64, 3), dtype=np.uint8)
    Image.fromarray(pixels).save(chemin, format="PNG")


def test_supprime_les_quasi_doublons_de_meme_classe() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        racine = Path(tmp)
        _ecrire_image(racine / "classeA" / "img1.png", seed=1)
        # copie octet pour octet -> distance de Hamming 0, garanti sous le seuil
        (racine / "classeA" / "img2.png").write_bytes((racine / "classeA" / "img1.png").read_bytes())
        _ecrire_image(racine / "classeA" / "img3.png", seed=999)  # bruit différent -> hash très différent

        deduper_avant_decoupage(racine, seuil=4)

        fichiers_restants = sorted(p.name for p in (racine / "classeA").iterdir())
        assert len(fichiers_restants) == 2, f"un des deux quasi-doublons aurait dû être retiré : {fichiers_restants}"
        assert "img3.png" in fichiers_restants, "l'image distincte ne doit pas être touchée"


def test_ne_supprime_rien_si_le_groupe_traverse_plusieurs_classes() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        racine = Path(tmp)
        _ecrire_image(racine / "classeA" / "img1.png", seed=7)
        (racine / "classeB" / "img2.png").parent.mkdir(parents=True, exist_ok=True)
        (racine / "classeB" / "img2.png").write_bytes((racine / "classeA" / "img1.png").read_bytes())

        sortie = io.StringIO()
        with contextlib.redirect_stdout(sortie):
            deduper_avant_decoupage(racine, seuil=4)

        assert (racine / "classeA" / "img1.png").exists()
        assert (racine / "classeB" / "img2.png").exists(), "un conflit inter-classes ne doit jamais être résolu automatiquement"
        assert "PLUSIEURS CLASSES" in sortie.getvalue()


def test_preserve_la_classe_porte_a_travers_la_reconstruction() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        racine = Path(tmp) / "prepared" / "feuille"
        _ecrire_image(racine / "pas_riz" / "negatif_001.png", seed=1)
        _ecrire_image(racine / "pas_riz" / "negatif_002.png", seed=2)
        _ecrire_image(racine / "blb" / "ancien_001.png", seed=3)  # sera recopié par la boucle appelante

        organe_par_id = {"pas_riz": "porte", "blb": "feuille"}
        nettoyer_en_preservant_la_porte(racine, organe_par_id)

        classes_restantes = sorted(p.name for p in racine.iterdir())
        assert classes_restantes == ["pas_riz"], "seule la classe porte doit survivre à la reconstruction"
        fichiers_pas_riz = sorted(p.name for p in (racine / "pas_riz").iterdir())
        assert fichiers_pas_riz == ["negatif_001.png", "negatif_002.png"], "toutes les images de la porte doivent être conservées"


def test_reconstruction_sans_dossier_existant_ne_plante_pas() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        racine = Path(tmp) / "prepared" / "feuille"
        assert not racine.exists()
        nettoyer_en_preservant_la_porte(racine, {})
        assert racine.is_dir()
        assert list(racine.iterdir()) == []


def test_seuil_zero_desactive_le_dedoublonnage() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        racine = Path(tmp)
        _ecrire_image(racine / "classeA" / "img1.png", seed=1)
        (racine / "classeA" / "img2.png").write_bytes((racine / "classeA" / "img1.png").read_bytes())

        deduper_avant_decoupage(racine, seuil=0)

        assert len(list((racine / "classeA").iterdir())) == 2


def main() -> int:
    tests = [
        test_supprime_les_quasi_doublons_de_meme_classe,
        test_ne_supprime_rien_si_le_groupe_traverse_plusieurs_classes,
        test_preserve_la_classe_porte_a_travers_la_reconstruction,
        test_reconstruction_sans_dossier_existant_ne_plante_pas,
        test_seuil_zero_desactive_le_dedoublonnage,
    ]
    for test in tests:
        test()
        print(f"ok  {test.__name__}")
    print(f"\n{len(tests)} test(s) réussi(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
