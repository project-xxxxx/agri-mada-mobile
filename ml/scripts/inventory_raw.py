#!/usr/bin/env python3
"""Inventaire des images téléchargées dans ml/data/raw/.

Compte les images par jeu et par dossier de classe, sans rien extraire : lit le contenu
des archives .zip et .7z, et parcourt les dossiers d'images déjà présents.

Usage :
    python ml/scripts/inventory_raw.py

Écrit ml/data/raw/inventory.csv (jeu, source, classe, images).
"""

from __future__ import annotations

import collections
import csv
import sys
import zipfile
from pathlib import PurePosixPath, Path

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "ml" / "data" / "raw"
OUT = RAW / "inventory.csv"
IMAGE_EXT = (".jpg", ".jpeg", ".png", ".bmp", ".webp", ".tif", ".tiff")


def class_of(member: str) -> str:
    """Nom de classe : les deux derniers dossiers du chemin de l'image."""
    parents = PurePosixPath(member.replace("\\", "/")).parts[:-1]
    return "/".join(parents[-2:]) or "(racine)"


def archive_members(path: Path) -> list[str]:
    if path.suffix.lower() == ".zip":
        with zipfile.ZipFile(path) as archive:
            return [n for n in archive.namelist() if not n.endswith("/")]
    if path.suffix.lower() == ".7z":
        try:
            import py7zr
        except ImportError:
            sys.exit("py7zr est requis pour lire les archives .7z : pip install py7zr")
        with py7zr.SevenZipFile(path) as archive:
            return archive.getnames()
    return []


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    rows = []
    for dataset_dir in sorted(p for p in RAW.iterdir() if p.is_dir()):
        loose = collections.Counter()
        for path in sorted(dataset_dir.rglob("*")):
            if not path.is_file() or ".cache" in path.parts:
                continue
            if path.suffix.lower() in (".zip", ".7z"):
                counts = collections.Counter(
                    class_of(m) for m in archive_members(path) if m.lower().endswith(IMAGE_EXT))
                source = path.relative_to(dataset_dir).as_posix()
                rows += [[dataset_dir.name, source, cls, n] for cls, n in sorted(counts.items())]
            elif path.suffix.lower() in IMAGE_EXT:
                loose[class_of(path.relative_to(dataset_dir).as_posix())] += 1
        rows += [[dataset_dir.name, "(fichiers)", cls, n] for cls, n in sorted(loose.items())]

    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["jeu", "source", "classe", "images"])
        writer.writerows(rows)

    totals = collections.Counter()
    for dataset, _, _, n in rows:
        totals[dataset] += n
    for dataset, n in sorted(totals.items()):
        print(f"{dataset:<24} {n:>7} images")
        for row in rows:
            if row[0] == dataset:
                print(f"    {row[3]:>6}  {row[2]}")
    print(f"\nTotal : {sum(totals.values())} images. Détail : {OUT.relative_to(ROOT).as_posix()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
