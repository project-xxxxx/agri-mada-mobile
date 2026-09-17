"""
Endpoints de l'agent de conseil (ADR-012).

- POST /agent/message : répond à une question en s'appuyant sur les fiches,
  les parcelles et les scans du compte connecté, dans une conversation dont
  l'application renvoie l'historique signé.
- DELETE /agent/traces : efface toutes les traces conservées pour le compte.

Ordre des contrôles : une urgence de santé humaine est servie avant tout le
reste (coupe-circuit, consentement, quota) puisqu'elle n'appelle pas Gemini.
"""

import logging
import threading
import time
from datetime import date, timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.agent.garde_fous import masquer_donnees_personnelles
from app.agent.historique import Echange, HistoriqueInvalide, maintenant, signer, verifier
from app.agent.orchestrateur import AgentAgriMada, ReponseAgent, prefiltrer
from app.api.endpoints import conseil
from app.core.config import settings
from app.crud import (
    consommer_quota_conseil,
    enregistrer_trace_agent,
    purger_traces_agent,
    rendre_quota_conseil,
    supprimer_traces_agent,
)
from app.db.session import get_db
from app.deps import get_current_user
from app.models.refresh_token import utcnow_naive
from app.models.user import User
from app.rag.gemini import ErreurFournisseur
from app.schemas.agent import AgentMessage, AgentReponse, EchangeSigne

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/agent", tags=["Agent de conseil"])

_agent: AgentAgriMada | None = None
_verrou_agent = threading.Lock()
_derniere_purge: date | None = None


def get_agent() -> AgentAgriMada | None:
    """None quand l'agent est coupé ou non configuré : seules les urgences sont alors servies."""
    global _agent
    if not settings.AGENT_ACTIF or not settings.GEMINI_API_KEY:
        return None
    with _verrou_agent:
        if _agent is None:
            try:
                moteur = conseil.get_moteur_conseil()
            except HTTPException:
                return None
            _agent = AgentAgriMada(
                moteur.client,
                moteur.index,
                top_k=settings.RAG_TOP_K,
                seuil=settings.RAG_SEUIL_SIMILARITE,
                max_appels_outils=settings.AGENT_MAX_APPELS_OUTILS,
                max_jetons_entree=settings.AGENT_MAX_JETONS_ENTREE,
            )
    return _agent


def _purger_une_fois_par_jour(db: Session) -> None:
    global _derniere_purge
    aujourd_hui = date.today()
    if _derniere_purge == aujourd_hui:
        return
    _derniere_purge = aujourd_hui
    supprimees = purger_traces_agent(
        db, utcnow_naive() - timedelta(days=settings.AGENT_CONSERVATION_JOURS)
    )
    if supprimees:
        logger.info("Agent : %d trace(s) purgée(s)", supprimees)


def _historique_verifie(demande: AgentMessage, user_id: int) -> tuple[list[Echange], int]:
    try:
        return verifier(
            settings.SECRET_KEY,
            user_id=user_id,
            conversation_id=demande.conversation_id,
            echanges=[
                (Echange(e.question, e.reponse, e.emis_le), e.signature)
                for e in demande.historique
            ],
            validite=timedelta(hours=settings.AGENT_HISTORIQUE_VALIDITE_HEURES),
        )
    except HistoriqueInvalide:
        logger.warning("Agent : historique refusé pour le compte %s", user_id)
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Historique de conversation invalide : recommencez une nouvelle conversation.",
        )


