"""
Fonctions CRUD - Opérations de base de données.
Create, Read, Update, Delete pour User, Parcelle, Diagnostic et RefreshToken.
"""

import json
from datetime import date, datetime, timedelta
from typing import List, Optional, Tuple
from sqlalchemy import delete, select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.security import (
    generate_refresh_token,
    get_password_hash,
    hash_token,
    verify_password,
)
from app.models.user import User
from app.models.parcelle import Parcelle
from app.models.diagnostic import Diagnostic
from app.models.diagnostic_session import DiagnosticSession, Observation
from app.models.refresh_token import RefreshToken, utcnow_naive
from app.models.trace_agent import TraceAgent
from app.models.usage_conseil import UsageConseil

# Étiquettes du modèle qui désignent une plante saine.
_HEALTHY_LABELS = {"healthy", "normal"}


def _normalise_uuid(value: Optional[str]) -> Optional[str]:
    return value.lower() if value else None


def _refresh_all(db: Session, objects: list) -> None:
    for obj in {id(o): o for o in objects}.values():
        db.refresh(obj)


# ============================================================
# CRUD - Utilisateurs
# ============================================================

def get_user_by_tel(db: Session, tel: str) -> Optional[User]:
    """Récupère un utilisateur par son numéro de téléphone."""
    return db.query(User).filter(User.tel == tel).first()


def get_user_by_id(db: Session, user_id: int) -> Optional[User]:
    """Récupère un utilisateur par son ID."""
    return db.query(User).filter(User.id == user_id).first()


