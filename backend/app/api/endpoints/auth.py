"""
Endpoints d'authentification.
- POST /register : Créer un compte agriculteur
- POST /login : Se connecter et obtenir un jeton d'accès et un jeton de rafraîchissement
- POST /refresh : Échanger le jeton de rafraîchissement contre une nouvelle paire
- POST /logout : Révoquer le jeton de rafraîchissement
- GET /me : Consulter son profil
"""

from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, Request, Response, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.core.config import settings
from app.core.rate_limit import login_rate_limiter
from app.core.security import create_access_token
from app.schemas.user import (
    UserCreate,
    UserResponse,
    Token,
    ForgotPasswordRequest,
    ForgotPasswordResponse,
    RefreshTokenRequest,
)
from app.crud import (
    authenticate_user,
    create_refresh_token,
    create_user,
    get_user_by_tel,
    revoke_refresh_token,
    rotate_refresh_token,
)
from app.deps import get_current_user
from app.models.user import User

router = APIRouter(prefix="/auth", tags=["Authentification"])


def _token_response(user: User, refresh_token: str) -> dict:
    access_token = create_access_token(
        data={"sub": str(user.id)},
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES),
    )
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "refresh_token": refresh_token,
        "expires_in": settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    }


@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Créer un compte agriculteur",
    description="Inscription d'un nouvel agriculteur avec nom, prénom, région et numéro de téléphone.",
)
def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """Créer un nouveau compte agriculteur."""
    # Vérifier si le numéro de téléphone est déjà utilisé
    existing_user = get_user_by_tel(db, user_data.tel)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Le numéro de téléphone {user_data.tel} est déjà enregistré.",
        )

    new_user = create_user(
        db=db,
        nom=user_data.nom,
        prenom=user_data.prenom,
        region=user_data.region,
        tel=user_data.tel,
        password=user_data.password,
    )
    return new_user


@router.post(
    "/login",
    response_model=Token,
    summary="Se connecter",
    description=(
        "Authentification par numéro de téléphone et mot de passe. Retourne un jeton "
        "d'accès et un jeton de rafraîchissement. Après trop d'échecs, répond 429."
    ),
)
def login(
    request: Request,
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    """
    Connexion de l'agriculteur.
    Note : OAuth2PasswordRequestForm utilise 'username' et 'password'.
    Ici, 'username' correspond au numéro de téléphone.
    """
    client_ip = request.client.host if request.client else "inconnu"
    account_key = f"compte:{client_ip}:{form_data.username.strip()}"
    limits = (
        (account_key, settings.LOGIN_MAX_FAILURES),
        (f"ip:{client_ip}", settings.LOGIN_MAX_FAILURES_PER_IP),
    )

    wait_seconds = max(login_rate_limiter.retry_after(key, limit) for key, limit in limits)
    if wait_seconds:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Trop de tentatives de connexion. Réessayez plus tard.",
            headers={"Retry-After": str(wait_seconds)},
        )

    user = authenticate_user(db, tel=form_data.username, password=form_data.password)
    if not user:
        for key, _ in limits:
            login_rate_limiter.record_failure(key)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Numéro de téléphone ou mot de passe incorrect.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    login_rate_limiter.reset(account_key)
    return _token_response(user, create_refresh_token(db, user.id))


@router.post(
    "/refresh",
    response_model=Token,
    summary="Rafraîchir la session",
    description=(
        "Échange un jeton de rafraîchissement valide contre une nouvelle paire de jetons. "
        "L'ancien jeton est révoqué ; le présenter à nouveau révoque toute la session."
    ),
)
def refresh(payload: RefreshTokenRequest, db: Session = Depends(get_db)):
    rotated = rotate_refresh_token(db, payload.refresh_token)
    if rotated is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Jeton de rafraîchissement invalide ou expiré.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    user, new_refresh_token = rotated
    return _token_response(user, new_refresh_token)


@router.post(
    "/logout",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Se déconnecter",
    description="Révoque le jeton de rafraîchissement fourni. Sans effet s'il est inconnu.",
)
def logout(payload: RefreshTokenRequest, db: Session = Depends(get_db)):
    revoke_refresh_token(db, payload.refresh_token)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get(
    "/me",
    response_model=UserResponse,
    summary="Mon profil",
    description="Retourne les informations du profil de l'utilisateur connecté.",
)
def read_current_user(current_user: User = Depends(get_current_user)):
    """Consulter le profil de l'utilisateur connecté."""
    return current_user


@router.post(
    "/forgot-password",
    response_model=ForgotPasswordResponse,
    summary="Initier la réinitialisation du mot de passe",
    description=(
        "Accepte un numéro de téléphone et retourne toujours un message "
        "générique pour éviter l'énumération des comptes."
    ),
)
def forgot_password(payload: ForgotPasswordRequest, db: Session = Depends(get_db)):
    """MVP sans OTP/SMS: confirmation générique côté client."""
    _ = get_user_by_tel(db, payload.tel)
    return {
        "message": (
            "Si ce numéro est associé à un compte, des instructions seront envoyées."
        )
    }
