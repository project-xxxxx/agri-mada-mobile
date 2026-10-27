#!/usr/bin/env python3
"""Applique ml/label_map.yaml à l'inventaire des jeux publics (tâche P3.2).

Lit ml/data/raw/inventory.csv (produit par inventory_raw.py) et
ml/label_map.yaml, et écrit ml/data/raw/label_map_report.csv avec, pour chaque
classe brute rencontrée : le jeu, la classe brute, l'id de taxonomie retenu
(ou `exclu:*` / `sans_etiquette`), et le nombre d'images.

Échoue (code de sortie 1) si une classe brute de inventory.csv n'a pas de
correspondance dans label_map.yaml, pour ne rien oublier en silence. Les jeux
listés dans `hors_perimetre` (ex. les masques de segmentation) sont ignorés.

Usage :
    ml/.venv/Scripts/python ml/scripts/apply_label_map.py
"""

from __future__ import annotations

import csv
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[2]
INVENTORY = ROOT / "ml" / "data" / "raw" / "inventory.csv"
LABEL_MAP = ROOT / "ml" / "label_map.yaml"
REPORT = ROOT / "ml" / "data" / "raw" / "label_map_report.csv"


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    with LABEL_MAP.open(encoding="utf-8") as handle:
        label_map = yaml.safe_load(handle)
    datasets = label_map.get("datasets", {})
    hors_perimetre = set(label_map.get("hors_perimetre", {}))

    if not INVENTORY.exists():
        sys.exit(
            f"{INVENTORY.relative_to(ROOT).as_posix()} introuvable : "
            "lancer d'abord ml/scripts/inventory_raw.py"
        )

    rows_out: list[dict] = []
    manquantes: list[tuple[str, str]] = []

    with INVENTORY.open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            jeu, classe, images = row["jeu"], row["classe"], row["images"]
            if jeu in hors_perimetre:
                continue
            correspondance = datasets.get(jeu, {}).get(classe)
            if correspondance is None:
                manquantes.append((jeu, classe))
                continue
            rows_out.append(
                {
                    "jeu": jeu,
                    "classe_brute": classe,
                    "id_taxonomie": correspondance,
                    "images": images,
                }
            )

    if manquantes:
        print("Classes brutes sans correspondance dans ml/label_map.yaml :")
        for jeu, classe in manquantes:
            print(f"  - {jeu}: {classe!r}")
        print(
            f"\n{len(manquantes)} classe(s) manquante(s). "
            "Complète ml/label_map.yaml avant de relancer."
        )
        return 1

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    with REPORT.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=["jeu", "classe_brute", "id_taxonomie", "images"])
        writer.writeheader()
        writer.writerows(rows_out)

    totals: dict[str, int] = {}
    for row in rows_out:
        totals[row["id_taxonomie"]] = totals.get(row["id_taxonomie"], 0) + int(row["images"])

    print(f"{len(rows_out)} classe(s) brute(s) mappée(s), {sum(totals.values())} images au total.")
    for id_taxonomie, n in sorted(totals.items(), key=lambda kv: -kv[1]):
        print(f"  {n:>6}  {id_taxonomie}")
    print(f"\nRapport écrit dans {REPORT.relative_to(ROOT).as_posix()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
