#!/usr/bin/env python3
"""Ajoute la classe pas_riz (porte) au jeu d'entraînement feuille.

Copie ml/data/raw/negatifs_v1/ (ml/scripts/fetch_negatives.py) dans
<data-root>/prepared/feuille/pas_riz/, au même format que
prepare_training_data.py, pour que train_feuille.py la traite comme une
classe de plus. Voir ml/reports/entrainement_feuille_2026-09-17.md : sans
cette classe, le classifieur force toujours une réponse confiante, même sur
une photo hors sujet.

Usage :
    ml/.venv/Scripts/python ml/scripts/add_negative_class.py
"""

from __future__ import annotations

import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
NEGATIFS_DIR = ROOT / "ml" / "data" / "raw" / "negatifs_v1"
IMAGE_EXT = (".jpg", ".jpeg", ".png")


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    import argparse

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data-root", type=Path, default=Path("D:/agrimada-ml"))
    args = parser.parse_args()

    if not NEGATIFS_DIR.is_dir():
        sys.exit(f"{NEGATIFS_DIR} introuvable : lancer d'abord ml/scripts/fetch_negatives.py")

    destination = args.data_root / "prepared" / "feuille" / "pas_riz"
    destination.mkdir(parents=True, exist_ok=True)

    copiees = 0
    for chemin in sorted(NEGATIFS_DIR.rglob("*")):
        if not chemin.is_file() or chemin.suffix.lower() not in IMAGE_EXT:
            continue
        nom_fichier = f"negatifs_v1_{chemin.parent.name}_{chemin.stem}{chemin.suffix.lower()}"
        shutil.copyfile(chemin, destination / nom_fichier)
        copiees += 1

    print(f"{copiees} image(s) copiée(s) vers {destination}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
