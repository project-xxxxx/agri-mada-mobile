"""
Schémas Pydantic - Agent de conseil (ADR-012).
"""

from datetime import datetime
from typing import List, Literal, Optional

from pydantic import BaseModel, Field, field_validator

from app.schemas.conseil import AvertissementResponse
from app.schemas.parcelle import UUID_PATTERN

MAX_ECHANGES_HISTORIQUE = 6


class EchangeSigne(BaseModel):
    """Un échange précédent, tel que le serveur l'a renvoyé et signé."""
    question: str = Field(..., max_length=500)
    reponse: str = Field(..., max_length=4000)
    emis_le: datetime
    signature: str = Field(..., pattern=r"^[0-9a-f]{64}$")


class AgentMessage(BaseModel):
    question: str = Field(
        ..., min_length=3, max_length=500,
        examples=["Qu'a trouvé le dernier scan de ma parcelle du bas-fond ?"],
    )
    langue: Literal["fr", "mg"] = "fr"
    conversation_id: str = Field(
        ..., pattern=UUID_PATTERN,
        description="Généré par l'application ; lie les échanges signés à une conversation.",
    )
    historique: List[EchangeSigne] = Field(
        default_factory=list,
        max_length=MAX_ECHANGES_HISTORIQUE,
        description="Derniers échanges renvoyés tels quels, du plus ancien au plus récent.",
    )
    consentement_conservation: bool = Field(
        False,
        description=(
            "L'utilisateur accepte que ses questions et les réponses soient conservées "
            "(durée limitée) et envoyées au fournisseur du modèle. Obligatoire."
        ),
    )

    @field_validator("question")
    @classmethod
    def _question_non_vide(cls, valeur: str) -> str:
        valeur = valeur.strip()
        if len(valeur) < 3:
            raise ValueError("La question doit contenir au moins 3 caractères.")
        return valeur


class FicheAgentResponse(BaseModel):
    id: str
    nom_fr: str
    nom_mg: Optional[str] = None
    statut_validation: str


class AgentReponse(BaseModel):
    issue: Literal[
        "repondu",
        "hors_fiches",
        "refus_produit",
        "repli_securite",
        "urgence_sante",
        "refus_injection",
        "salutation",
    ] = Field(..., description="Ce qui a produit la réponse ; seul « repondu » vient librement du modèle.")
    reponse: str
    fiches: List[FicheAgentResponse]
    sessions_consultees: List[int]
    avertissements: List[AvertissementResponse]
    orienter_technicien: bool
    motifs_technicien: List[str] = Field(
        ...,
        description=(
            "piste_a_confirmer, scan_sans_nom, gravite_elevee, maladie_a_signaler, "
            "hors_fiches, demande_traitement"
        ),
    )
    echange: EchangeSigne = Field(..., description="À renvoyer dans `historique` au tour suivant.")
    questions_restantes: Optional[int] = Field(
        None, description="null quand la réponse n'a pas consommé de question (réponse fixe)."
    )
