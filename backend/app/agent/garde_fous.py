"""
Garde-fous de l'agent de conseil (ADR-012).

Tous déterministes : aucun ne dépend du jugement du modèle, qui s'est montré
capable de classer « Quel fongicide pour ma rizière ? » comme une simple
question sur la parcelle.

Entrée : urgence de santé humaine, tentative d'injection, salutation, demande
de produit ou de dose, données personnelles.
Sortie : produit ou dose (ADR-005), maladie citée sans preuve (ancrage),
diagnostic présenté comme certain (ADR-006).
"""

from __future__ import annotations

import re

from app.agent.correspondances import TERMES_PAR_PROBLEME, normaliser, termes_cites
from app.rag.moteur import MOTIF_PRODUIT_OU_DOSAGE

# --- Entrée -----------------------------------------------------------------

_PRODUITS = r"(produit|pesticide|insecticide|herbicide|fongicide|poison|engrais|traitement|bouteille|bidon|fanafody|pestisida|insektisida|zezika|poizina)"

_URGENCE_FORTE = re.compile(
    r"\b(intoxi\w*|empoisonn\w*|s'est empoisonn\w*|convulsion\w*|evanoui\w*|ne respire plus"
    r"|n'arrive (plus )?a respirer|voapoizina|tsy miaina intsony)"
)
_URGENCE_AVEC_PRODUIT = re.compile(
    r"\b(avale\w*|a bu|ont bu|j'ai bu|vomi\w*|malaise|brulure\w*|brule la peau|dans les yeux"
    r"|nitelina|nisotro|mandoa|torana|sempotra|may ny hoditra)\b"
)
_PRODUITS_RE = re.compile(r"\b" + _PRODUITS)

# Vise les consignes de l'assistant (« tes règles », « instructions précédentes »),
# pas celles d'un technicien : « j'ai oublié les consignes du technicien » passe.
_INJECTION = re.compile(
    r"\b(ignore|oublie|ne tiens? (plus )?pas compte de)\w*\W+(toutes?\W+)?(tes|vos)\W+(\w+\W+)?(instructions?|regles?|consignes?|directives?)\b"
    r"|\b(ignore|oublie|ne tiens? (plus )?pas compte de)\w*\W+(toutes?\W+)?(les|ces)\W+(instructions?|regles?|consignes?|directives?)\W+(precedentes?|initiales?|anterieures?|du systeme)\b"
    r"|\b(message|prompt|invite|consigne)s? (du )?systeme\b"
    r"|\bsystem prompt\b"
    r"|\btu es (maintenant|desormais|a present)\b"
    r"|\b(mode developpeur|developer mode|jailbreak)\b"
    r"|\b(revele|affiche|montre|repete|donne)\w*(\W+moi)?\W+(tes|vos)\W+(instructions?|consignes?|prompt|regles?)\b"
)

_SALUTATION = re.compile(
    r"^(bonjour|bonsoir|salut|coucou|hello|manao ahoana|salama|akory)"
    r"( (a vous|a toi|tout le monde|tompoko|daholo|e))?[\s!.,?]*$"
)

_DEMANDE_TRAITEMENT = re.compile(
    r"\b(quel(le)?s? (produit|traitement|remede)|dose|dosage|combien de (kg|kilos?|litres?|ml|grammes?|sachets?|bidons?)"
    r"|pulveris\w*|traiter avec|fanafody|fatra|firy kilao)\b"
)

_TELEPHONE = re.compile(r"(?<!\d)(?:\+|00)?\d(?:[\s.-]?\d){8,}(?!\d)")
_COURRIEL = re.compile(r"[\w.+-]+@[\w-]+(?:\.[\w-]+)+")


def detecter_urgence_sante(texte: str) -> bool:
    texte = normaliser(texte)
    if _URGENCE_FORTE.search(texte):
        return True
    return bool(_URGENCE_AVEC_PRODUIT.search(texte) and _PRODUITS_RE.search(texte))


def detecter_injection(texte: str) -> bool:
    return _INJECTION.search(normaliser(texte)) is not None


def est_salutation(texte: str) -> bool:
    texte = normaliser(texte).strip()
    return len(texte) <= 30 and _SALUTATION.match(texte) is not None


def detecter_demande_traitement(texte: str) -> bool:
    normalise = normaliser(texte)
    return bool(MOTIF_PRODUIT_OU_DOSAGE.search(texte) or _DEMANDE_TRAITEMENT.search(normalise))


def masquer_donnees_personnelles(texte: str) -> tuple[str, bool]:
    """Masque numéros de téléphone et courriels, avant tout envoi à Google et tout stockage."""
    masque = _COURRIEL.sub("[courriel masqué]", texte)
    masque = _TELEPHONE.sub("[numéro masqué]", masque)
    return masque, masque != texte


# --- Sortie -----------------------------------------------------------------

