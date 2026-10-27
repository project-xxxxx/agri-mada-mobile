"""
Schémas Pydantic - Sessions de diagnostic multi-photos (tâche P2.3).
"""

from datetime import datetime
from typing import List, Literal, Optional

from pydantic import BaseModel, Field

from app.schemas.parcelle import UUID_PATTERN

ORGANES = Literal[
    "feuille",
    "tige_gaine",
    "collet",
    "racines",
    "panicule_grains",
    "plante_entiere",
]


# --- Schémas d'entrée ---

class ObservationCreate(BaseModel):
    """Une photo d'organe et ce que l'agriculteur en a dit."""

    client_uuid: Optional[str] = Field(None, pattern=UUID_PATTERN)
    organe: ORGANES = Field(..., examples=["feuille"])
    image_path: Optional[str] = Field(None, max_length=500)
    qualite_nettete: Optional[float] = Field(None, ge=0)
    qualite_luminosite: Optional[float] = Field(None, ge=0, le=1)
    top_k: Optional[str] = Field(
        None, description='Sortie du modèle en JSON, null pour un organe sans modèle'
    )
    reponses: Optional[str] = Field(
        None, description="Réponses au questionnaire en JSON"
    )
    created_at: datetime


class DiagnosticSessionCreate(BaseModel):
    """Session envoyée par le téléphone, avec ses observations."""

    client_uuid: Optional[str] = Field(None, pattern=UUID_PATTERN)
    parcelle_id: Optional[int] = None
    parcelle_client_uuid: Optional[str] = Field(None, pattern=UUID_PATTERN)
    created_at: datetime
    stade: Optional[str] = Field(None, max_length=50)
    ecosysteme: Optional[str] = Field(None, max_length=50)
    resultat_fiche_id: Optional[str] = Field(None, max_length=100)
    certitude: Optional[str] = Field(None, max_length=20)
    gravite_declaree: Optional[str] = Field(None, max_length=50)
    classement: Optional[str] = None
    statut_validation: Optional[str] = Field(None, max_length=30)
    observations: List[ObservationCreate] = Field(default_factory=list)


class SessionSync(BaseModel):
    sessions: List[DiagnosticSessionCreate]


# --- Schémas de sortie ---

class ObservationResponse(BaseModel):
    id: int
    client_uuid: Optional[str] = None
    organe: str
    image_path: Optional[str] = None
    qualite_nettete: Optional[float] = None
    qualite_luminosite: Optional[float] = None
    top_k: Optional[str] = None
    reponses: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class DiagnosticSessionResponse(BaseModel):
    id: int
    user_id: int
    parcelle_id: Optional[int] = None
    client_uuid: Optional[str] = None
    created_at: datetime
    stade: Optional[str] = None
    ecosysteme: Optional[str] = None
    resultat_fiche_id: Optional[str] = None
    certitude: Optional[str] = None
    gravite_declaree: Optional[str] = None
    classement: Optional[str] = None
    statut_validation: str
    synced_at: datetime
    observations: List[ObservationResponse] = Field(default_factory=list)

    class Config:
        from_attributes = True


class SessionSyncResponse(BaseModel):
    total_received: int
    total_created: int
    total_skipped: int = 0
    total_observations_created: int = 0
    message: str
    sessions: List[DiagnosticSessionResponse] = Field(
        default_factory=list,
        description="Toutes les sessions acceptées ; le client les associe par client_uuid.",
    )
