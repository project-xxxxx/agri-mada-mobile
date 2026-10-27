#!/usr/bin/env python3
"""Génère les fiches de connaissance (tâche P5.1) depuis ml/taxonomy_v1.yaml.

Une fiche correspond à un problème identifiable par un agriculteur ou un
technicien (une maladie, un ravageur, un trouble abiotique) — pas à une
classe de taxonomie brute : une maladie qui touche plusieurs organes (la
pyriculariose sur feuille, collet et panicule) n'a qu'une fiche, avec une
entrée par organe dans son champ `organes`. Les classes « saines » et les
catégories techniques de la porte (`riz_exploitable`, `pas_riz`,
`photo_inexploitable`) n'ont pas de fiche : rien à prévenir ni à traiter.

Les champs mécaniques (noms, agent, sources, priorité) viennent de
ml/taxonomy_v1.yaml, pour rester cohérents avec elle sans dupliquer à la
main. Le contenu organe par organe, les confusions et la prévention sont
tirés du plan de correction (section « Diagnostiquer au-delà de la feuille »)
et des `notes` déjà sourcées de la taxonomie — jamais inventés : une classe
sans détail au-delà de sa `note` de taxonomie reprend cette note telle
quelle, honnêtement, plutôt qu'un symptôme fabriqué.

Toutes les fiches sortent au statut `brouillon` (aucune n'est validée par un
agronome) : voir knowledge/fiches/README.md.

Usage :
    ml/.venv/Scripts/python ml/scripts/generate_fiches.py
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[2]
TAXONOMY = ROOT / "ml" / "taxonomy_v1.yaml"
FICHES_DIR = ROOT / "knowledge" / "fiches"
# Fiches écrites à la main (contenu plus riche que ce générateur), reprises
# telles quelles dans le bundle plutôt que régénérées.
FICHES_MANUELLES = ["carence_azote", "carence_phosphore", "carence_potassium"]
BUNDLE = ROOT / "assets" / "knowledge" / "fiches.json"

# Prévention générique par nature de problème, réutilisée quand aucune
# précision spécifique n'existe (cohérent avec lib/core/ai/disease_catalog.dart,
# ADR-005 : aucun produit ni dosage, toujours renvoyer vers un technicien).
PREVENTION_MALADIE = ["semences saines", "résidus de récolte retirés ou enfouis", "outils nettoyés entre parcelles"]
PREVENTION_RAVAGEUR = ["surveillance régulière de la parcelle", "élimination des adventices hôtes"]
PREVENTION_GENERIQUE_FIN = "avis d'un technicien avant tout traitement"

# Chaque entrée : id de fiche, ids de taxonomie regroupés (1 ou plus),
# organes -> liste de symptômes, et le reste des champs de la fiche.
FICHES: list[dict] = [
    {
        "id": "pyriculariose",
        "nom_fr_override": "Pyriculariose",
        "taxonomy_ids": ["pyriculariose_feuille", "pyriculariose_noeud_collet", "pyriculariose_cou"],
        "organes": {
            "feuille": ["lésions en losange, centre gris, bord brun"],
            "collet": ["collet ou nœud noirci qui casse"],
            "panicule_grains": ["cou de la panicule brun-noir", "panicule blanche ou vide qui se casse"],
        },
        "confusions": [
            {"fiche": "helminthosporiose", "question": {"fr": "Les taches ont-elles un centre gris clair et une forme en losange ?", "mg": None}},
        ],
        "conditions": {"ecosystemes": ["tanety_pluvial", "irrigue"], "altitude_m": [1000, 1800], "facteurs": ["forte humidité (> 90 %)", "nuits fraîches (20-25°C)", "excès d'azote", "variété sensible"]},
        "prevention": ["variété recommandée par FOFIFA pour la zone", "apport d'azote fractionné plutôt qu'en une fois"] + PREVENTION_MALADIE,
    },
    {
        "id": "blb",
        "taxonomy_ids": ["blb"],
        "organes": {"feuille": ["flétrissement à partir du bord de la feuille", "stries jaune-grisâtre à blanchâtre le long des nervures"]},
        "confusions": [{"fiche": "bls", "question": {"fr": "Le flétrissement part-il du bord de la feuille (BLB) ou suit-il des stries fines entre les nervures sans flétrir toute la feuille (BLS) ?", "mg": None}}],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": ["excès d'azote", "blessures des feuilles (vent, outils)"]},
        "prevention": ["éviter l'excès d'azote"] + PREVENTION_MALADIE,
    },
    {
        "id": "bls",
        "taxonomy_ids": ["bls"],
        "organes": {"feuille": ["fines stries translucides entre les nervures, jaunissant avec le temps"]},
        "confusions": [{"fiche": "blb", "question": {"fr": "Les stries restent-elles fines et entre les nervures, sans flétrissement complet de la feuille ?", "mg": None}}],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": PREVENTION_MALADIE,
    },
    {
        "id": "helminthosporiose",
        "taxonomy_ids": ["helminthosporiose"],
        "organes": {
            "feuille": ["petites taches ovales brunes, pouvant se rejoindre sur les feuilles âgées"],
            "panicule_grains": ["attaque aussi les grains (voir aussi grains_taches, complexe de champignons)"],
        },
        "confusions": [{"fiche": "pyriculariose", "question": {"fr": "Les taches sont-elles petites et ovales (pas en losange) et sans centre gris net ?", "mg": None}}],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": ["sol pauvre", "stress hydrique"]},
        "prevention": ["fertilisation équilibrée (pas seulement l'azote)"] + PREVENTION_MALADIE,
    },
    {
        "id": "cercosporiose",
        "taxonomy_ids": ["cercosporiose"],
        "organes": {"feuille": ["petites taches allongées brun-rougeâtre, bordées d'un halo jaune"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": PREVENTION_MALADIE,
    },
    {
        "id": "echaudure",
        "taxonomy_ids": ["echaudure"],
        "organes": {"feuille": ["taches irrégulières grisâtres à blanchâtres qui sèchent la pointe des feuilles"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": PREVENTION_MALADIE,
    },
    {
        "id": "mildiou",
        "taxonomy_ids": ["mildiou"],
        "organes": {"feuille": ["stries vert pâle à jaunâtres le long des nervures, feuillage clairsemé"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": PREVENTION_MALADIE,
    },
    {
        "id": "degats_hispa",
        "taxonomy_ids": ["degats_hispa"],
        "organes": {"feuille": ["stries blanches parallèles aux nervures, grattage de la surface de la feuille"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": ["surveiller aussi la panachure jaune (RYMV), transmise par ce ravageur"] + PREVENTION_RAVAGEUR,
    },
    {
        "id": "degats_chenilles",
        "taxonomy_ids": ["degats_chenilles"],
        "organes": {"feuille": ["feuilles enroulées ou mangées par plaques"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": PREVENTION_RAVAGEUR,
    },
    {
        "id": "toxicite_ferreuse",
        "nom_fr_override": "Toxicité ferreuse",
        "taxonomy_ids": ["toxicite_fer_feuille", "racines_ferreuses"],
        "organes": {
            "feuille": ["pigmentation orange rouille qui commence à la pointe des feuilles puis gagne tout le feuillage"],
            "racines": ["racines brun-rouge à orangé, gainées de dépôts de fer, peu de radicelles, souvent noircies"],
        },
        "confusions": [{"fiche": "carence_azote", "question": {"fr": "Le jaunissement est-il uniforme et pâle sur les vieilles feuilles (carence), ou orange rouille en partant de la pointe (toxicité ferreuse) ?", "mg": None}}],
        "conditions": {"ecosystemes": ["bas_fond", "irrigue"], "altitude_m": [], "facteurs": ["bas-fonds et parties mal drainées des périmètres irrigués"]},
        "prevention": ["amélioration du drainage", "éviter les bas-fonds mal drainés pour les variétés sensibles"],
    },
    {
        "id": "coeur_mort_foreurs",
        "taxonomy_ids": ["coeur_mort_foreurs", "panicule_blanche_foreurs"],
        "organes": {
            "tige_gaine": ["pousse centrale sèche qui se retire d'un coup (cœur mort)", "trou et larve visibles dans la tige fendue"],
            "panicule_grains": ["panicule blanche dressée qui s'arrache facilement (attaque à l'épiaison)"],
        },
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": PREVENTION_RAVAGEUR,
    },
    {
        "id": "pourriture_gaine",
        "taxonomy_ids": ["pourriture_gaine"],
        "organes": {"tige_gaine": ["gaine de la dernière feuille brunie ou pourrie", "panicule qui sort mal de la gaine"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": ["se voit au début de la montaison"]},
        "prevention": PREVENTION_MALADIE,
    },
    {
        "id": "bacteriose_gaine_altitude",
        "taxonomy_ids": ["bacteriose_gaine_altitude"],
        "organes": {"tige_gaine": ["stries anguleuses sur les gaines, visibles à la formation de la panicule", "stérilité variable selon les variétés"]},
        "confusions": [{"fiche": "sterilite_froid", "question": {"fr": "Y a-t-il des stries anguleuses visibles sur les gaines (bactériose), ou seulement des grains vides sans marque sur les gaines (froid) ?", "mg": None}}],
        "conditions": {"ecosystemes": [], "altitude_m": [1600, 2200], "facteurs": ["Hautes Terres, au-dessus de 1600 m"]},
        "prevention": PREVENTION_MALADIE,
    },
    {
        "id": "rhizoctone",
        "taxonomy_ids": ["rhizoctone"],
        "organes": {"tige_gaine": ["grandes taches ovales gris-vert à bord brun sur les gaines basses"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": PREVENTION_MALADIE,
    },
    {
        "id": "degats_voana",
        "taxonomy_ids": ["degats_voana"],
        "organes": {"collet": ["base de tige rongée", "plant desséché qui s'arrache à la main en laissant ses racines dans le sol"]},
        "confusions": [],
        "conditions": {"ecosystemes": ["tanety_pluvial"], "altitude_m": [], "facteurs": ["surtout sur jeunes plants de riz pluvial"]},
        "prevention": ["lutte biologique à base du champignon Metarhizium (voir la fiche FOFIFA dédiée)"] + PREVENTION_RAVAGEUR,
    },
    {
        "id": "grains_taches",
        "taxonomy_ids": ["grains_taches"],
        "organes": {"panicule_grains": ["grains tachés, décolorés"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": ["pluies à maturité", "parcelles non drainées", "stockage au-dessus de 14 % d'humidité"]},
        "prevention": ["récolte et séchage rapides après maturité", "amélioration du drainage"],
    },
    {
        "id": "degats_punaises",
        "taxonomy_ids": ["degats_punaises"],
        "organes": {"panicule_grains": ["grains vides, piqués ou mangés"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": PREVENTION_RAVAGEUR,
    },
    {
        "id": "sterilite_froid",
        "taxonomy_ids": ["sterilite_froid"],
        "organes": {"panicule_grains": ["grains vides sans marque visible sur la panicule ou les gaines", "trouble non parasitaire"]},
        "confusions": [{"fiche": "bacteriose_gaine_altitude", "question": {"fr": "Y a-t-il des stries anguleuses sur les gaines (bactériose) ou aucune marque particulière hors la stérilité (froid) ?", "mg": None}}],
        "conditions": {"ecosystemes": [], "altitude_m": [1600, 2200], "facteurs": ["Hautes Terres, froid à la floraison"]},
        "prevention": ["choix d'une variété tolérante au froid pour l'altitude", "ajuster la date de repiquage pour éviter la floraison en période froide"],
    },
    {
        "id": "faux_charbon",
        "taxonomy_ids": ["faux_charbon"],
        "organes": {"panicule_grains": ["boules vert-olive à la place des grains"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": PREVENTION_MALADIE,
    },
    {
        "id": "brunissure_bacterienne_panicule",
        "taxonomy_ids": ["brunissure_bacterienne_panicule"],
        "organes": {"panicule_grains": ["brunissement bactérien de la panicule"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": PREVENTION_MALADIE,
    },
    {
        "id": "galles_nematodes",
        "taxonomy_ids": ["galles_nematodes"],
        "organes": {"racines": ["galles en crochet ou renflements au bout des racines"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": ["rotation culturale", "assainissement des pépinières"],
    },
    {
        "id": "racines_noires_pourries",
        "taxonomy_ids": ["racines_noires_pourries"],
        "organes": {"racines": ["racines noires et malodorantes dans un sol asphyxié"]},
        "confusions": [],
        "conditions": {"ecosystemes": ["bas_fond", "irrigue"], "altitude_m": [], "facteurs": ["sol mal drainé, asphyxie racinaire"]},
        "prevention": ["amélioration du drainage"],
    },
    {
        "id": "racines_rongees",
        "taxonomy_ids": ["racines_rongees"],
        "organes": {"racines": ["système racinaire réduit ou rongé — ravageur à identifier avec l'agronome"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": ["photographier aussi le collet pour croiser avec voana ou les foreurs"],
    },
    {
        "id": "rymv",
        "taxonomy_ids": ["rymv"],
        "organes": {"plante_entiere": ["foyers de plants jaune-orangé, nains et peu tallés, répartis en taches dans la parcelle"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": ["répartition côtière rapportée", "transmis par l'hispa et d'autres insectes vecteurs"]},
        "prevention": ["brûler les plants atteints (recommandation FOFIFA)", "lutter contre les insectes vecteurs (hispa)", "aucune lutte curative connue"],
        "lutte_chimique_override": {"statut": "sans_objet", "note": "maladie virale : aucune lutte curative connue (FOFIFA), seule la prévention (variétés, vecteurs, arrachage) s'applique"},
    },
    {
        "id": "foyers_desseches",
        "taxonomy_ids": ["foyers_desseches"],
        "organes": {"plante_entiere": ["taches de plants desséchés dans la parcelle — oriente vers une photo du collet ou de la tige (voana, foreurs ou rats)"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": ["photographier le collet et la tige pour préciser la cause"],
    },
    {
        "id": "carence_generale",
        "taxonomy_ids": ["carence_generale"],
        "organes": {"plante_entiere": ["vert pâle uniforme sur toute la parcelle"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": ["analyse de sol avant d'ajuster la fertilisation"],
        "lutte_chimique_override": {"statut": "sans_objet", "note": "carence nutritionnelle probable, pas une maladie : correction par la fertilisation"},
    },
    {
        "id": "bakanae",
        "taxonomy_ids": ["bakanae"],
        "organes": {"plante_entiere": ["plantules anormalement longues et pâles"]},
        "confusions": [],
        "conditions": {"ecosystemes": [], "altitude_m": [], "facteurs": []},
        "prevention": ["semences saines, traitement des semences avant pépinière"],
    },
]


def charger_taxonomie() -> dict:
    with TAXONOMY.open(encoding="utf-8") as handle:
        return yaml.safe_load(handle)


def index_par_id(taxonomie: dict) -> dict[str, dict]:
    index: dict[str, dict] = {}
    for entree in taxonomie.get("porte", []):
        index[entree["id"]] = entree
    for problemes in taxonomie.get("problemes", {}).values():
        for entree in problemes:
            index[entree["id"]] = entree
    return index


def resoudre_sources(ids_sources: list[str], sources_taxonomie: dict) -> list[dict]:
    resolues = []
    for sid in ids_sources:
        info = sources_taxonomie.get(sid)
        if info is None:
            continue
        entree = {"titre": info["titre"]}
        if "url" in info:
            entree["url"] = info["url"]
        if "fichier" in info:
            entree["fichier"] = info["fichier"]
        resolues.append(entree)
    return resolues


def construire_fiche(spec: dict, index: dict[str, dict], sources_taxonomie: dict) -> dict:
    taxonomy_ids = spec["taxonomy_ids"]
    entrees = [index[tid] for tid in taxonomy_ids]
    principale = entrees[0]

    nom_mg = next((e.get("nom_mg") for e in entrees if e.get("nom_mg")), None)
    agent = next((e.get("agent") for e in entrees if e.get("agent")), None)
    autres_noms_mg: list[str] = []
    for e in entrees:
        for nom in e.get("autres_noms_mg", []):
            if nom not in autres_noms_mg:
                autres_noms_mg.append(nom)
    ids_sources: list[str] = []
    for e in entrees:
        for sid in e.get("sources", []):
            if sid not in ids_sources:
                ids_sources.append(sid)

    fiche = {
        "id": spec["id"],
        "noms": {
            "fr": spec.get("nom_fr_override", principale["nom_fr"]),
            "mg": nom_mg,
            "sci": agent,
            "autres_noms_mg": autres_noms_mg,
        },
        "organes": spec["organes"],
        "confusions": spec.get("confusions", []),
        "conditions": spec.get("conditions", {"ecosystemes": [], "altitude_m": [], "facteurs": []}),
        "prevention": spec["prevention"] + [PREVENTION_GENERIQUE_FIN],
        "lutte_chimique": spec.get("lutte_chimique_override") or {"statut": "a_completer_liste_DPV", "produits": []},
        "sources": resoudre_sources(ids_sources, sources_taxonomie),
        "taxonomy_ids": taxonomy_ids,
        "validation": {"par": None, "date": None, "statut": "brouillon"},
    }
    return fiche


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    taxonomie = charger_taxonomie()
    index = index_par_id(taxonomie)
    sources_taxonomie = taxonomie.get("sources", {})

    collisions = sorted({spec["id"] for spec in FICHES} & set(FICHES_MANUELLES))
    if collisions:
        sys.exit(
            f"fiche(s) écrite(s) à la main déjà présente(s) dans FICHES : {', '.join(collisions)} — "
            "les générer écraserait un contenu plus riche (voir knowledge/fiches/README.md)"
        )

    FICHES_DIR.mkdir(parents=True, exist_ok=True)
    ecrites = 0
    for spec in FICHES:
        for tid in spec["taxonomy_ids"]:
            if tid not in index:
                sys.exit(f"id de taxonomie inconnu : {tid} (fiche {spec['id']})")
        fiche = construire_fiche(spec, index, sources_taxonomie)
        chemin = FICHES_DIR / f"{spec['id']}.json"
        chemin.write_text(json.dumps(fiche, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        ecrites += 1

    print(f"{ecrites} fiche(s) écrite(s) dans {FICHES_DIR.relative_to(ROOT).as_posix()}")
    print("(carence_azote, carence_phosphore, carence_potassium restent écrites à la main : contenu plus riche que ce générateur ne produit)")

    toutes = sorted(FICHES_DIR.glob("*.json"), key=lambda p: p.stem)
    bundle = [json.loads(p.read_text(encoding="utf-8")) for p in toutes]
    BUNDLE.parent.mkdir(parents=True, exist_ok=True)
    BUNDLE.write_text(json.dumps(bundle, ensure_ascii=False), encoding="utf-8")
    print(f"{len(bundle)} fiche(s) regroupées dans {BUNDLE.relative_to(ROOT).as_posix()} (asset Flutter, P5.3)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
