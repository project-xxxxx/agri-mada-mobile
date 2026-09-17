"""
Endpoint du conseil à partir des fiches de connaissance (tâche P5.4, ADR-011).

- POST /conseil/question : répond à une question à partir des fiches, jamais
  au-delà ; renvoie vers un technicien quand les fiches ne répondent pas.

Réservé aux comptes connectés et plafonné par jour : chaque question est
facturée par l'API Gemini.
"""

import logging
import threading
from dataclasses import asdict
from datetime import date, datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.config import settings
from app.crud import consommer_quota_conseil, rendre_quota_conseil
from app.db.session import get_db
from app.deps import get_current_user
from app.models.user import User
from app.rag.gemini import ClientGemini, ErreurFournisseur
from app.rag.index import IndexFiches
from app.rag.moteur import MoteurConseil
from app.schemas.conseil import ConseilQuestion, ConseilReponse

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/conseil", tags=["Conseil (fiches)"])

# Madagascar n'a pas d'heure d'été : le quota repart à minuit, heure locale.
_FUSEAU_MADAGASCAR = timezone(timedelta(hours=3))

_moteur: MoteurConseil | None = None
_verrou_moteur = threading.Lock()


def _indisponible() -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        detail="Le conseil est momentanément indisponible. Réessayez plus tard.",
    )


def jour_madagascar() -> date:
    return datetime.now(_FUSEAU_MADAGASCAR).date()


def get_moteur_conseil() -> MoteurConseil:
    """Construit le moteur une seule fois : l'index est lu depuis le disque au premier appel."""
    global _moteur
    if not settings.GEMINI_API_KEY:
        raise _indisponible()
    with _verrou_moteur:
        if _moteur is None:
            try:
                index = IndexFiches.charger()
            except FileNotFoundError:
                logger.error("Index des fiches absent : lancer scripts/build_rag_index.py")
                raise _indisponible()
            if index.modele_embedding != settings.RAG_MODELE_EMBEDDING:
                # Des vecteurs de modèles différents ne sont pas comparables entre eux.
                logger.error(
                    "Index construit avec %s mais RAG_MODELE_EMBEDDING=%s : reconstruire l'index",
                    index.modele_embedding,
                    settings.RAG_MODELE_EMBEDDING,
                )
                raise _indisponible()
            client = ClientGemini(
                cle_api=settings.GEMINI_API_KEY,
                modele_generation=settings.RAG_MODELE_GENERATION,
                modele_embedding=index.modele_embedding,
                dimensions=index.dimensions,
                delai_secondes=settings.RAG_DELAI_SECONDES,
                max_jetons_reponse=settings.RAG_MAX_JETONS_REPONSE,
            )
            _moteur = MoteurConseil(
                index, client, top_k=settings.RAG_TOP_K, seuil=settings.RAG_SEUIL_SIMILARITE
            )
    return _moteur


@router.post(
    "/question",
    response_model=ConseilReponse,
    summary="Poser une question aux fiches",
    description=(
        "Répond à partir des fiches de connaissance AgriMada uniquement. Aucune réponse "
        "ne cite de produit ni de dose. Les fiches sont en brouillon tant qu'un agronome "
        "ne les a pas validées : la réponse le signale dans `avertissements`."
    ),
    responses={
        429: {"description": "Quota de questions du jour atteint"},
        503: {"description": "Conseil non configuré ou fournisseur indisponible"},
    },
)
def poser_question(
    demande: ConseilQuestion,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    moteur: MoteurConseil = Depends(get_moteur_conseil),
):
    jour = jour_madagascar()
    restantes = consommer_quota_conseil(db, current_user.id, jour, settings.RAG_QUOTA_JOUR)
    if restantes is None:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Quota de {settings.RAG_QUOTA_JOUR} questions par jour atteint. Réessayez demain.",
        )

    try:
        reponse = moteur.repondre(demande.question, demande.langue)
    except ErreurFournisseur as erreur:
        rendre_quota_conseil(db, current_user.id, jour)
        logger.warning("Conseil : fournisseur indisponible (%s)", erreur)
        raise _indisponible()

    if reponse.filtre_securite:
        logger.info("Conseil : réponse remplacée par le filtre produits/doses")

    return ConseilReponse(
        trouve=reponse.trouve,
        reponse=reponse.reponse,
        fiches=[asdict(fiche) for fiche in reponse.fiches],
        avertissements=[asdict(avertissement) for avertissement in reponse.avertissements],
        questions_restantes=restantes,
    )