def create_user(
    db: Session, nom: str, prenom: str, region: str, tel: str, password: str
) -> User:
    """Crée un nouvel agriculteur dans la base de données."""
    hashed_password = get_password_hash(password)
    db_user = User(
        nom=nom,
        prenom=prenom,
        region=region,
        tel=tel,
        hashed_password=hashed_password,
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def authenticate_user(db: Session, tel: str, password: str) -> Optional[User]:
    """
    Authentifie un utilisateur par téléphone + mot de passe.
    Retourne l'utilisateur si les identifiants sont corrects, None sinon.
    """
    user = get_user_by_tel(db, tel)
    if not user:
        return None
    if not verify_password(password, user.hashed_password):
        return None
    return user


# ============================================================
# CRUD - Jetons de rafraîchissement (P1.8)
# ============================================================

def create_refresh_token(db: Session, user_id: int, *, commit: bool = True) -> str:
    """Émet un jeton de rafraîchissement et retourne sa valeur en clair."""
    raw_token = generate_refresh_token()
    now = utcnow_naive()
    db.add(
        RefreshToken(
            user_id=user_id,
            token_hash=hash_token(raw_token),
            expires_at=now + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
            created_at=now,
        )
    )
    if commit:
        db.commit()
    return raw_token


def revoke_all_refresh_tokens(db: Session, user_id: int) -> None:
    now = utcnow_naive()
    db.query(RefreshToken).filter(
        RefreshToken.user_id == user_id,
        RefreshToken.revoked_at.is_(None),
    ).update({RefreshToken.revoked_at: now}, synchronize_session=False)
    db.commit()


def revoke_refresh_token(db: Session, raw_token: str) -> None:
    """Révoque un jeton s'il existe (déconnexion) ; sans effet sinon."""
    token = (
        db.query(RefreshToken)
        .filter(RefreshToken.token_hash == hash_token(raw_token))
        .first()
    )
    if token is not None and token.revoked_at is None:
        token.revoked_at = utcnow_naive()
        db.commit()


def rotate_refresh_token(db: Session, raw_token: str) -> Optional[Tuple[User, str]]:
    """
    Échange un jeton valide contre un nouveau (rotation).

    Un jeton déjà révoqué qui revient signale un vol probable : tous les jetons
    actifs de l'utilisateur sont alors révoqués. Retourne None si refusé.
    """
    token = (
        db.query(RefreshToken)
        .filter(RefreshToken.token_hash == hash_token(raw_token))
        .first()
    )
    if token is None:
        return None
    if token.revoked_at is not None:
        revoke_all_refresh_tokens(db, token.user_id)
        return None

    now = utcnow_naive()
    if token.expires_at <= now:
        return None

    user = get_user_by_id(db, token.user_id)
    if user is None or not user.is_active:
        return None

    token.revoked_at = now
    new_raw_token = create_refresh_token(db, user.id, commit=False)
    db.commit()
    return user, new_raw_token


# ============================================================
# CRUD - Parcelles
# ============================================================

def get_parcelles_by_user(db: Session, user_id: int) -> List[Parcelle]:
    """Récupère toutes les parcelles d'un utilisateur."""
    return db.query(Parcelle).filter(Parcelle.user_id == user_id).all()


def get_parcelle_by_id(db: Session, parcelle_id: int) -> Optional[Parcelle]:
    """Récupère une parcelle par son ID."""
    return db.query(Parcelle).filter(Parcelle.id == parcelle_id).first()


def create_parcelle(
    db: Session,
    user_id: int,
    nom_parcelle: str,
    description: Optional[str] = None,
    surface: Optional[float] = None,
    latitude: Optional[float] = None,
    longitude: Optional[float] = None,
) -> Parcelle:
    """Crée une nouvelle parcelle pour un agriculteur."""
    db_parcelle = Parcelle(
        user_id=user_id,
        nom_parcelle=nom_parcelle,
        description=description,
        surface=surface,
        latitude=latitude,
        longitude=longitude,
    )
    db.add(db_parcelle)
    db.commit()
    db.refresh(db_parcelle)
    return db_parcelle


def bulk_upsert_parcelles(
    db: Session, user_id: int, parcelles_data: list
) -> Tuple[List[Parcelle], List[Parcelle]]:
    """
    Synchronisation offline → serveur, idempotente grâce à client_uuid (P1.9).

    Une parcelle déjà connue sous le même client_uuid est mise à jour au lieu
    d'être dupliquée. Retourne (parcelles traitées dans l'ordre reçu, parcelles créées).
    """
    uuids = {u for p in parcelles_data if (u := _normalise_uuid(p.client_uuid))}
    known = (
        {
            p.client_uuid: p
            for p in db.query(Parcelle).filter(
                Parcelle.user_id == user_id, Parcelle.client_uuid.in_(uuids)
            )
        }
        if uuids
        else {}
    )

    processed: List[Parcelle] = []
    created: List[Parcelle] = []
    for p_data in parcelles_data:
        client_uuid = _normalise_uuid(p_data.client_uuid)
        fields = {
            "nom_parcelle": p_data.nom_parcelle,
            "description": p_data.description,
            "surface": p_data.surface,
            "latitude": p_data.latitude,
            "longitude": p_data.longitude,
            "ecosysteme": p_data.ecosysteme,
            "region": p_data.region,
            "altitude_tranche": p_data.altitude_tranche,
            "altitude_metres": p_data.altitude_metres,
            "variete": p_data.variete,
            "saison": p_data.saison,
            "date_repiquage": p_data.date_repiquage,
        }
        parcelle = known.get(client_uuid) if client_uuid else None
        if parcelle is None:
            parcelle = Parcelle(user_id=user_id, client_uuid=client_uuid, **fields)
            db.add(parcelle)
            created.append(parcelle)
            if client_uuid:
                known[client_uuid] = parcelle
        else:
            for name, value in fields.items():
                setattr(parcelle, name, value)
        processed.append(parcelle)

    db.commit()
    _refresh_all(db, processed)
    return processed, created


# ============================================================
# CRUD - Diagnostics
# ============================================================

def get_diagnostics_by_user(db: Session, user_id: int) -> List[Diagnostic]:
    """Récupère tous les diagnostics d'un utilisateur."""
    return (
        db.query(Diagnostic)
        .filter(Diagnostic.user_id == user_id)
        .order_by(Diagnostic.date_diagnostic.desc())
        .all()
    )


def get_diagnostics_by_parcelle(
    db: Session, parcelle_id: int
) -> List[Diagnostic]:
    """Récupère tous les diagnostics d'une parcelle donnée."""
    return (
        db.query(Diagnostic)
        .filter(Diagnostic.parcelle_id == parcelle_id)
        .order_by(Diagnostic.date_diagnostic.desc())
        .all()
    )


def create_diagnostic(
    db: Session,
    user_id: int,
    parcelle_id: int,
    maladie_detectee: str,
    date_diagnostic,
    confiance: Optional[float] = None,
    niveau_gravite: Optional[str] = None,
    recommandations: Optional[str] = None,
) -> Diagnostic:
    """Crée un nouveau diagnostic."""
    db_diag = Diagnostic(
        user_id=user_id,
        parcelle_id=parcelle_id,
        maladie_detectee=maladie_detectee,
        confiance=confiance,
        niveau_gravite=niveau_gravite,
        recommandations=recommandations,
        date_diagnostic=date_diagnostic,
    )
    db.add(db_diag)
    db.commit()
    db.refresh(db_diag)
    return db_diag


def bulk_upsert_diagnostics(
    db: Session, user_id: int, diagnostics_data: list
) -> Tuple[List[Diagnostic], List[Diagnostic], int]:
    """
    Synchronisation offline → serveur, idempotente grâce à client_uuid (P1.9).

    La parcelle est désignée par parcelle_client_uuid (prioritaire) ou parcelle_id,
    et doit appartenir à l'utilisateur. Un diagnostic déjà reçu n'est pas modifié.
    Retourne (diagnostics acceptés dans l'ordre reçu, diagnostics créés, nombre ignoré).
    """
    user_parcelles = get_parcelles_by_user(db, user_id)
    parcelles_by_id = {p.id: p for p in user_parcelles}
    parcelles_by_uuid = {p.client_uuid: p for p in user_parcelles if p.client_uuid}

    uuids = {u for d in diagnostics_data if (u := _normalise_uuid(d.client_uuid))}
    known = (
        {
            d.client_uuid: d
            for d in db.query(Diagnostic).filter(
                Diagnostic.user_id == user_id, Diagnostic.client_uuid.in_(uuids)
            )
        }
        if uuids
        else {}
    )

    processed: List[Diagnostic] = []
    created: List[Diagnostic] = []
    skipped = 0
    for d_data in diagnostics_data:
        client_uuid = _normalise_uuid(d_data.client_uuid)
        if client_uuid and client_uuid in known:
            processed.append(known[client_uuid])
            continue

        parcelle = None
        if d_data.parcelle_client_uuid:
            parcelle = parcelles_by_uuid.get(_normalise_uuid(d_data.parcelle_client_uuid))
        if parcelle is None and d_data.parcelle_id is not None:
            parcelle = parcelles_by_id.get(d_data.parcelle_id)
        if parcelle is None:
            # Sécurité : parcelle inconnue ou appartenant à un autre utilisateur.
            skipped += 1
            continue

        diagnostic = Diagnostic(
            user_id=user_id,
            parcelle_id=parcelle.id,
            client_uuid=client_uuid,
            maladie_detectee=d_data.maladie_detectee,
            confiance=d_data.confiance,
            certitude=d_data.certitude,
            niveau_gravite=d_data.niveau_gravite,
            recommandations=d_data.recommandations,
            date_diagnostic=d_data.date_diagnostic,
        )
        db.add(diagnostic)
        created.append(diagnostic)
        processed.append(diagnostic)
        if client_uuid:
            known[client_uuid] = diagnostic

    db.commit()
    _refresh_all(db, processed)
    return processed, created, skipped


def get_journal_agricole(db: Session, user_id: int) -> list:
    """
    Construit le journal agricole : un résumé de l'état de santé de chaque parcelle.
    Pour chaque parcelle, retourne :
      - Infos de la parcelle
      - Nombre total de diagnostics
      - Dernière maladie détectée
      - Statut global (sain / malade)
    """
    parcelles = get_parcelles_by_user(db, user_id)
    journal = []

    for parcelle in parcelles:
        diagnostics = get_diagnostics_by_parcelle(db, parcelle.id)
        nb_diagnostics = len(diagnostics)

        derniere_maladie = None
        statut = "aucun_diagnostic"

        if nb_diagnostics > 0:
            # Le diagnostic le plus récent détermine l'état actuel
            dernier = diagnostics[0]  # Déjà trié par date desc
            derniere_maladie = dernier.maladie_detectee
            statut = (
                "sain" if derniere_maladie.lower() in _HEALTHY_LABELS else "malade"
            )

        journal.append(
            {
                "parcelle_id": parcelle.id,
                "nom_parcelle": parcelle.nom_parcelle,
                "description": parcelle.description,
                "surface": parcelle.surface,
                "latitude": parcelle.latitude,
                "longitude": parcelle.longitude,
                "nb_diagnostics": nb_diagnostics,
                "derniere_maladie": derniere_maladie,
                "statut": statut,
                "created_at": parcelle.created_at,
            }
        )

    return journal


def bulk_upsert_sessions(
    db: Session, user_id: int, sessions_data: list
) -> Tuple[List[DiagnosticSession], List[DiagnosticSession], int, int]:
    """
    Synchronisation des sessions de scan multi-photos (tâche P2.3).

    Idempotente par client_uuid, comme les parcelles et les diagnostics (P1.9).
    La parcelle est facultative (P2.6) ; si elle est désignée mais inconnue ou
    appartenant à un autre utilisateur, la session est ignorée. Une session déjà
    reçue n'est pas modifiée, mais ses nouvelles observations sont ajoutées :
    un renvoi après une photo de plus fonctionne.

    Retourne (sessions acceptées, sessions créées, ignorées, observations créées).
    """
    user_parcelles = get_parcelles_by_user(db, user_id)
    parcelles_by_id = {p.id: p for p in user_parcelles}
    parcelles_by_uuid = {p.client_uuid: p for p in user_parcelles if p.client_uuid}

    uuids = {u for s in sessions_data if (u := _normalise_uuid(s.client_uuid))}
    known = (
        {
            s.client_uuid: s
            for s in db.query(DiagnosticSession).filter(
                DiagnosticSession.user_id == user_id,
                DiagnosticSession.client_uuid.in_(uuids),
            )
        }
        if uuids
        else {}
    )

    processed: List[DiagnosticSession] = []
    created: List[DiagnosticSession] = []
    observations_created = 0
    skipped = 0

    for s_data in sessions_data:
        client_uuid = _normalise_uuid(s_data.client_uuid)
        session = known.get(client_uuid) if client_uuid else None

        if session is None:
            parcelle = None
            if s_data.parcelle_client_uuid:
                parcelle = parcelles_by_uuid.get(
                    _normalise_uuid(s_data.parcelle_client_uuid)
                )
            if parcelle is None and s_data.parcelle_id is not None:
                parcelle = parcelles_by_id.get(s_data.parcelle_id)

            parcelle_designee = (
                s_data.parcelle_client_uuid is not None or s_data.parcelle_id is not None
            )
            if parcelle_designee and parcelle is None:
                # Sécurité : parcelle inconnue ou appartenant à un autre utilisateur.
                skipped += 1
                continue

            session = DiagnosticSession(
                user_id=user_id,
                parcelle_id=parcelle.id if parcelle else None,
                client_uuid=client_uuid,
                created_at=s_data.created_at,
                stade=s_data.stade,
                ecosysteme=s_data.ecosysteme,
                resultat_fiche_id=s_data.resultat_fiche_id,
                certitude=s_data.certitude,
                gravite_declaree=s_data.gravite_declaree,
                classement=s_data.classement,
                statut_validation=s_data.statut_validation or "non_valide",
            )
            db.add(session)
            db.flush()
            created.append(session)
            if client_uuid:
                known[client_uuid] = session

        observations_created += _ajouter_observations(session, s_data.observations)
        processed.append(session)

    db.commit()
    _refresh_all(db, processed)
    return processed, created, skipped, observations_created


def _ajouter_observations(session: DiagnosticSession, observations_data: list) -> int:
    """Ajoute les observations encore inconnues de la session."""
    deja_connues = {o.client_uuid for o in session.observations if o.client_uuid}
    ajoutees = 0

    for o_data in observations_data:
        client_uuid = _normalise_uuid(o_data.client_uuid)
        if client_uuid and client_uuid in deja_connues:
            continue

        session.observations.append(
            Observation(
                client_uuid=client_uuid,
                organe=o_data.organe,
                image_path=o_data.image_path,
                qualite_nettete=o_data.qualite_nettete,
                qualite_luminosite=o_data.qualite_luminosite,
                top_k=o_data.top_k,
                reponses=o_data.reponses,
                created_at=o_data.created_at,
            )
        )
        if client_uuid:
            deja_connues.add(client_uuid)
        ajoutees += 1

    return ajoutees


# ==========================================
# QUOTA DU CONSEIL (tâche P5.4)
# ==========================================

def consommer_quota_conseil(
    db: Session, user_id: int, jour: date, limite: int
) -> Optional[int]:
    """
    Réserve une question dans le quota du jour et renvoie le nombre de questions
    restantes, ou None si le quota est épuisé.

    L'incrément est conditionnel en une seule requête : deux questions
    simultanées ne peuvent pas dépasser la limite ensemble.
    """
    filtre = (UsageConseil.user_id == user_id, UsageConseil.jour == jour)
    for _ in range(2):
        incrementee = db.execute(
            update(UsageConseil)
            .where(*filtre, UsageConseil.nb_questions < limite)
            .values(nb_questions=UsageConseil.nb_questions + 1)
        )
        if incrementee.rowcount == 1:
            db.commit()
            consommees = db.execute(select(UsageConseil.nb_questions).where(*filtre)).scalar_one()
            return limite - consommees

        if limite <= 0 or db.execute(select(UsageConseil.id).where(*filtre)).first():
            db.rollback()
            return None

        db.add(UsageConseil(user_id=user_id, jour=jour, nb_questions=1))
        try:
            db.commit()
            return limite - 1
        except IntegrityError:
            # Une autre requête vient de créer la ligne du jour : on repasse par l'incrément.
            db.rollback()
    return None


def rendre_quota_conseil(db: Session, user_id: int, jour: date) -> None:
    """Rend une question du quota quand le fournisseur n'a pas pu répondre."""
    db.execute(
        update(UsageConseil)
        .where(
            UsageConseil.user_id == user_id,
            UsageConseil.jour == jour,
            UsageConseil.nb_questions > 0,
        )
        .values(nb_questions=UsageConseil.nb_questions - 1)
    )
    db.commit()


# ==========================================
# TRACES DE L'AGENT (ADR-012)
# ==========================================

def enregistrer_trace_agent(
    db: Session,
    *,
    user_id: int,
    conversation_id: Optional[str],
    langue: str,
    question: str,
    reponse: str,
    issue: str,
    outils: list,
    garde_fous: list,
    fiches: list,
    sessions: list,
    orienter_technicien: bool,
    jetons_entree: int,
    jetons_sortie: int,
    duree_ms: int,
    modele: Optional[str],
) -> None:
    db.add(
        TraceAgent(
            user_id=user_id,
            conversation_id=conversation_id,
            cree_le=utcnow_naive(),
            langue=langue,
            question=question,
            reponse=reponse,
            issue=issue,
            outils=json.dumps(outils, ensure_ascii=False),
            garde_fous=json.dumps(garde_fous, ensure_ascii=False),
            fiches=json.dumps(fiches, ensure_ascii=False),
            sessions=json.dumps(sessions),
            orienter_technicien=orienter_technicien,
            jetons_entree=jetons_entree,
            jetons_sortie=jetons_sortie,
            duree_ms=duree_ms,
            modele=modele,
        )
    )
    db.commit()


def purger_traces_agent(db: Session, avant: datetime) -> int:
    """Supprime les traces plus anciennes que la durée de conservation."""
    resultat = db.execute(delete(TraceAgent).where(TraceAgent.cree_le < avant))
    db.commit()
    return resultat.rowcount or 0


def supprimer_traces_agent(db: Session, user_id: int) -> int:
    """Droit à l'effacement : toutes les traces du compte."""
    resultat = db.execute(delete(TraceAgent).where(TraceAgent.user_id == user_id))
    db.commit()
    return resultat.rowcount or 0
