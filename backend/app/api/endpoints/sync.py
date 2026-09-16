"""
Endpoints de synchronisation.
Reçoit les données créées hors-ligne par l'application Flutter
et les sauvegarde dans la base PostgreSQL du serveur.

Les renvois sont sans danger : un élément portant un client_uuid déjà reçu
n'est pas dupliqué (tâche P1.9).

- POST /parcelles : Synchroniser les parcelles créées hors-ligne
- POST /diagnostics : Synchroniser les diagnostics créés hors-ligne
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.deps import get_current_user
from app.models.user import User
from app.schemas.parcelle import ParcelleSync, ParcelleSyncResponse
from app.schemas.diagnostic import DiagnosticSync, DiagnosticSyncResponse
from app.schemas.diagnostic_session import SessionSync, SessionSyncResponse
from app.crud import (
    bulk_upsert_parcelles,
    bulk_upsert_diagnostics,
    bulk_upsert_sessions,
)

router = APIRouter(prefix="/sync", tags=["Synchronisation"])


@router.post(
    "/parcelles",
    response_model=ParcelleSyncResponse,
    summary="Synchroniser les parcelles",
    description=(
        "Reçoit un ensemble de parcelles créées hors-ligne sur le téléphone "
        "et les sauvegarde sur le serveur. Une parcelle déjà reçue avec le même "
        "client_uuid est mise à jour, pas dupliquée."
    ),
)
def sync_parcelles(
    data: ParcelleSync,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Synchronisation en bloc des parcelles créées hors-ligne."""
    processed, created = bulk_upsert_parcelles(
        db=db,
        user_id=current_user.id,
        parcelles_data=data.parcelles,
    )
    updated = len({id(p) for p in processed}) - len(created)
    message = f"{len(created)} parcelle(s) créée(s)."
    if updated > 0:
        message += f" {updated} déjà connue(s), mise(s) à jour."
    return ParcelleSyncResponse(
        total_received=len(data.parcelles),
        total_created=len(created),
        message=message,
        parcelles=processed,
        parcelles_creees=created,
    )


@router.post(
    "/diagnostics",
    response_model=DiagnosticSyncResponse,
    summary="Synchroniser les diagnostics",
    description=(
        "Reçoit un ensemble de diagnostics IA effectués hors-ligne sur le téléphone "
        "et les sauvegarde sur le serveur. Chaque diagnostic doit être lié à une "
        "parcelle existante appartenant à l'utilisateur."
    ),
)
def sync_diagnostics(
    data: DiagnosticSync,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Synchronisation en bloc des diagnostics créés hors-ligne."""
    processed, created, skipped = bulk_upsert_diagnostics(
        db=db,
        user_id=current_user.id,
        diagnostics_data=data.diagnostics,
    )

    message = f"{len(created)} diagnostic(s) synchronisé(s) avec succès."
    if skipped > 0:
        message += f" {skipped} ignoré(s) (parcelle introuvable ou non autorisée)."

    return DiagnosticSyncResponse(
        total_received=len(data.diagnostics),
        total_created=len(created),
        total_skipped=skipped,
        message=message,
        diagnostics=processed,
        diagnostics_crees=created,
    )


@router.post(
    "/sessions",
    response_model=SessionSyncResponse,
    summary="Synchroniser les sessions de scan",
    description=(
        "Reçoit les sessions de diagnostic multi-photos créées hors ligne, avec "
        "leurs observations. La parcelle est facultative : une session peut être "
        "rattachée plus tard. Un renvoi ne crée pas de doublon, mais une photo "
        "ajoutée après coup rejoint sa session."
    ),
)
def sync_sessions(
    data: SessionSync,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Synchronisation en bloc des sessions de scan (tâche P2.3)."""
    processed, created, skipped, observations_created = bulk_upsert_sessions(
        db=db,
        user_id=current_user.id,
        sessions_data=data.sessions,
    )

    message = (
        f"{len(created)} session(s) créée(s), "
        f"{observations_created} observation(s) ajoutée(s)."
    )
    if skipped > 0:
        message += f" {skipped} ignorée(s) (parcelle introuvable ou non autorisée)."

    return SessionSyncResponse(
        total_received=len(data.sessions),
        total_created=len(created),
        total_skipped=skipped,
        total_observations_created=observations_created,
        message=message,
        sessions=processed,
    )
