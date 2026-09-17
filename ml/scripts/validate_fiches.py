#!/usr/bin/env python3
"""Valide les fiches de connaissance contre knowledge/schema.json (P5.1).

Vérifications :
1. Chaque knowledge/fiches/*.json respecte le schéma (structure, pas de
   produit/dosage dans lutte_chimique, etc.).
2. Cohérence interne : les confusions pointent vers des fiches existantes, et
   aucun texte de remplacement (« à traduire ») n'est prêt à être affiché.
3. Le bundle embarqué assets/knowledge/fiches.json est bien le reflet exact
   des fiches source : c'est lui que l'app charge, pas knowledge/fiches/.
4. Les codes d'organe du schéma correspondent à l'enum Organe de l'app :
   sinon les symptômes d'un organe inconnu disparaîtraient silencieusement.
5. Garde-fou du plan : « aucune fiche au statut brouillon n'est embarquée
   dans l'app ». Tant que P5.3 n'existe pas, lib/ ne doit référencer aucun id
   de fiche — ce script échouera le jour où quelqu'un embarque une fiche
   encore brouillon sans avoir mis à jour ce garde-fou.

Usage :
    ml/.venv/Scripts/python ml/scripts/validate_fiches.py
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

import jsonschema

ROOT = Path(__file__).resolve().parents[2]
SCHEMA = ROOT / "knowledge" / "schema.json"
FICHES_DIR = ROOT / "knowledge" / "fiches"
BUNDLE = ROOT / "assets" / "knowledge" / "fiches.json"
ORGANE_DART = ROOT / "lib" / "features" / "scan" / "domain" / "entities" / "organe.dart"
LIB_DIR = ROOT / "lib"
ARB_FR = ROOT / "assets" / "l10n" / "app_fr.arb"
CLE_DIVULGATION = "guidesDraftBadge"
# Marqueur des textes laissés en attente de traduction : ils ne doivent jamais
# atteindre l'écran d'un agriculteur (l'app affiche le français à la place).
MARQUEUR_A_TRADUIRE = "à traduire"


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
    fichiers = sorted(FICHES_DIR.glob("*.json"))
    if not fichiers:
        sys.exit(f"Aucune fiche trouvée dans {FICHES_DIR}")

    erreurs: list[str] = []
    brouillons: list[str] = []
    ids_vus: set[str] = set()
    fiches: list[dict] = []

    for chemin in fichiers:
        fiche = json.loads(chemin.read_text(encoding="utf-8"))
        try:
            jsonschema.validate(fiche, schema)
        except jsonschema.ValidationError as erreur:
            erreurs.append(f"{chemin.name} : {erreur.message} (chemin : {list(erreur.absolute_path)})")
            continue

        if fiche["id"] != chemin.stem:
            erreurs.append(f"{chemin.name} : id {fiche['id']!r} ne correspond pas au nom du fichier")
        if fiche["id"] in ids_vus:
            erreurs.append(f"{chemin.name} : id {fiche['id']!r} déjà utilisé par une autre fiche")
        ids_vus.add(fiche["id"])
        fiches.append(fiche)

        if fiche["validation"]["statut"] == "brouillon":
            brouillons.append(fiche["id"])

    if erreurs:
        print(f"{len(erreurs)} erreur(s) de schéma :")
        for erreur in erreurs:
            print(f"  - {erreur}")
        return 1

    print(f"{len(fichiers)} fiche(s) valides contre {SCHEMA.relative_to(ROOT).as_posix()}.")
    print(f"{len(brouillons)} en statut brouillon (aucune validée par un agronome pour l'instant).")

    # Le schéma type `confusions[].fiche` en simple chaîne : rien ne dit qu'elle
    # désigne une fiche existante. Une référence morte ne casse rien tant que
    # l'app n'affiche que la question, mais elle piège le jour où on rendra la
    # confusion cliquable (le cas s'était produit : un id de taxonomie glissé à
    # la place d'un id de fiche).
    for fiche in fiches:
        for confusion in fiche["confusions"]:
            if confusion["fiche"] not in ids_vus:
                erreurs.append(
                    f"{fiche['id']} : confusion vers {confusion['fiche']!r}, qui n'est pas un id de fiche"
                )

    for fiche in fiches:
        textes = [confusion["question"].get("mg") or "" for confusion in fiche["confusions"]]
        textes += [fiche["noms"].get("mg") or ""]
        if any(MARQUEUR_A_TRADUIRE in texte for texte in textes):
            erreurs.append(
                f"{fiche['id']} : texte de remplacement {MARQUEUR_A_TRADUIRE!r} en malgache — "
                "mettre null plutôt qu'un texte affichable tant que la traduction manque"
            )

    # Parité schéma / enum Dart : Fiche.fromJson ignore en silence un organe
    # qu'Organe.fromCode ne connaît pas, donc un code ajouté d'un seul côté
    # ferait disparaître des symptômes sans erreur ni test rouge.
    codes_schema = set(schema["properties"]["organes"]["propertyNames"]["enum"])
    codes_dart = set(re.findall(r"^\s+\w+\('([a-z_]+)'", ORGANE_DART.read_text(encoding="utf-8"), re.MULTILINE))
    if codes_schema != codes_dart:
        erreurs.append(
            f"codes d'organe désynchronisés entre {SCHEMA.relative_to(ROOT).as_posix()} et "
            f"{ORGANE_DART.relative_to(ROOT).as_posix()} : {sorted(codes_schema ^ codes_dart)}"
        )

    # L'app ne lit pas knowledge/fiches/ mais le bundle : le valider seul
    # laisserait passer un bundle périmé ou modifié à la main.
    if not BUNDLE.exists():
        erreurs.append(f"{BUNDLE.relative_to(ROOT).as_posix()} absent : lancer ml/scripts/generate_fiches.py")
    else:
        bundle = json.loads(BUNDLE.read_text(encoding="utf-8"))
        if bundle != fiches:
            erreurs.append(
                f"{BUNDLE.relative_to(ROOT).as_posix()} ne correspond plus aux fiches source : "
                "relancer ml/scripts/generate_fiches.py"
            )

    if erreurs:
        print(f"\n{len(erreurs)} erreur(s) de cohérence :")
        for erreur in erreurs:
            print(f"  - {erreur}")
        return 1

    print("Références croisées, codes d'organe et bundle embarqué cohérents.")

    # Garde-fou (révisé pour P5.3, voir ADR-010) : la version stricte de P5.1
    # (« aucune fiche brouillon embarquée ») supposait des fiches validées
    # avant tout affichage. P5.3 les embarque volontairement, brouillon
    # compris, à condition de le dire à l'écran. On vérifie donc que la
    # divulgation existe et qu'elle est réellement utilisée, pas seulement
    # déclarée — pas qu'aucune fiche brouillon n'apparaît.
    sources_dart = [
        f.read_text(encoding="utf-8", errors="ignore") for f in LIB_DIR.rglob("*.dart")
    ] if LIB_DIR.is_dir() else []
    embarque = any("assets/knowledge/fiches.json" in source for source in sources_dart)

    if not embarque:
        print("assets/knowledge/fiches.json n'est référencé nulle part dans lib/ pour l'instant : rien à vérifier.")
        return 0

    if not brouillons:
        print("Fiches embarquées, mais aucune n'est brouillon : rien à divulguer.")
        return 0

    arb = json.loads(ARB_FR.read_text(encoding="utf-8"))
    if CLE_DIVULGATION not in arb:
        print(f"\nFiches brouillon embarquées mais {ARB_FR.relative_to(ROOT).as_posix()} n'a pas la clé {CLE_DIVULGATION!r} (mention « brouillon, non validé »).")
        return 1

    utilisee = any(CLE_DIVULGATION in source for source in sources_dart)
    if not utilisee:
        print(f"\nLa clé ARB {CLE_DIVULGATION!r} existe mais n'est utilisée nulle part dans lib/ : la divulgation n'est pas affichée.")
        return 1

    print(f"Fiches brouillon embarquées, divulgation {CLE_DIVULGATION!r} présente et utilisée : garde-fou respecté.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
