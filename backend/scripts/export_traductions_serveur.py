#!/usr/bin/env python3
"""Exporte les messages malgaches fixés côté serveur pour relecture (ADR-011, ADR-012).

Pendant de tool/export_translation_review.dart, qui ne lit que les fichiers de
l'app : les réponses fixes du conseil et de l'agent (urgence de santé, refus,
hors fiches, repli) sont écrites dans le code du serveur et doivent être
relues par le même locuteur natif. Même format de tableau ; les statuts et
remarques déjà saisis sont conservés d'un export à l'autre.

Usage (depuis backend/) :
    venv/Scripts/python scripts/export_traductions_serveur.py
"""

from __future__ import annotations

import csv
import sys
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BACKEND_DIR))

SORTIE = BACKEND_DIR.parent / "docs" / "traductions" / "relecture-malgache-serveur.csv"
ENTETE = ["cle", "francais", "malagasy", "statut", "remarque"]


def messages_serveur() -> list[tuple[str, str, str]]:
    from app.agent.correspondances import NOM_PAR_ETIQUETTE
    from app.agent.garde_fous import MESSAGES_AGENT
    from app.rag.moteur import MESSAGES

    lignes = []
    for prefixe, source in (("conseil", MESSAGES), ("agent", MESSAGES_AGENT)):
        for code in dict.fromkeys([*source["fr"], *source["mg"]]):
            lignes.append((f"{prefixe}.{code}", source["fr"].get(code, ""), source["mg"].get(code, "")))
    for etiquette, noms in NOM_PAR_ETIQUETTE.items():
        lignes.append((f"etiquette.{etiquette}", noms["fr"], noms["mg"]))
    return lignes


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    precedent: dict[str, tuple[str, str]] = {}
    if SORTIE.exists():
        with SORTIE.open(encoding="utf-8-sig", newline="") as handle:
            for ligne in csv.DictReader(handle, delimiter=";"):
                precedent[ligne["cle"]] = (ligne["statut"], ligne["remarque"])

    lignes = messages_serveur()
    SORTIE.parent.mkdir(parents=True, exist_ok=True)
    with SORTIE.open("w", encoding="utf-8-sig", newline="") as handle:
        ecrivain = csv.writer(handle, delimiter=";", quoting=csv.QUOTE_ALL, lineterminator="\r\n")
        ecrivain.writerow(ENTETE)
        for cle, francais, malagasy in lignes:
            statut, remarque = precedent.get(
                cle, ("à relire" if malagasy else "traduction manquante", "")
            )
            ecrivain.writerow([cle, francais, malagasy, statut, remarque])

    manquantes = sum(1 for _, _, malagasy in lignes if not malagasy)
    print(f"{SORTIE.relative_to(BACKEND_DIR.parent).as_posix()} : {len(lignes)} messages, {manquantes} sans traduction malgache")
    return 0


if __name__ == "__main__":
    sys.exit(main())
