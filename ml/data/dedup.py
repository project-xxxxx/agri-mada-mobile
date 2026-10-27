"""Dédoublonnage par empreinte perceptuelle (tâche P3.6).

Calcule un hash perceptuel (phash) pour chaque image d'un dossier déjà extrait
et regroupe les quasi-doublons (distance de Hamming <= seuil). Ne touche pas
aux archives .zip/.7z encore compressées : l'extraction complète des jeux
publics est un traitement long, laissé à P4.1 (ml/prepare_data.py).

Usage :
    ml/.venv/Scripts/python ml/data/dedup.py <dossier_images> [--seuil 4]

Écrit ml/data/eval/doublons.csv (groupe, fichier, jeu).
"""

from __future__ import annotations

import argparse
import csv
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
IMAGE_EXT = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}
OUT = ROOT / "ml" / "data" / "eval" / "doublons.csv"


def grouper_par_similarite(hashes: dict[str, "object"], seuil: int = 4) -> list[list[str]]:
    """Regroupe les fichiers dont le hash perceptuel diffère d'au plus `seuil` bits.

    Fonction pure (pas d'I/O), testable avec des hashes synthétiques. Chaque
    fichier n'apparaît que dans un seul groupe (le premier auquel il matche).
    Les fichiers sans doublon ne sont pas inclus (groupes de taille 1 omis).
    """
    fichiers = list(hashes)
    deja_groupe: set[str] = set()
    groupes: list[list[str]] = []

    for i, fichier in enumerate(fichiers):
        if fichier in deja_groupe:
            continue
        groupe = [fichier]
        for autre in fichiers[i + 1 :]:
            if autre in deja_groupe:
                continue
            if (hashes[fichier] - hashes[autre]) <= seuil:
                groupe.append(autre)
                deja_groupe.add(autre)
        if len(groupe) > 1:
            deja_groupe.add(fichier)
            groupes.append(groupe)

    return groupes


def calculer_hashes(dossier: Path) -> dict[str, "object"]:
    import imagehash
    from PIL import Image

    hashes: dict[str, object] = {}
    for chemin in sorted(dossier.rglob("*")):
        if chemin.suffix.lower() not in IMAGE_EXT or not chemin.is_file():
            continue
        try:
            with Image.open(chemin) as image:
                hashes[chemin.resolve().relative_to(ROOT).as_posix()] = imagehash.phash(image)
        except Exception as erreur:  # image corrompue ou illisible
            print(f"  ignorée ({erreur}) : {chemin}")
    return hashes


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("dossier", type=Path, help="dossier d'images déjà extraites")
    parser.add_argument("--seuil", type=int, default=4, help="distance de Hamming max (défaut 4)")
    args = parser.parse_args()

    if not args.dossier.is_dir():
        sys.exit(f"dossier introuvable : {args.dossier}")

    hashes = calculer_hashes(args.dossier)
    print(f"{len(hashes)} image(s) hashée(s) dans {args.dossier}")

    groupes = grouper_par_similarite(hashes, seuil=args.seuil)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(["groupe", "fichier", "jeu"])
        for numero, groupe in enumerate(groupes, start=1):
            for fichier in groupe:
                jeu = Path(fichier).parts[3] if len(Path(fichier).parts) > 3 else "(inconnu)"
                writer.writerow([numero, fichier, jeu])

    total_doublons = sum(len(g) - 1 for g in groupes)
    print(f"{len(groupes)} groupe(s) de quasi-doublons, {total_doublons} image(s) à écarter avant découpage.")
    print(f"Détail : {OUT.relative_to(ROOT).as_posix()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
