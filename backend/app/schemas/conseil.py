"""
Schémas Pydantic - Conseil à partir des fiches (tâche P5.4).
"""

from typing import List, Literal, Optional

from pydantic import BaseModel, Field, field_validator


class ConseilQuestion(BaseModel):
    """Question posée par un agriculteur ou un technicien."""
    question: str = Field(
        ...,
        min_length=3,
        max_length=500,
        examples=["Mes feuilles ont des taches en losange avec un centre gris, qu'est-ce que c'est ?"],
    )
    langue: Literal["fr", "mg"] = Field(
        "fr", description="Langue de la réponse, en général celle de l'application."
    )

    @field_validator("question")
    @classmethod
    def _question_non_vide(cls, valeur: str) -> str:
        valeur = valeur.strip()
        if len(valeur) < 3:
            raise ValueError("La question doit contenir au moins 3 caractères.")
        return valeur


class FicheCiteeResponse(BaseModel):
    id: str
    nom_fr: str
    nom_mg: Optional[str] = None
    statut_validation: str = Field(..., description="brouillon ou valide (ADR-010)")
    score: float = Field(..., description="Similarité de l'extrait le plus proche (0 à 1)")


class AvertissementResponse(BaseModel):
    code: str = Field(
        ...,
        description=(
            "reponse_automatique, fiches_brouillon ou malgache_non_relu : "
            "l'application peut les traduire elle-même à partir du code."
        ),
    )
    message: str


class ConseilReponse(BaseModel):
    trouve: bool = Field(
        ..., description="false quand les fiches ne répondent pas : la réponse renvoie alors vers un technicien."
    )
    reponse: str
    fiches: List[FicheCiteeResponse]
    avertissements: List[AvertissementResponse]
    questions_restantes: int = Field(..., description="Questions encore autorisées aujourd'hui pour ce compte")
