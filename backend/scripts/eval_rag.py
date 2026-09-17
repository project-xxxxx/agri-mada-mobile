#!/usr/bin/env python3
"""Évalue le conseil sur les 150 cas validés par l'équipe (tâche P5.5, ADR-011).

Deux modes :
- --recherche-seule : vectorise les questions et mesure si la bonne fiche
  remonte, puis propose un seuil de similarité. Trois appels d'API seulement.
- complet (par défaut) : passe chaque cas dans le moteur du conseil, génération
  comprise, et vérifie l'abstention, la sécurité (aucun produit ni dose) et les
  avertissements. Écrit aussi un CSV des réponses à relire par l'équipe.

Les vérifications automatiques ne jugent pas si une réponse est juste : elles
mesurent ce qui se vérifie mécaniquement. La justesse se lit dans le CSV.

Usage (depuis backend/, GEMINI_API_KEY dans backend/.env) :
    venv/Scripts/python scripts/eval_rag.py --recherche-seule
    venv/Scripts/python scripts/eval_rag.py
"""

from __future__ import annotations

import argparse
import csv
import json
import statistics
import sys
import time
from datetime import date
from pathlib import Path

import yaml

BACKEND_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BACKEND_DIR))

RACINE = BACKEND_DIR.parent
CAS = RACINE / "knowledge" / "eval" / "cas_rag.yaml"
RAPPORTS = RACINE / "ml" / "reports"
# Résultats enregistrés au fil de l'eau : une panne Google en cours de route ne
# fait plus perdre les cas déjà évalués (--reprendre).
SAUVEGARDE = RAPPORTS / "eval_rag_en_cours.jsonl"
TYPES = {"contenu", "confusion", "produit_dosage", "hors_corpus", "hors_sujet"}
TYPES_ABSTENTION = {"hors_corpus", "hors_sujet"}
TAILLE_LOT = 50


def doit_repondre(cas: dict) -> bool:
    """Un cas « produit_dosage » sur une fiche connue doit retrouver cette fiche (puis refuser la dose)."""
    return cas["type"] in {"contenu", "confusion"} or (
        cas["type"] == "produit_dosage" and bool(cas["fiches_attendues"])
    )


def charger_cas(ids_fiches: set[str]) -> list[dict]:
    donnees = yaml.safe_load(CAS.read_text(encoding="utf-8"))
    cas = donnees["cas"]
    erreurs = []
    vus = set()
    for c in cas:
        c.setdefault("fiches_attendues", [])
        if c["id"] in vus:
            erreurs.append(f"{c['id']} : identifiant en double")
        vus.add(c["id"])
        if c["type"] not in TYPES:
            erreurs.append(f"{c['id']} : type inconnu {c['type']!r}")
        if c["langue"] not in ("fr", "mg"):
            erreurs.append(f"{c['id']} : langue inconnue {c['langue']!r}")
        inconnues = set(c["fiches_attendues"]) - ids_fiches
        if inconnues:
            erreurs.append(f"{c['id']} : fiches inconnues {sorted(inconnues)}")
        if c["type"] in {"contenu", "confusion"} and not c["fiches_attendues"]:
            erreurs.append(f"{c['id']} : un cas {c['type']} doit attendre au moins une fiche")
        if c["type"] in TYPES_ABSTENTION and c["fiches_attendues"]:
            erreurs.append(f"{c['id']} : un cas {c['type']} n'attend aucune fiche")
    if erreurs:
        sys.exit("Cas d'évaluation invalides :\n  - " + "\n  - ".join(erreurs))
    return cas


def avec_reessais(appel):
    from app.rag.gemini import CODES_A_REESSAYER, ErreurFournisseur

    for tentative in range(6):
        try:
            return appel()
        except ErreurFournisseur as erreur:
            if erreur.code not in CODES_A_REESSAYER or tentative == 5:
                raise
            attente = min(120, 10 * 2**tentative)
            print(f"  {erreur} — nouvel essai dans {attente} s")
            time.sleep(attente)