@router.post(
    "/message",
    response_model=AgentReponse,
    summary="Poser une question à l'agent de conseil",
    description=(
        "L'agent consulte les fiches, les parcelles et les scans du compte connecté. "
        "Aucune réponse ne cite de produit ni de dose, aucune ne présente une piste de scan "
        "comme un diagnostic. `consentement_conservation` est obligatoire : les échanges sont "
        f"conservés {settings.AGENT_CONSERVATION_JOURS} jours et traités par Google (Gemini)."
    ),
    responses={
        403: {"description": "Consentement à la conservation non donné"},
        422: {"description": "Question ou historique invalide"},
        429: {"description": "Quota de questions du jour atteint"},
        503: {"description": "Agent coupé, non configuré ou fournisseur indisponible"},
    },
)
def envoyer_message(
    demande: AgentMessage,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    agent: AgentAgriMada | None = Depends(get_agent),
):
    debut = time.perf_counter()
    question, masquee = masquer_donnees_personnelles(demande.question)

    reponse: ReponseAgent | None = prefiltrer(question, demande.langue)
    urgence = reponse is not None and reponse.issue == "urgence_sante"
    historique: list[Echange] = []
    expires = 0
    if not urgence:
        if agent is None:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="L'agent de conseil est momentanément indisponible.",
            )
        if not demande.consentement_conservation:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Acceptez la conservation des échanges pour utiliser l'agent.",
            )
        historique, expires = _historique_verifie(demande, current_user.id)

    restantes = None
    if reponse is None:
        jour = conseil.jour_madagascar()
        restantes = consommer_quota_conseil(db, current_user.id, jour, settings.RAG_QUOTA_JOUR)
        if restantes is None:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=f"Quota de {settings.RAG_QUOTA_JOUR} questions par jour atteint. Réessayez demain.",
            )
        try:
            reponse = agent.repondre(
                question=question,
                langue=demande.langue,
                historique=historique,
                boite=agent.boite(db, current_user.id, demande.langue),
            )
        except ErreurFournisseur as erreur:
            rendre_quota_conseil(db, current_user.id, jour)
            logger.warning("Agent : fournisseur indisponible (%s)", erreur)
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="L'agent de conseil est momentanément indisponible. Réessayez plus tard.",
            )

    if masquee:
        reponse.garde_fous.append("donnees_personnelles_masquees")
    if expires:
        reponse.garde_fous.append("historique_expire")
    if reponse.garde_fous:
        logger.info("Agent : garde-fous %s, issue %s", reponse.garde_fous, reponse.issue)

    echange = Echange(question=question, reponse=reponse.reponse, emis_le=maintenant())
    signature = signer(
        settings.SECRET_KEY,
        user_id=current_user.id,
        conversation_id=demande.conversation_id,
        echange=echange,
    )

    if demande.consentement_conservation:
        _purger_une_fois_par_jour(db)
        enregistrer_trace_agent(
            db,
            user_id=current_user.id,
            conversation_id=demande.conversation_id,
            langue=demande.langue,
            question=question,
            reponse=reponse.reponse,
            issue=reponse.issue,
            outils=reponse.outils,
            garde_fous=reponse.garde_fous,
            fiches=[fiche.id for fiche in reponse.fiches],
            sessions=reponse.sessions,
            orienter_technicien=reponse.orienter_technicien,
            jetons_entree=reponse.jetons_entree,
            jetons_sortie=reponse.jetons_sortie,
            duree_ms=int((time.perf_counter() - debut) * 1000),
            modele=settings.RAG_MODELE_GENERATION if reponse.appel_modele else None,
        )

    return AgentReponse(
        issue=reponse.issue,
        reponse=reponse.reponse,
        fiches=[
            {
                "id": fiche.id,
                "nom_fr": fiche.nom_fr,
                "nom_mg": fiche.nom_mg,
                "statut_validation": fiche.statut_validation,
            }
            for fiche in reponse.fiches
        ],
        sessions_consultees=reponse.sessions,
        avertissements=[{"code": a.code, "message": a.message} for a in reponse.avertissements],
        orienter_technicien=reponse.orienter_technicien,
        motifs_technicien=reponse.motifs_technicien,
        echange=EchangeSigne(
            question=echange.question,
            reponse=echange.reponse,
            emis_le=echange.emis_le,
            signature=signature,
        ),
        questions_restantes=restantes,
    )


@router.delete(
    "/traces",
    summary="Effacer mes échanges conservés",
    description="Supprime toutes les questions et réponses conservées pour le compte connecté.",
)
def effacer_mes_traces(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return {"supprimees": supprimer_traces_agent(db, current_user.id)}
