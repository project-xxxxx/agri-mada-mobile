"""
Agri-Mada Backend — Point d'entrée principal.

Application FastAPI pour la centralisation et la synchronisation
des données de l'application mobile de détection des maladies du riz.

Démarrer le serveur en développement :
    alembic upgrade head
    uvicorn app.main:app --reload

En production (Dockerfile) : migrations puis uvicorn, sans --reload.

Documentation interactive :
    http://localhost:8000/docs (Swagger UI)
    http://localhost:8000/redoc (ReDoc)
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.api.router import api_router

# --- Importer tous les modèles pour que SQLAlchemy les enregistre ---
from app.models.user import User  # noqa: F401
from app.models.parcelle import Parcelle  # noqa: F401
from app.models.diagnostic import Diagnostic  # noqa: F401
from app.models.refresh_token import RefreshToken  # noqa: F401
from app.models.usage_conseil import UsageConseil  # noqa: F401
from app.models.trace_agent import TraceAgent  # noqa: F401


# --- Création de l'application FastAPI ---
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description=(
        "API backend pour l'application mobile Agri-Mada.\n\n"
        "## Fonctionnalités\n"
        "- **Authentification** : Inscription et connexion des agriculteurs (JWT et jeton de rafraîchissement)\n"
        "- **Synchronisation** : Réception idempotente des parcelles et diagnostics créés hors-ligne\n"
        "- **Journal Agricole** : Résumé de l'état de santé des parcelles\n"
        "- **Conseil** : Réponses tirées des fiches de connaissance, sans produit ni dose "
        "(nécessite une connexion et GEMINI_API_KEY)\n"
        "- **Agent de conseil** : Relie fiches, parcelles et scans derrière des garde-fous "
        "(ADR-012)\n\n"
        "## Architecture\n"
        "L'application mobile Flutter fonctionne 100% hors-ligne avec TensorFlow Lite "
        "et Isar Database. Ce backend sert uniquement de plateforme de centralisation "
        "et de sauvegarde lorsque l'agriculteur retrouve une connexion internet."
    ),
    docs_url="/docs",
    redoc_url="/redoc",
)

# --- CORS ---
# L'application mobile n'envoie pas de requêtes soumises au CORS : aucune origine
# n'est autorisée par défaut. CORS_ORIGINS ne sert qu'à un éventuel client web.
if settings.CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=False,
        allow_methods=["GET", "POST", "PUT", "DELETE"],
        allow_headers=["Authorization", "Content-Type"],
    )

# Le schéma de base est géré par Alembic (`alembic upgrade head`), plus par
# Base.metadata.create_all au démarrage (tâche P1.11).

# --- Inclusion du routeur principal ---
app.include_router(api_router)


# --- Route de vérification (health check) ---
@app.get(
    "/",
    tags=["Santé"],
    summary="Vérification du serveur",
    description="Endpoint de vérification : retourne un message confirmant que le serveur est en ligne.",
)
def health_check():
    """Vérifier que le serveur est en ligne."""
    return {
        "status": "ok",
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "message": "Serveur Agri-Mada en ligne. Bienvenue !",
    }