def fiches_classees(resultats) -> list[str]:
    ordre: list[str] = []
    for resultat in resultats:
        if resultat.extrait.fiche_id not in ordre:
            ordre.append(resultat.extrait.fiche_id)
    return ordre


def rang_attendu(cas: dict, classees: list[str]) -> int | None:
    rangs = [classees.index(f) + 1 for f in cas["fiches_attendues"] if f in classees]
    return min(rangs) if rangs else None


def pct(numerateur: int, denominateur: int) -> str:
    if denominateur == 0:
        return "—"
    return f"{100 * numerateur / denominateur:.1f} % ({numerateur}/{denominateur})"


def balayer_seuils(lignes: list[dict]) -> tuple[float, list[tuple[float, float, float, float]]]:
    positifs = [l["meilleur_score"] for l in lignes if doit_repondre(l["cas"])]
    negatifs = [l["meilleur_score"] for l in lignes if l["cas"]["type"] in TYPES_ABSTENTION]
    courbe = []
    for centieme in range(30, 91):
        seuil = centieme / 100
        sensibilite = sum(s >= seuil for s in positifs) / len(positifs)
        specificite = sum(s < seuil for s in negatifs) / len(negatifs)
        courbe.append((seuil, sensibilite, specificite, (sensibilite + specificite) / 2))
    # À équilibre égal, le seuil le plus haut : mieux vaut renvoyer vers un technicien qu'inventer.
    meilleur = max(courbe, key=lambda point: (round(point[3], 6), point[0]))
    return meilleur[0], courbe


def section_recherche(lignes: list[dict], seuil_config: float, top_k: int) -> list[str]:
    avec_fiche = [l for l in lignes if l["cas"]["fiches_attendues"]]
    sortie = ["## 1. Recherche : la bonne fiche remonte-t-elle ?", ""]
    sortie.append(f"Sur les {len(avec_fiche)} cas qui attendent au moins une fiche (rang de la première fiche attendue parmi les fiches des {top_k} extraits les plus proches) :")
    sortie.append("")
    sortie.append("| Périmètre | Top 1 | Top 3 | Top 5 |")
    sortie.append("|---|---|---|---|")
    perimetres = [("Tous", avec_fiche)]
    perimetres += [(f"Langue {langue}", [l for l in avec_fiche if l["cas"]["langue"] == langue]) for langue in ("fr", "mg")]
    perimetres += [(f"Type {t}", [l for l in avec_fiche if l["cas"]["type"] == t]) for t in ("contenu", "confusion", "produit_dosage")]
    for nom, groupe in perimetres:
        cellules = [pct(sum(1 for l in groupe if l["rang"] is not None and l["rang"] <= k), len(groupe)) for k in (1, 3, 5)]
        sortie.append(f"| {nom} | " + " | ".join(cellules) + " |")

    confusions = [l for l in lignes if l["cas"]["type"] == "confusion"]
    completes = sum(1 for l in confusions if set(l["cas"]["fiches_attendues"]) <= set(l["classees"]))
    sortie += ["", f"Confusions dont **les deux** fiches remontent : {pct(completes, len(confusions))}.", ""]

    positifs = [l["meilleur_score"] for l in lignes if doit_repondre(l["cas"])]
    negatifs = [l["meilleur_score"] for l in lignes if l["cas"]["type"] in TYPES_ABSTENTION]
    if not positifs or not negatifs:
        return sortie + ["Seuil non calculé : il faut des cas à répondre et des cas à refuser.", ""]
    seuil_propose, courbe = balayer_seuils(lignes)
    sortie += [
        "### Seuil de similarité",
        "",
        f"Meilleure similarité par question — cas qui doivent obtenir une réponse : moyenne {statistics.mean(positifs):.3f}, min {min(positifs):.3f} ; "
        f"cas hors corpus ou hors sujet : moyenne {statistics.mean(negatifs):.3f}, max {max(negatifs):.3f}.",
        "",
        "| Seuil | Répond quand il faut | S'abstient quand il faut | Moyenne |",
        "|---|---|---|---|",
    ]
    retenus = {round(seuil_propose, 2), round(seuil_config, 2)}
    retenus |= {round(seuil_propose + d, 2) for d in (-0.1, -0.05, 0.05, 0.1)}
    for seuil, sens, spec, moyenne in courbe:
        if round(seuil, 2) in retenus:
            marque = " ← proposé" if round(seuil, 2) == round(seuil_propose, 2) else ""
            marque += " ← configuré" if round(seuil, 2) == round(seuil_config, 2) else ""
            sortie.append(f"| {seuil:.2f}{marque} | {100 * sens:.1f} % | {100 * spec:.1f} % | {100 * moyenne:.1f} % |")
    sortie += [
        "",
        f"Seuil proposé : **{seuil_propose:.2f}** (configuré : {seuil_config:.2f}). Il est choisi sur ces mêmes 150 cas : "
        "la mesure est donc optimiste, à reconfirmer sur des questions réelles.",
        "",
    ]

    rates = [l for l in avec_fiche if l["rang"] is None or l["rang"] > 3]
    sortie.append(f"### Cas où la fiche attendue n'est pas dans le top 3 ({len(rates)})")
    sortie.append("")
    if rates:
        sortie.append("| Cas | Langue | Question | Attendue | Obtenues (top 3) | Similarité |")
        sortie.append("|---|---|---|---|---|---|")
        for l in rates:
            c = l["cas"]
            sortie.append(
                f"| {c['id']} | {c['langue']} | {c['question']} | {', '.join(c['fiches_attendues'])} | "
                f"{', '.join(l['classees'][:3])} | {l['meilleur_score']:.3f} |"
            )
    else:
        sortie.append("Aucun.")
    sortie.append("")
    return sortie


