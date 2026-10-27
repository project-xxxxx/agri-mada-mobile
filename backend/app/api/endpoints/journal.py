"""
Endpoints du journal agricole.
Fournit un résumé de l'état de santé de chaque parcelle d'un agriculteur.

- GET /journal : Obtenir le journal agricole de l'utilisateur connecté
- GET /journal/parcelle/{parcelle_id} : Détails des diagnostics d'une parcelle
"""

from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.deps import get_current_user
from app.models.user import User
from app.schemas.parcelle import ParcelleResponse
from app.schemas.diagnostic import DiagnosticResponse
from app.crud import (
    get_journal_agricole,
    get_parcelle_by_id,
    get_diagnostics_by_parcelle,
)

router = APIRouter(prefix="/journal", tags=["Journal Agricole"])


@router.get(
    "/",
    summary="Journal agricole",
    description=(
        "Retourne l'état de santé de chaque parcelle de l'agriculteur connecté, "
        "d'après son dernier scan : `sain`, `malade` (résultat probable seulement), "
        "`a_confirmer` (piste du modèle, ADR-006) ou `aucun_diagnostic`."
    ),
)
def get_journal(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Récupère le journal agricole complet :
    - Liste de toutes les parcelles
    - Statut de santé de chaque parcelle (sain / malade / a_confirmer / aucun_diagnostic)
    - Dernier résultat et sa certitude
    - Nombre de scans
    """
    journal = get_journal_agricole(db, current_user.id)
    return {
        "user_id": current_user.id,
        "user_nom": f"{current_user.prenom} {current_user.nom}",
        "region": current_user.region,
        "total_parcelles": len(journal),
        "parcelles_saines": sum(1 for p in journal if p["statut"] == "sain"),
        "parcelles_malades": sum(1 for p in journal if p["statut"] == "malade"),
        "parcelles_a_confirmer": sum(1 for p in journal if p["statut"] == "a_confirmer"),
        "parcelles": journal,
    }


@router.get(
    "/parcelle/{parcelle_id}",
    response_model=List[DiagnosticResponse],
    summary="Détails d'une parcelle",
    description=(
        "Retourne l'historique complet des diagnostics pour une parcelle spécifique. "
        "Permet de suivre l'évolution des maladies sur cette parcelle."
    ),
)
def get_parcelle_details(
    parcelle_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Historique des diagnostics d'une parcelle spécifique."""
    # Vérifier que la parcelle existe et appartient à l'utilisateur
    parcelle = get_parcelle_by_id(db, parcelle_id)
    if not parcelle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Parcelle introuvable.",
        )
    if parcelle.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Cette parcelle ne vous appartient pas.",
        )

    diagnostics = get_diagnostics_by_parcelle(db, parcelle_id)
    return diagnostics
