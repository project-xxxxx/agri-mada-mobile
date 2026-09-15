"""
Schémas Pydantic - Parcelle.
Définissent le format des données pour la gestion des parcelles (journal agricole).
"""

from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field

UUID_PATTERN = (
    r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
)


# --- Schémas d'entrée ---

class ParcelleCreate(BaseModel):
    """Données pour créer une parcelle depuis l'application mobile."""
    client_uuid: Optional[str] = Field(
        None,
        pattern=UUID_PATTERN,
        description=(
            "Identifiant généré par le téléphone. Un renvoi avec le même identifiant "
            "met à jour la parcelle au lieu d'en créer une seconde."
        ),
    )
    nom_parcelle: str = Field(
        ..., min_length=1, max_length=200, examples=["Champ Nord"]
    )
    description: Optional[str] = Field(
        None, max_length=500, examples=["Rizière proche de la rivière"]
    )
    surface: Optional[float] = Field(
        None, ge=0, examples=[2.5], description="Surface en hectares"
    )
    latitude: Optional[float] = Field(None, examples=[-18.9137])
    longitude: Optional[float] = Field(None, examples=[47.5361])


class ParcelleSync(BaseModel):
    """
    Format de synchronisation en bloc des parcelles.
    L'application mobile envoie une liste de parcelles créées hors-ligne.
    """
    parcelles: List[ParcelleCreate]


# --- Schémas de sortie ---

class ParcelleResponse(BaseModel):
    """Données d'une parcelle renvoyées par l'API."""
    id: int
    user_id: int
    client_uuid: Optional[str] = None
    nom_parcelle: str
    description: Optional[str] = None
    surface: Optional[float] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    created_at: datetime
    nb_diagnostics: int = 0
    derniere_maladie: Optional[str] = None

    class Config:
        from_attributes = True


class ParcelleSyncResponse(BaseModel):
    """Réponse après synchronisation en bloc des parcelles."""
    total_received: int
    total_created: int
    message: str
    parcelles: List[ParcelleResponse] = Field(
        default_factory=list,
        description="Toutes les parcelles traitées ; le client les associe par client_uuid.",
    )
    parcelles_creees: List[ParcelleResponse] = Field(
        default_factory=list,
        description="Seulement les parcelles nouvellement créées (compatibilité).",
    )