def section_reponses(lignes: list[dict]) -> list[str]:
    sortie = ["## 2. Réponses générées", ""]
    a_repondre = [l for l in lignes if l["cas"]["type"] in {"contenu", "confusion"}]
    a_refuser = [l for l in lignes if l["cas"]["type"] in TYPES_ABSTENTION]
    dosage = [l for l in lignes if l["cas"]["type"] == "produit_dosage"]
    trouvees = [l for l in lignes if l["trouve"]]
    en_malgache = [l for l in lignes if l["cas"]["langue"] == "mg"]

    sortie += [
        "| Mesure | Résultat |",
        "|---|---|",
        f"| Répond aux cas contenu et confusion | {pct(sum(l['trouve'] for l in a_repondre), len(a_repondre))} |",
        f"| S'abstient sur hors corpus | {pct(sum(not l['trouve'] for l in a_refuser if l['cas']['type'] == 'hors_corpus'), sum(1 for l in a_refuser if l['cas']['type'] == 'hors_corpus'))} |",
        f"| S'abstient sur hors sujet | {pct(sum(not l['trouve'] for l in a_refuser if l['cas']['type'] == 'hors_sujet'), sum(1 for l in a_refuser if l['cas']['type'] == 'hors_sujet'))} |",
        f"| **Produit ou dose dans la réponse finale (doit être 0)** | **{sum(l['violation_finale'] for l in lignes)}** sur {len(lignes)} |",
        f"| Réponses du modèle remplacées par le filtre | {pct(sum(l['filtre'] for l in lignes), len(lignes))} (dont {sum(l['filtre'] for l in dosage)} sur les {len(dosage)} cas produit_dosage) |",
        f"| Réponses signalées « automatique » et « brouillon » | {pct(sum({'reponse_automatique', 'fiches_brouillon'} <= set(l['codes']) for l in trouvees), len(trouvees))} |",
        f"| Réponses en malgache signalées « non relu » | {pct(sum('malgache_non_relu' in l['codes'] for l in en_malgache), len(en_malgache))} |",
    ]
    durees = sorted(l["duree"] for l in lignes)
    entree = sum(l["jetons_entree"] or 0 for l in lignes)
    sortie_jetons = sum(l["jetons_sortie"] or 0 for l in lignes)
    generees = sum(1 for l in lignes if l["jetons_entree"])
    sortie += [
        f"| Durée par question (médiane / 95e centile) | {statistics.median(durees):.2f} s / {durees[int(0.95 * (len(durees) - 1))]:.2f} s |",
        f"| Jetons (entrée / sortie), {generees} générations | {entree} / {sortie_jetons} |",
        "",
    ]

    echecs = [l for l in a_repondre if not l["trouve"]] + [l for l in a_refuser if l["trouve"]]
    sortie.append(f"### Décisions de répondre ou de s'abstenir erronées ({len(echecs)})")
    sortie.append("")
    if echecs:
        sortie.append("| Cas | Type | Langue | Question | Répondu | Similarité |")
        sortie.append("|---|---|---|---|---|---|")
        for l in echecs:
            c = l["cas"]
            sortie.append(f"| {c['id']} | {c['type']} | {c['langue']} | {c['question']} | {'oui' if l['trouve'] else 'non'} | {l['meilleur_score']:.3f} |")
    else:
        sortie.append("Aucune.")
    sortie.append("")
    return sortie


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--recherche-seule", action="store_true", help="mesurer la recherche sans générer de réponse")
    parser.add_argument("--pause", type=float, default=0.0, help="secondes d'attente entre deux générations (quota Google)")
    parser.add_argument("--limite", type=int, default=None, help="n'évaluer que les N premiers cas (essai)")
    parser.add_argument("--reprendre", action="store_true", help="reprendre une évaluation complète interrompue")
    args = parser.parse_args()

    from app.core.config import settings
    from app.rag.gemini import ClientGemini
    from app.rag.index import IndexFiches
    from app.rag.moteur import MoteurConseil, contient_produit_ou_dosage

    if not settings.GEMINI_API_KEY:
        sys.exit("GEMINI_API_KEY absente de backend/.env.")

    index = IndexFiches.charger()
    client = ClientGemini(
        cle_api=settings.GEMINI_API_KEY,
        modele_generation=settings.RAG_MODELE_GENERATION,
        modele_embedding=index.modele_embedding,
        dimensions=index.dimensions,
        delai_secondes=settings.RAG_DELAI_SECONDES,
        max_jetons_reponse=settings.RAG_MAX_JETONS_REPONSE,
    )
    moteur = MoteurConseil(index, client, top_k=settings.RAG_TOP_K, seuil=settings.RAG_SEUIL_SIMILARITE)

    cas = charger_cas(set(index.fiches))[: args.limite]
    print(f"{len(cas)} cas chargés depuis {CAS.relative_to(RACINE).as_posix()}.")

    vecteurs: list[list[float]] = []
    for debut in range(0, len(cas), TAILLE_LOT):
        lot = [c["question"] for c in cas[debut : debut + TAILLE_LOT]]
        vecteurs += avec_reessais(lambda lot=lot: client.vectoriser(lot, type_tache="question"))
    print(f"{len(vecteurs)} questions vectorisées.")

    deja_faits: dict[str, dict] = {}
    if not args.recherche_seule:
        if args.reprendre and SAUVEGARDE.exists():
            for texte in SAUVEGARDE.read_text(encoding="utf-8").splitlines():
                enregistre = json.loads(texte)
                deja_faits[enregistre.pop("id")] = enregistre
            print(f"{len(deja_faits)} cas repris de {SAUVEGARDE.relative_to(RACINE).as_posix()}.")
        elif SAUVEGARDE.exists():
            SAUVEGARDE.unlink()

    lignes = []
    for numero, (c, vecteur) in enumerate(zip(cas, vecteurs), start=1):
        if c["id"] in deja_faits:
            lignes.append({**deja_faits[c["id"]], "cas": c})
            continue
        resultats = index.rechercher(vecteur, settings.RAG_TOP_K)
        classees = fiches_classees(resultats)
        ligne = {
            "cas": c,
            "meilleur_score": resultats[0].score,
            "classees": classees,
            "rang": rang_attendu(c, classees),
        }
        if not args.recherche_seule:
            debut = time.perf_counter()
            reponse = avec_reessais(
                lambda c=c, vecteur=vecteur: moteur.repondre_avec_vecteur(c["question"], c["langue"], vecteur)
            )
            generation = reponse.generation
            ligne.update(
                trouve=reponse.trouve,
                reponse=reponse.reponse,
                fiches_citees=[f.id for f in reponse.fiches],
                codes=[a.code for a in reponse.avertissements],
                filtre=reponse.filtre_securite,
                violation_finale=contient_produit_ou_dosage(reponse.reponse),
                reponse_brute=generation.texte if generation else "",
                jetons_entree=generation.jetons_entree if generation else None,
                jetons_sortie=generation.jetons_sortie if generation else None,
                duree=time.perf_counter() - debut,
            )
            print(f"  [{numero}/{len(cas)}] {c['id']} {'répond' if reponse.trouve else 'abstention'}{' (filtré)' if reponse.filtre_securite else ''}")
            with SAUVEGARDE.open("a", encoding="utf-8") as handle:
                resultat = {cle: valeur for cle, valeur in ligne.items() if cle != "cas"}
                handle.write(json.dumps({"id": c["id"], **resultat}, ensure_ascii=False) + "\n")
            if args.pause:
                time.sleep(args.pause)
        lignes.append(ligne)

    jour = date.today().isoformat()
    mode = "recherche seule" if args.recherche_seule else "complet"
    contenu = [
        f"# Évaluation du conseil à partir des fiches — {jour} ({mode})",
        "",
        "Tâches P5.4 et P5.5, ADR-011. Généré par `backend/scripts/eval_rag.py`.",
        "",
        f"- Cas : {len(cas)} (`knowledge/eval/cas_rag.yaml`), validés par l'équipe AgriMada, sans relecture agronomique (ADR-011).",
        f"- Index : {len(index.extraits)} extraits de {len(index.fiches)} fiches, `{index.modele_embedding}`, {index.dimensions} dimensions.",
        f"- Génération : `{settings.RAG_MODELE_GENERATION}`, top {settings.RAG_TOP_K}, seuil {settings.RAG_SEUIL_SIMILARITE:.2f}.",
        "- Limites : les questions en malgache ont été écrites sans locuteur natif ; les vérifications automatiques "
        "ne jugent pas la justesse d'une réponse (voir le CSV des réponses).",
        "",
    ]
    contenu += section_recherche(lignes, settings.RAG_SEUIL_SIMILARITE, settings.RAG_TOP_K)

    RAPPORTS.mkdir(parents=True, exist_ok=True)
    if args.recherche_seule:
        chemin_rapport = RAPPORTS / f"eval_rag_recherche_{jour}.md"
    else:
        contenu += section_reponses(lignes)
        chemin_csv = RAPPORTS / f"eval_rag_reponses_{jour}.csv"
        with chemin_csv.open("w", newline="", encoding="utf-8-sig") as handle:
            ecrivain = csv.writer(handle, delimiter=";")
            ecrivain.writerow([
                "id", "type", "langue", "question", "fiches_attendues", "fiches_citees",
                "repondu", "filtre_securite", "reponse", "reponse_modele_avant_filtre",
                "verdict_equipe", "commentaire",
            ])
            for l in lignes:
                c = l["cas"]
                ecrivain.writerow([
                    c["id"], c["type"], c["langue"], c["question"], ",".join(c["fiches_attendues"]),
                    ",".join(l["fiches_citees"]), "oui" if l["trouve"] else "non",
                    "oui" if l["filtre"] else "non", l["reponse"],
                    # Pour juger un éventuel faux positif du filtre produits/doses.
                    l["reponse_brute"] if l["filtre"] else "",
                    "", "",
                ])
        contenu += [f"Réponses à relire : `{chemin_csv.relative_to(RACINE).as_posix()}` (colonnes `verdict_equipe` et `commentaire`).", ""]
        chemin_rapport = RAPPORTS / f"eval_rag_{jour}.md"

    chemin_rapport.write_text("\n".join(contenu), encoding="utf-8")
    if not args.recherche_seule and SAUVEGARDE.exists():
        SAUVEGARDE.unlink()
    print(f"Rapport écrit : {chemin_rapport.relative_to(RACINE).as_posix()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
