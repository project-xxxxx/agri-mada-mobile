"""
Routeur principal de l'API.
Regroupe tous les endpoints sous le préfixe /api.
"""

from fastapi import APIRouter

from app.api.endpoints import auth, sync, journal, conseil, agent

api_router = APIRouter(prefix="/api")

# Inclure tous les sous-routeurs
api_router.include_router(auth.router)
api_router.include_router(sync.router)
api_router.include_router(journal.router)
api_router.include_router(conseil.router)
api_router.include_router(agent.router)
