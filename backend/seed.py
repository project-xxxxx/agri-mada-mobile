"""Création idempotente d'un compte local pour les essais.

Aucun identifiant par défaut (tâche P1.11) : le compte admin/admin a été retiré.

    SEED_USER_TEL=0340000000 SEED_USER_PASSWORD='un-mot-de-passe-solide' python seed.py

Le schéma doit exister : lancer `alembic upgrade head` avant.
"""

import os

from app.core.config import settings  # noqa: F401  (valide SECRET_KEY au démarrage)
from app.crud import create_user, get_user_by_tel
from app.db.session import SessionLocal
from app.models.diagnostic import Diagnostic  # noqa: F401
from app.models.parcelle import Parcelle  # noqa: F401
from app.models.refresh_token import RefreshToken  # noqa: F401
from app.models.user import User  # noqa: F401
from app.schemas.user import MIN_PASSWORD_LENGTH

_WEAK_PASSWORDS = {"admin", "password", "motdepasse", "12345678", "azerty123"}


def seed_user() -> int:
    """Crée le compte décrit par SEED_USER_TEL / SEED_USER_PASSWORD s'il est absent."""
    tel = os.environ.get("SEED_USER_TEL", "").strip()
    password = os.environ.get("SEED_USER_PASSWORD", "")
    if not tel or len(password) < MIN_PASSWORD_LENGTH or password.lower() in _WEAK_PASSWORDS:
        raise SystemExit(
            "Définissez SEED_USER_TEL et SEED_USER_PASSWORD "
            f"({MIN_PASSWORD_LENGTH} caractères minimum, pas un mot de passe trivial)."
        )

    db = SessionLocal()
    try:
        if get_user_by_tel(db, "admin") is not None:
            print(
                "Attention : un compte hérité « admin » existe encore dans cette base. "
                "Supprimez-le."
            )

        existing = get_user_by_tel(db, tel)
        if existing is not None:
            print(f"Compte {tel} déjà présent (id={existing.id}).")
            return existing.id

        created = create_user(
            db=db,
            nom="Essai",
            prenom="Compte",
            region="Local",
            tel=tel,
            password=password,
        )
        print(f"Compte {tel} créé (id={created.id}).")
        return created.id
    finally:
        db.close()


if __name__ == "__main__":
    seed_user()
