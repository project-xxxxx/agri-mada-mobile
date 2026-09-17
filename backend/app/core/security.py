"""
Module de sécurité - Gestion JWT et hachage de mots de passe.
"""

import hashlib
import secrets
from datetime import datetime, timedelta, timezone
from typing import Optional

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings

# --- Hachage de mot de passe ---
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Vérifie qu'un mot de passe en clair correspond au hash stocké."""
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """Génère un hash bcrypt à partir d'un mot de passe en clair."""
    return pwd_context.hash(password)


# --- Tokens JWT ---
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Crée un token JWT signé.
    Le champ 'sub' (subject) contient généralement l'identifiant de l'utilisateur.
    """
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(
        to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM
    )
    return encoded_jwt


def decode_access_token(token: str) -> Optional[dict]:
    """
    Décode et valide un token JWT.
    Retourne les données du token ou None si invalide/expiré.
    """
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        return payload
    except JWTError:
        return None


# --- Jetons de rafraîchissement ---
def generate_refresh_token() -> str:
    """Jeton opaque à forte entropie, remis une seule fois au client."""
    return secrets.token_urlsafe(48)


def hash_token(raw_token: str) -> str:
    """Empreinte stockée en base : le jeton en clair n'est jamais conservé."""
    return hashlib.sha256(raw_token.encode("utf-8")).hexdigest()
