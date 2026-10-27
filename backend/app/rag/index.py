"""
Index vectoriel des fiches, chargé en mémoire (tâche P5.4, ADR-011).

Recherche exacte par similarité cosinus sur tous les extraits : à quelques
centaines de vecteurs, le parcours complet reste sous la milliseconde et
dispense d'une base vectorielle (pgvector) sur un backend en SQLite.
"""

from __future__ import annotations

import json
import math
from dataclasses import dataclass
from pathlib import Path

from app.rag.decoupage import Extrait

CHEMIN_INDEX = Path(__file__).with_name("index_fiches.json")
VERSION_FORMAT = 1


@dataclass(frozen=True)
class FicheIndexee:
    id: str
    nom_fr: str
    nom_mg: str | None
    statut_validation: str


@dataclass(frozen=True)
class ExtraitIndexe:
    id: str
    fiche_id: str
    section: str
    texte: str
    vecteur: tuple[float, ...]


@dataclass(frozen=True)
class Resultat:
    extrait: ExtraitIndexe
    score: float


def normaliser(vecteur: list[float] | tuple[float, ...]) -> tuple[float, ...]:
    norme = math.sqrt(sum(v * v for v in vecteur))
    if norme == 0:
        raise ValueError("vecteur nul : impossible de calculer une similarité")
    return tuple(v / norme for v in vecteur)


class IndexFiches:
    def __init__(
        self,
        *,
        modele_embedding: str,
        dimensions: int,
        empreinte_fiches: str,
        fiches: dict[str, FicheIndexee],
        extraits: list[ExtraitIndexe],
    ) -> None:
        self.modele_embedding = modele_embedding
        self.dimensions = dimensions
        self.empreinte_fiches = empreinte_fiches
        self.fiches = fiches
        self.extraits = extraits

    @classmethod
    def charger(cls, chemin: Path = CHEMIN_INDEX) -> "IndexFiches":
        donnees = json.loads(chemin.read_text(encoding="utf-8"))
        if donnees.get("version_format") != VERSION_FORMAT:
            raise ValueError(f"{chemin.name} : format {donnees.get('version_format')!r} non pris en charge")
        return cls(
            modele_embedding=donnees["modele_embedding"],
            dimensions=donnees["dimensions"],
            empreinte_fiches=donnees["empreinte_fiches"],
            fiches={
                fiche["id"]: FicheIndexee(
                    id=fiche["id"],
                    nom_fr=fiche["nom_fr"],
                    nom_mg=fiche["nom_mg"],
                    statut_validation=fiche["statut_validation"],
                )
                for fiche in donnees["fiches"]
            },
            extraits=[
                ExtraitIndexe(
                    id=extrait["id"],
                    fiche_id=extrait["fiche_id"],
                    section=extrait["section"],
                    texte=extrait["texte"],
                    vecteur=normaliser(extrait["vecteur"]),
                )
                for extrait in donnees["extraits"]
            ],
        )

    def rechercher(self, vecteur_question: list[float], top_k: int) -> list[Resultat]:
        if len(vecteur_question) != self.dimensions:
            raise ValueError(
                f"vecteur de {len(vecteur_question)} dimensions, l'index en attend {self.dimensions}"
            )
        question = normaliser(vecteur_question)
        scores = [
            (sum(a * b for a, b in zip(question, extrait.vecteur)), extrait)
            for extrait in self.extraits
        ]
        scores.sort(key=lambda paire: paire[0], reverse=True)
        return [Resultat(extrait=extrait, score=score) for score, extrait in scores[:top_k]]


def serialiser_index(
    *,
    modele_embedding: str,
    dimensions: int,
    empreinte: str,
    fiches: list[dict],
    extraits: list[Extrait],
    vecteurs: list[list[float]],
) -> dict:
    if len(extraits) != len(vecteurs):
        raise ValueError(f"{len(extraits)} extraits mais {len(vecteurs)} vecteurs")
    return {
        "version_format": VERSION_FORMAT,
        "modele_embedding": modele_embedding,
        "dimensions": dimensions,
        "empreinte_fiches": empreinte,
        "fiches": [
            {
                "id": fiche["id"],
                "nom_fr": fiche["noms"]["fr"],
                "nom_mg": fiche["noms"].get("mg"),
                "statut_validation": fiche["validation"]["statut"],
            }
            for fiche in sorted(fiches, key=lambda f: f["id"])
        ],
        "extraits": [
            {
                "id": extrait.id,
                "fiche_id": extrait.fiche_id,
                "section": extrait.section,
                "texte": extrait.texte,
                "vecteur": [round(v, 6) for v in normaliser(vecteur)],
            }
            for extrait, vecteur in zip(extraits, vecteurs)
        ],
    }
