#!/usr/bin/env python3
"""Extrait les archives des jeux publics vers un disque avec plus d'espace libre.

Le dépôt (C:) n'a que 14 Go libres pour 8,2 Go d'archives déjà téléchargées
dans ml/data/raw/ : ce script les décompresse sur un autre disque (D: par
défaut) plutôt que sur place, pour préparer l'entraînement (P4, hors plan P3).

Usage :
    ml/.venv/Scripts/python ml/scripts/extract_datasets.py
    ml/.venv/Scripts/python ml/scripts/extract_datasets.py --data-root E:/agrimada-ml
"""

from __future__ import annotations

import argparse
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "ml" / "data" / "raw"

# (id du jeu, chemin de l'archive relatif à ml/data/raw/)
ARCHIVES: list[tuple[str, str]] = [
    ("mendeley_hx6f852hw4", "mendeley_hx6f852hw4/Original/Original Images.zip"),
    ("riceleafbd", "riceleafbd/Original Images.zip"),
    ("hf_rice_disease", "hf_rice_disease/rename.zip"),
    ("paddy_doctor", "paddy_doctor/paddy-disease-classification.zip"),
    ("nutrient_deficiency_rice", "nutrient_deficiency_rice/nutrientdeficiencysymptomsinrice.zip"),
    ("sethy_5932", "sethy_5932/Rice Leaf Disease Images.7z"),
]

MARQUEUR = ".extrait_ok"


def extraire_zip(archive: Path, destination: Path) -> None:
    with zipfile.ZipFile(archive) as zf:
        zf.extractall(destination)


def extraire_7z(archive: Path, destination: Path) -> None:
    import py7zr

    with py7zr.SevenZipFile(archive) as sz:
        sz.extractall(destination)


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--data-root",
        type=Path,
        default=Path("D:/agrimada-ml"),
        help="disque/dossier de destination (défaut D:/agrimada-ml)",
    )
    args = parser.parse_args()

    destination_racine = args.data_root / "raw"
    destination_racine.mkdir(parents=True, exist_ok=True)

    for dataset_id, chemin_archive in ARCHIVES:
        archive = RAW / chemin_archive
        destination = destination_racine / dataset_id
        marqueur = destination / MARQUEUR

        if not archive.exists():
            print(f"[ignoré] {dataset_id} : archive introuvable ({archive})")
            continue
        if marqueur.exists():
            print(f"[déjà fait] {dataset_id} -> {destination}")
            continue

        print(f"[extraction] {dataset_id} : {archive.name} -> {destination}")
        destination.mkdir(parents=True, exist_ok=True)
        if archive.suffix.lower() == ".zip":
            extraire_zip(archive, destination)
        elif archive.suffix.lower() == ".7z":
            extraire_7z(archive, destination)
        else:
            print(f"[ignoré] {dataset_id} : format non géré ({archive.suffix})")
            continue
        marqueur.write_text("ok", encoding="utf-8")
        print(f"[ok] {dataset_id}")

    print(f"\nDonnées extraites sous {destination_racine}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
