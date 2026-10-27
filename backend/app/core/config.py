"""
Configuration centrale du backend Agri-Mada.
Charge les variables d'environnement depuis le fichier .env
"""

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

# Fragments des valeurs d'exemple : une clé qui les contient n'a jamais été générée.
_PLACEHOLDER_MARKERS = ("changez_moi", "change-me", "change_me", "dev-secret")
_MIN_SECRET_KEY_LENGTH = 32


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="ignore",
    )

    # --- Base de données ---
    DATABASE_URL: str = "sqlite:///./agrimada_dev.db"

    # --- Sécurité JWT ---
    # Obligatoire, sans valeur par défaut (tâche P1.11). Générer avec :
    #   python -c "import secrets; print(secrets.token_urlsafe(48))"
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    # Long : un agriculteur peut rester plusieurs semaines sans réseau.
    REFRESH_TOKEN_EXPIRE_DAYS: int = 60

    # --- Protection de la connexion ---
    LOGIN_MAX_FAILURES: int = 5
    LOGIN_MAX_FAILURES_PER_IP: int = 20
    LOGIN_FAILURE_WINDOW_SECONDS: int = 900

    # --- CORS ---
    # L'application mobile n'en a pas besoin. À renseigner (liste JSON) seulement
    # pour un client web, par ex. CORS_ORIGINS='["https://tableau.agrimada.mg"]'.
    CORS_ORIGINS: list[str] = []

    # --- Conseil à partir des fiches (RAG, tâche P5.4, ADR-011) ---
    # Clé Google AI Studio. Sans elle, le conseil répond 503 et le reste de l'API fonctionne.
    GEMINI_API_KEY: str | None = None
    RAG_MODELE_GENERATION: str = "gemini-3.5-flash-lite"
    RAG_MODELE_EMBEDDING: str = "gemini-embedding-001"
    # Utilisé à la construction de l'index ; la recherche suit ensuite celles de l'index.
    RAG_DIMENSIONS: int = 768
    RAG_TOP_K: int = 5
    # Similarité cosinus minimale d'un extrait pour être transmis au modèle.
    # Calibrée par l'évaluation P5.5 (backend/scripts/eval_rag.py --recherche-seule).
    RAG_SEUIL_SIMILARITE: float = 0.6
    # Chaque question est facturée : plafond par compte et par jour (heure de Madagascar).
    RAG_QUOTA_JOUR: int = 20
    RAG_DELAI_SECONDES: int = 30
    RAG_MAX_JETONS_REPONSE: int = 1024

    # --- Agent de conseil (ADR-012) ---
    # Coupe-circuit : false désactive l'agent (503) sans toucher au reste de l'API.
    # Les réponses d'urgence de santé restent servies, elles n'appellent pas Gemini.
    AGENT_ACTIF: bool = True
    AGENT_MAX_APPELS_OUTILS: int = 4
    # Au-delà, l'agent doit répondre avec ce qu'il a déjà : plafonne le coût d'une question.
    AGENT_MAX_JETONS_ENTREE: int = 20000
    AGENT_HISTORIQUE_VALIDITE_HEURES: int = 24
    # Durée de conservation des traces (questions et réponses), purgées ensuite.
    AGENT_CONSERVATION_JOURS: int = 90

    # --- Application ---
    APP_NAME: str = "Agri-Mada API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False

    @field_validator("SECRET_KEY")
    @classmethod
    def _secret_key_solide(cls, value: str) -> str:
        if any(marker in value.lower() for marker in _PLACEHOLDER_MARKERS):
            raise ValueError(
                "SECRET_KEY est encore la valeur d'exemple. Générez une vraie clé : "
                'python -c "import secrets; print(secrets.token_urlsafe(48))"'
            )
        if len(value) < _MIN_SECRET_KEY_LENGTH:
            raise ValueError(
                f"SECRET_KEY doit contenir au moins {_MIN_SECRET_KEY_LENGTH} caractères."
            )
        return value


settings = Settings()