# Pas « c'est bien » (« c'est bien de drainer ») ni « est atteinte de » seul, qui
# décrivent sans affirmer : seulement les tournures qui tranchent pour la plante
# de l'agriculteur.
_CERTITUDE = re.compile(
    r"\b(certainement|surement|sans aucun doute|sans hesitation"
    r"|c'est (certain|clairement|forcement)|il s'agit (certainement|surement|forcement|sans doute)"
    r"|diagnostic (confirme|certain|definitif)|j'en suis certaine?|je (vous )?confirme"
    r"|(votre|vos|ton|ta|tes) (\w+ ){0,3}?(est|sont) (bien |certainement |surement )?atteinte?s? (de|par)"
    r"|azo antoka|tsy misy isalasalana|tsy isalasalana)\b"
)
# « sûr » perd son accent à la normalisation et se confond avec « sur » :
# « le diagnostic sur votre culture », « c'est sur la feuille ». Cherché accentué.
_CERTITUDE_ACCENTUEE = re.compile(r"\b(diagnostic sûr|c'est sûr|à coup sûr|j'en suis sûre?)\b")


# Le modèle reprend la consigne de prudence : « non un diagnostic certain »,
# « ce n'est pas un diagnostic sûr ». Une négation juste avant annule la tournure.
_NEGATION = re.compile(r"\b(pas|non|jamais|ni|sans|aucune?|tsy)\b")


def _affirme(motif: re.Pattern, texte: str) -> bool:
    for trouve in motif.finditer(texte):
        if not _NEGATION.search(texte[max(0, trouve.start() - 25) : trouve.start()]):
            return True
    return False


def affirme_un_diagnostic(texte: str) -> bool:
    accentue = texte.lower().replace("’", "'")
    return _affirme(_CERTITUDE, normaliser(texte)) or _affirme(_CERTITUDE_ACCENTUEE, accentue)


def fiches_mentionnees(texte: str, fiches: dict) -> list[str]:
    """Fiches consultées que la réponse nomme vraiment (par son vocabulaire ou son nom)."""
    termes = termes_cites(texte)
    normalise = normaliser(texte)
    mentionnees = []
    for fiche_id, fiche in fiches.items():
        tete = normaliser(fiche.nom_fr.split(" (")[0])
        if (
            termes & set(TERMES_PAR_PROBLEME.get(fiche_id, []))
            or (len(tete) >= 6 and tete in normalise)
            or (fiche.nom_mg and normaliser(fiche.nom_mg) in normalise)
        ):
            mentionnees.append(fiche_id)
    return mentionnees


def termes_non_ancres(texte: str, preuves: str) -> set[str]:
    """Maladies citées dans la réponse mais absentes de tout ce que les outils ont renvoyé."""
    return termes_cites(texte) - termes_cites(preuves)


# --- Messages fixes -----------------------------------------------------------

MESSAGES_AGENT: dict[str, dict[str, str]] = {
    "fr": {
        "urgence_sante": (
            "Urgence : emmenez tout de suite la personne au centre de santé le plus proche, "
            "avec l'emballage du produit. N'attendez pas. AgriMada ne peut pas aider davantage."
        ),
        "refus_injection": (
            "Je réponds seulement aux questions sur la santé du riz, à partir des fiches AgriMada."
        ),
        "salutation": (
            "Bonjour ! Posez-moi une question sur la santé de votre riz, vos parcelles ou vos derniers scans."
        ),
        "modele_experimental": (
            "Les pistes de scan viennent d'un modèle expérimental : elles doivent être confirmées "
            "par un technicien agricole."
        ),
        "repli_pistes": (
            "D'après les fiches AgriMada, les pistes à vérifier sont : {pistes}. Ce ne sont que des "
            "pistes, pas un diagnostic : montrez la plante à un technicien agricole avant d'agir."
        ),
    },
    "mg": {
        "urgence_sante": (
            "Maika : ataovy any amin'ny toeram-pitsaboana akaiky indrindra avy hatrany ilay olona, "
            "miaraka amin'ny fonon'ilay vokatra. Aza miandry. Tsy afaka manampy bebe kokoa ny AgriMada."
        ),
        "refus_injection": (
            "Ny fanontaniana momba ny fahasalaman'ny vary ihany no valiako, araka ny fiche AgriMada."
        ),
        "salutation": (
            "Manao ahoana ! Manontania ahy momba ny fahasalaman'ny vary, ny tanimbarinao na ny sary nalainao farany."
        ),
        "modele_experimental": (
            "Avy amin'ny milina mbola andrana ireo soso-kevitra avy amin'ny sary : tsy maintsy "
            "hamarinin'ny teknisiana momba ny fambolena."
        ),
        "repli_pistes": (
            "Araka ny fiche AgriMada, ireto no mety ho izy : {pistes}. Tsy fitiliana marina izany : "
            "asehoy teknisiana momba ny fambolena ny vary alohan'ny hanaovana zavatra."
        ),
    },
}
