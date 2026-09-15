"""
Schémas Pydantic - Diagnostic.
Définissent le format des données pour les résultats d'analyse IA synchronisés.
"""

from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field, model_validator

from app.schemas.parcelle import UUID_PATTERN


# --- Schémas d'entrée ---

class DiagnosticCreate(BaseModel):
    """Données d'un diagnostic envoyé depuis l'application mobile."""
    client_uuid: Optional[str] = Field(
        None,
        pattern=UUID_PATTERN,
        description="Identifiant généré par le téléphone ; un renvoi ne crée pas de doublon.",
    )
    parcelle_id: Optional[int] = Field(
        None, description="ID serveur de la parcelle, s'il est connu du téléphone"
    )
    parcelle_client_uuid: Optional[str] = Field(
        None,
        pattern=UUID_PATTERN,
        description="Identifiant téléphone de la parcelle (prioritaire sur parcelle_id)",
    )
    maladie_detectee: str = Field(
        ...,
        max_length=100,
        examples=["Bacterial leaf blight"],
        description="Résultat de l'IA : Bacterial leaf blight, Brown spot, Leaf smut",
    )
    confiance: Optional[float] = Field(
        None,
        ge=0.0,
        le=1.0,
        examples=[0.92],
        description="Score de confiance du modèle (0.0 à 1.0)",
    )
    certitude: Optional[str] = Field(
        None,
        max_length=20,
        examples=["probable"],
        description="Certitude affichée à l'agriculteur : probable, possible",
    )
    niveau_gravite: Optional[str] = Field(
        None,
        max_length=50,
        examples=["moins_tiers"],
        description="Part de parcelle déclarée : quelques_plants, moins_tiers, plus_tiers",
    )
    recommandations: Optional[str] = Field(
        None,
        max_length=1000,
        examples=["Retirer et brûler les résidus de récolte malades"],
    )
    date_diagnostic: datetime = Field(
        ..., description="Date/heure de l'analyse effectuée hors-ligne sur le téléphone"
    )

    @model_validator(mode="after")
    def _parcelle_designee(self) -> "DiagnosticCreate":
        if self.parcelle_id is None and not self.parcelle_client_uuid:
            raise ValueError("parcelle_id ou parcelle_client_uuid est requis.")
        return self


class DiagnosticSync(BaseModel):
    """
    Format de synchronisation en bloc des diagnostics.
    L'application mobile envoie tous les diagnostics non synchronisés d'un coup.
    """
    diagnostics: List[DiagnosticCreate]


# --- Schémas de sortie ---

class DiagnosticResponse(BaseModel):
    """Données d'un diagnostic renvoyées par l'API."""
    id: int
    user_id: int
    parcelle_id: int
    client_uuid: Optional[str] = None
    maladie_detectee: str
    confiance: Optional[float] = None
    certitude: Optional[str] = None
    niveau_gravite: Optional[str] = None
    recommandations: Optional[str] = None
    date_diagnostic: datetime
    synced_at: datetime

    class Config:
        from_attributes = True


class DiagnosticSyncResponse(BaseModel):
    """Réponse après synchronisation en bloc des diagnostics."""
    total_received: int
    total_created: int
    total_skipped: int = 0
    message: str
    diagnostics: List[DiagnosticResponse] = Field(
        default_factory=list,
        description="Tous les diagnostics acceptés ; le client les associe par client_uuid.",
    )
    diagnostics_crees: List[DiagnosticResponse] = Field(
        default_factory=list,
        description="Seulement les diagnostics nouvellement créés (compatibilité).",
    )
