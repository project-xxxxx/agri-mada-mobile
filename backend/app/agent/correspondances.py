"""
Correspondances entre les briques existantes (agent, ADR-012).

Les sessions synchronisées portent les étiquettes du modèle feuille embarqué
(assets/model/labels.txt), pas les identifiants des fiches de connaissance :
l'agent fait le pont ici, explicitement, y compris pour les étiquettes qui
n'ont aucune fiche.
"""

from __future__ import annotations

import re
import unicodedata

# Clés en minuscules. Une étiquette absente de cette table est traitée comme sans fiche.
FICHE_PAR_ETIQUETTE: dict[str, str | None] = {
    "bacterial leaf blight": "blb",
    "brown spot": "helminthosporiose",
    # Charbon foliaire (Entyloma oryzae) : ni classe de taxonomie ni fiche.
    "leaf smut": None,
    "healthy": None,
    "normal": None,
}

NOM_PAR_ETIQUETTE: dict[str, dict[str, str]] = {
    "bacterial leaf blight": {"fr": "flétrissement bactérien", "mg": "malazo ravina vokatry ny bakteria"},
    "brown spot": {"fr": "helminthosporiose (tache brune)", "mg": "helminthosporiose"},
    "leaf smut": {"fr": "charbon foliaire", "mg": "charbon foliaire"},
    "healthy": {"fr": "plante saine", "mg": "vary salama"},
    "normal": {"fr": "plante saine", "mg": "vary salama"},
}

# Maladies qui se propagent ou n'ont aucun remède connu : un technicien doit
# être prévenu tôt (arrachage, brûlage, surveillance des voisins).
FICHES_A_SIGNALER = {
    "rymv",
    "blb",
    "bls",
    "bacteriose_gaine_altitude",
    "brunissure_bacterienne_panicule",
}

# Termes qui désignent sans ambiguïté un problème précis. Les mots courants
# (« tache brune », « malazo », « voana » qui veut aussi dire « atteint » en
# malgache) sont exclus : ils déclencheraient le contrôle d'ancrage à tort.
TERMES_PAR_PROBLEME: dict[str, list[str]] = {
    "pyriculariose": ["pyriculariose", "menalavitra", "pyricularia", "magnaporthe"],
    "helminthosporiose": ["helminthosporiose", "brown spot", "bipolaris"],
    "blb": ["fletrissement bacterien", "bacterial leaf blight", "blb", "oryzae pv. oryzae"],
    "bls": ["strie bacterienne", "bls", "oryzicola"],
    "rymv": ["panachure jaune", "rymv", "mavoratsy", "mativondrana", "fondrabe"],
    "cercosporiose": ["cercosporiose", "cercospora"],
    "rhizoctone": ["rhizoctone", "sheath blight", "rhizoctonia"],
    "bakanae": ["bakanae", "fusarium"],
    "faux_charbon": ["faux charbon", "ustilaginoidea"],
    "mildiou": ["mildiou", "sclerophthora"],
    "echaudure": ["echaudure", "leaf scald", "microdochium"],
    "pourriture_gaine": ["pourriture de la gaine", "sarocladium"],
    "bacteriose_gaine_altitude": ["bacteriose d'altitude", "fuscovaginae", "pourriture brune de la gaine"],
    "brunissure_bacterienne_panicule": ["brunissure bacterienne", "burkholderia"],
    "galles_nematodes": ["nematode", "meloidogyne"],
    "toxicite_ferreuse": ["toxicite ferreuse"],
    "coeur_mort_foreurs": ["foreur", "coeur mort", "fositra", "maliarpha", "sesamia"],
    "degats_hispa": ["hispa", "haom-bary", "pou du riz"],
    "degats_voana": ["heteronychus", "scarabee noir"],
    "degats_punaises": ["punaise", "besoroka"],
    "carence_azote": ["carence en azote"],
    "carence_phosphore": ["carence en phosphore"],
    "carence_potassium": ["carence en potassium"],
    "sterilite_froid": ["sterilite due au froid"],
    # Étiquette du modèle sans fiche : ne peut être citée que si un scan la renvoie.
    "leaf smut": ["charbon foliaire", "leaf smut", "entyloma"],
}


def normaliser(texte: str) -> str:
    """Minuscules, sans accents ni ligatures : « Cœur mort » → « coeur mort »."""
    texte = texte.lower().replace("œ", "oe").replace("æ", "ae").replace("’", "'")
    decompose = unicodedata.normalize("NFKD", texte)
    return "".join(c for c in decompose if not unicodedata.combining(c))


# Début de mot seulement : « foreur » reconnaît aussi « foreurs ».
_MOTIFS_TERMES = [
    (terme, re.compile(r"(?<![a-z0-9])" + re.escape(terme)))
    for termes in TERMES_PAR_PROBLEME.values()
    for terme in termes
]


def termes_cites(texte: str) -> set[str]:
    """Termes du vocabulaire des maladies présents dans le texte."""
    texte = normaliser(texte)
    return {terme for terme, motif in _MOTIFS_TERMES if motif.search(texte)}
