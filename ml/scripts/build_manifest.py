#!/usr/bin/env python3
"""Construit ml/data/manifest.csv, le manifeste versionné des données (tâche P3.6).

Colonnes : id, sha256, source, licence, organe, classe, site, date, annotateur,
split. `organe` est déduit de `classe` (id de taxonomie) via ml/taxonomy_v1.yaml.

Deux granularités, selon que les images d'un jeu sont déjà extraites ou non :

- **Fichiers déjà extraits** (ex. dhan_shomadhan, ml/data/raw/hors_sujet/,
  ml/data/raw/negatifs_v1/) : une ligne par image, avec son vrai SHA-256.
- **Jeux encore en archive** (les autres jeux publics) : une ligne par (jeu,
  classe brute), avec le SHA-256 de l'archive entière (celui de
  downloads.csv) et une colonne `images` indiquant combien d'images cette
  ligne représente. L'extraction réelle et le hash par image sont laissés à
  P4.1 (ml/prepare_data.py) : ce manifeste sert la traçabilité et la
  répartition entraînement/validation/test par jeu, pas encore le
  dédoublonnage image par image (voir ml/data/dedup.py, séparé).

Usage :
    ml/.venv/Scripts/python ml/scripts/build_manifest.py
"""

from __future__ import annotations

import csv
import hashlib
import sys
from pathlib import Path, PurePosixPath

import yaml

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "ml" / "data" / "raw"
DOWNLOADS = RAW / "downloads.csv"
LABEL_MAP_REPORT = RAW / "label_map_report.csv"
TAXONOMY = ROOT / "ml" / "taxonomy_v1.yaml"
HORS_SUJET_CSV = ROOT / "ml" / "data" / "eval" / "hors_sujet.csv"
NEGATIFS_CSV = ROOT / "ml" / "data" / "eval" / "negatifs_v1.csv"
OUT = ROOT / "ml" / "data" / "manifest.csv"

FIELDS = ["id", "sha256", "source", "licence", "organe", "classe", "site", "date", "annotateur", "split", "images"]
IMAGE_EXT = (".jpg", ".jpeg", ".png", ".bmp", ".webp")

# Jeux dont les images sont déjà extraites en fichiers (pas en archive).
JEUX_EXTRAITS = {"dhan_shomadhan"}


def charger_organe_par_id() -> dict[str, str]:
    with TAXONOMY.open(encoding="utf-8") as handle:
        taxonomie = yaml.safe_load(handle)
    organe_par_id: dict[str, str] = {}
    for entree in taxonomie.get("porte", []):
        organe_par_id[entree["id"]] = "porte"
    for organe, problemes in taxonomie.get("problemes", {}).items():
        for entree in problemes:
            organe_par_id[entree["id"]] = organe
    return organe_par_id


def classe_of(chemin_relatif: str) -> str:
    """Reprend la règle de inventory_raw.py : les deux derniers dossiers du chemin."""
    parents = PurePosixPath(chemin_relatif).parts[:-1]
    return "/".join(parents[-2:]) or "(racine)"


def charger_licences() -> dict[str, str]:
    licences: dict[str, str] = {}
    if not DOWNLOADS.exists():
        return licences
    with DOWNLOADS.open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            licences.setdefault(row["id"], row.get("licence", ""))
    return licences


def charger_archives_sha256() -> dict[str, str]:
    """id du jeu -> sha256 de son archive, depuis downloads.csv."""
    archives: dict[str, str] = {}
    if not DOWNLOADS.exists():
        return archives
    with DOWNLOADS.open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            if row.get("statut") not in ("telecharge", "telecharge_ou_present") or not row.get("sha256"):
                continue
            archives.setdefault(row["id"], row["sha256"])
    return archives


