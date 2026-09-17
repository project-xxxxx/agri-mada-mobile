#!/usr/bin/env python3
"""Construit l'index vectoriel des fiches pour le conseil (tâche P5.4, ADR-011).

Découpe knowledge/fiches/*.json en extraits, les vectorise avec l'API Gemini et
écrit app/rag/index_fiches.json. À relancer après toute modification des
fiches : tests/test_rag.py échoue tant que l'index ne leur correspond plus.

Usage (depuis backend/, GEMINI_API_KEY dans backend/.env) :
    venv/Scripts/python scripts/build_rag_index.py
"""

from __future__ import annotations

import json
import sys
import time
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BACKEND_DIR))

FICHES_DIR = BACKEND_DIR.parent / "knowledge" / "fiches"
TAILLE_LOT = 50


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    from app.core.config import settings
    from app.rag.decoupage import decouper_fiches, empreinte_fiches
    from app.rag.gemini import CODES_A_REESSAYER, ClientGemini, ErreurFournisseur
    from app.rag.index import CHEMIN_INDEX, serialiser_index

    if not settings.GEMINI_API_KEY:
        sys.exit("GEMINI_API_KEY absente de backend/.env : impossible de vectoriser les fiches.")

    fiches = [json.loads(p.read_text(encoding="utf-8")) for p in sorted(FICHES_DIR.glob("*.json"))]
    if not fiches:
        sys.exit(f"Aucune fiche dans {FICHES_DIR}")
    extraits = decouper_fiches(fiches)
    print(f"{len(fiches)} fiches découpées en {len(extraits)} extraits.")

    client = ClientGemini(
        cle_api=settings.GEMINI_API_KEY,
        modele_generation=settings.RAG_MODELE_GENERATION,
        modele_embedding=settings.RAG_MODELE_EMBEDDING,
        dimensions=settings.RAG_DIMENSIONS,
        delai_secondes=settings.RAG_DELAI_SECONDES,
        max_jetons_reponse=settings.RAG_MAX_JETONS_REPONSE,
    )

    vecteurs: list[list[float]] = []
    for debut in range(0, len(extraits), TAILLE_LOT):
        lot = extraits[debut : debut + TAILLE_LOT]
        for tentative in range(5):
            try:
                vecteurs += client.vectoriser([e.texte for e in lot], type_tache="document")
                break
            except ErreurFournisseur as erreur:
                if erreur.code not in CODES_A_REESSAYER or tentative == 4:
                    sys.exit(f"Échec de la vectorisation : {erreur}")
                attente = 10 * 2**tentative
                print(f"  {erreur} — nouvel essai dans {attente} s")
                time.sleep(attente)
        print(f"  {len(vecteurs)}/{len(extraits)} extraits vectorisés")

    index = serialiser_index(
        modele_embedding=settings.RAG_MODELE_EMBEDDING,
        dimensions=settings.RAG_DIMENSIONS,
        empreinte=empreinte_fiches(fiches),
        fiches=fiches,
        extraits=extraits,
        vecteurs=vecteurs,
    )
    CHEMIN_INDEX.write_text(json.dumps(index, ensure_ascii=False) + "\n", encoding="utf-8")
    taille_ko = CHEMIN_INDEX.stat().st_size // 1024
    print(f"Index écrit : {CHEMIN_INDEX.relative_to(BACKEND_DIR).as_posix()} ({taille_ko} Ko, {settings.RAG_MODELE_EMBEDDING}, {settings.RAG_DIMENSIONS} dimensions)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
