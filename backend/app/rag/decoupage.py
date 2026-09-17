"""
Découpage des fiches de connaissance en extraits recherchables (tâche P5.4).

Un extrait par section de fiche (identité, symptômes par organe, confusions,
conditions, prévention, lutte chimique) : une question d'agriculteur porte
presque toujours sur un seul de ces aspects, et un extrait court se retrouve
mieux par similarité qu'une fiche entière. Chaque extrait reprend le nom de la
fiche, pour rester compréhensible une fois isolé.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass

# À incrémenter quand le découpage change : l'empreinte de l'index change avec
# lui, et le test de cohérence exige de reconstruire l'index.
VERSION_DECOUPAGE = 1

LIBELLES_ORGANES = {
    "feuille": "la feuille",
    "tige_gaine": "la tige ou la gaine",
    "collet": "le collet",
    "racines": "les racines",
    "panicule_grains": "la panicule ou les grains",
    "plante_entiere": "la plante entière ou la parcelle",
}

LIBELLES_ECOSYSTEMES = {
    "irrigue": "rizière irriguée",
    "bas_fond": "bas-fond",
    "tanety_pluvial": "riz pluvial sur tanety",
}


@dataclass(frozen=True)
class Extrait:
    id: str
    fiche_id: str
    section: str
    texte: str


def empreinte_fiches(fiches: list[dict]) -> str:
    """Empreinte du contenu des fiches, indépendante de leur ordre et de leur mise en forme."""
    canonique = json.dumps(
        sorted(fiches, key=lambda fiche: fiche["id"]), sort_keys=True, ensure_ascii=False
    )
    return hashlib.sha256(f"{VERSION_DECOUPAGE}:{canonique}".encode("utf-8")).hexdigest()


def _titre(fiche: dict) -> str:
    noms = fiche["noms"]
    alias = [nom for nom in [noms.get("mg"), *noms.get("autres_noms_mg", [])] if nom]
    if not alias:
        return noms["fr"]
    return f"{noms['fr']} (en malgache : {', '.join(alias)})"


def _texte_conditions(conditions: dict) -> str | None:
    morceaux = []
    if conditions["ecosystemes"]:
        morceaux.append(
            "écosystèmes : "
            + ", ".join(LIBELLES_ECOSYSTEMES.get(e, e) for e in conditions["ecosystemes"])
        )
    if conditions["altitude_m"]:
        morceaux.append("altitude : " + " à ".join(f"{int(a)} m" for a in conditions["altitude_m"]))
    if conditions["facteurs"]:
        morceaux.append("facteurs favorables : " + " ; ".join(conditions["facteurs"]))
    if not morceaux:
        return None
    return "conditions favorables. " + ". ".join(morceaux) + "."


def _texte_lutte_chimique(lutte: dict) -> str:
    if lutte["statut"] == "sans_objet":
        note = lutte.get("note") or "ce problème ne se corrige pas par un produit phytosanitaire"
        return f"traitement chimique sans objet : {note}."
    return (
        "aucun produit ni aucune dose ne sont indiqués : la liste officielle des produits "
        "autorisés (DPV) n'est pas encore intégrée. Demander conseil à un technicien "
        "agricole avant tout traitement."
    )


def decouper_fiche(fiche: dict, noms_par_id: dict[str, str]) -> list[Extrait]:
    titre = _titre(fiche)
    fiche_id = fiche["id"]
    extraits: list[Extrait] = []

    def ajouter(section: str, texte: str) -> None:
        extraits.append(Extrait(f"{fiche_id}#{section}", fiche_id, section, f"{titre} — {texte}"))

    organes = ", ".join(LIBELLES_ORGANES[organe] for organe in fiche["organes"])
    identite = f"problème qui touche {organes}."
    if fiche["noms"].get("sci"):
        identite += f" Agent ou cause : {fiche['noms']['sci']}."
    ajouter("identite", identite)

    for organe, symptomes in fiche["organes"].items():
        ajouter(f"organe:{organe}", f"symptômes sur {LIBELLES_ORGANES[organe]} : {' ; '.join(symptomes)}.")

    for confusion in fiche["confusions"]:
        autre = noms_par_id.get(confusion["fiche"], confusion["fiche"])
        ajouter(
            f"confusion:{confusion['fiche']}",
            f"peut se confondre avec {autre}. Pour les distinguer : {confusion['question']['fr']}",
        )

    conditions = _texte_conditions(fiche["conditions"])
    if conditions:
        ajouter("conditions", conditions)

    ajouter("prevention", "prévention : " + " ; ".join(fiche["prevention"]) + ".")
    ajouter("lutte_chimique", _texte_lutte_chimique(fiche["lutte_chimique"]))
    return extraits


def decouper_fiches(fiches: list[dict]) -> list[Extrait]:
    noms_par_id = {fiche["id"]: fiche["noms"]["fr"] for fiche in fiches}
    return [
        extrait
        for fiche in sorted(fiches, key=lambda f: f["id"])
        for extrait in decouper_fiche(fiche, noms_par_id)
    ]