def lignes_jeux_en_archive(organe_par_id: dict[str, str], licences: dict[str, str]) -> list[dict]:
    if not LABEL_MAP_REPORT.exists():
        sys.exit(
            f"{LABEL_MAP_REPORT.relative_to(ROOT).as_posix()} introuvable : "
            "lancer d'abord ml/scripts/apply_label_map.py"
        )
    archives_sha256 = charger_archives_sha256()
    lignes: list[dict] = []
    with LABEL_MAP_REPORT.open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            jeu = row["jeu"]
            if jeu in JEUX_EXTRAITS:
                continue
            classe = row["id_taxonomie"]
            # Retrouve le fichier source exact via inventory.csv aurait été plus
            # précis, mais downloads.csv suffit : un seul fichier .zip/.7z par jeu
            # dans la grande majorité des cas (voir ml/DATASETS.md).
            sha256 = archives_sha256.get(jeu, "")
            organe = "exclu" if classe.startswith("exclu:") else organe_par_id.get(classe, "?")
            lignes.append(
                {
                    "id": f"{jeu}:{row['classe_brute']}",
                    "sha256": sha256,
                    "source": f"ml/data/raw/{jeu}/",
                    "licence": licences.get(jeu, ""),
                    "organe": organe,
                    "classe": classe,
                    "site": "",
                    "date": "",
                    "annotateur": "",
                    "split": "",
                    "images": row["images"],
                }
            )
    return lignes


def lignes_jeux_extraits(organe_par_id: dict[str, str], licences: dict[str, str]) -> list[dict]:
    if not LABEL_MAP_REPORT.exists():
        return []
    label_map: dict[tuple[str, str], str] = {}
    with LABEL_MAP_REPORT.open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            if row["jeu"] in JEUX_EXTRAITS:
                label_map[(row["jeu"], row["classe_brute"])] = row["id_taxonomie"]

    lignes: list[dict] = []
    for jeu in sorted(JEUX_EXTRAITS):
        dossier = RAW / jeu
        if not dossier.is_dir():
            continue
        for chemin in sorted(dossier.rglob("*")):
            if not chemin.is_file() or chemin.suffix.lower() not in IMAGE_EXT:
                continue
            relatif = chemin.relative_to(dossier).as_posix()
            classe_brute = classe_of(relatif)
            classe = label_map.get((jeu, classe_brute), "")
            if not classe:
                continue
            organe = "exclu" if classe.startswith("exclu:") else organe_par_id.get(classe, "?")
            lignes.append(
                {
                    "id": chemin.relative_to(ROOT).as_posix(),
                    "sha256": hashlib.sha256(chemin.read_bytes()).hexdigest(),
                    "source": chemin.relative_to(ROOT).as_posix(),
                    "licence": licences.get(jeu, ""),
                    "organe": organe,
                    "classe": classe,
                    "site": "",
                    "date": "",
                    "annotateur": "",
                    "split": "",
                    "images": "1",
                }
            )
    return lignes


def lignes_hors_sujet_et_negatifs() -> list[dict]:
    lignes: list[dict] = []
    for chemin_csv, source_libelle in ((HORS_SUJET_CSV, "hors_sujet"), (NEGATIFS_CSV, "negatifs_v1")):
        if not chemin_csv.exists():
            continue
        reprises = 0
        with chemin_csv.open(newline="", encoding="utf-8") as handle:
            for row in csv.DictReader(handle):
                reprises += 1
                lignes.append(
                    {
                        "id": row["fichier"],
                        "sha256": row["sha256"],
                        "source": row["fichier"],
                        "licence": row.get("licence", ""),
                        "organe": "porte",
                        "classe": "pas_riz",
                        "site": "",
                        "date": "",
                        "annotateur": "",
                        "split": "",
                        "images": "1",
                    }
                )
        print(f"{source_libelle} : {reprises} ligne(s) reprise(s)")
    return lignes


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    organe_par_id = charger_organe_par_id()
    licences = charger_licences()

    lignes = (
        lignes_jeux_en_archive(organe_par_id, licences)
        + lignes_jeux_extraits(organe_par_id, licences)
        + lignes_hors_sujet_et_negatifs()
    )

    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(lignes)

    total_images = sum(int(ligne["images"]) for ligne in lignes)
    print(f"{len(lignes)} ligne(s) de manifeste, {total_images} image(s) au total.")
    print(f"Écrit dans {OUT.relative_to(ROOT).as_posix()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
