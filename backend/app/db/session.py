"""
Configuration de la session SQLAlchemy.
Gère la connexion à la base de données (PostgreSQL en prod, SQLite en dev).
"""

from sqlalchemy import create_engine, event
from sqlalchemy.orm import sessionmaker, declarative_base

from app.core.config import settings

# --- Création du moteur de base de données ---
# Pour SQLite, on doit activer check_same_thread=False
connect_args = {}
if settings.DATABASE_URL.startswith("sqlite"):
    connect_args = {"check_same_thread": False}

engine = create_engine(
    settings.DATABASE_URL,
    connect_args=connect_args,
    echo=settings.DEBUG,  # Affiche les requêtes SQL en mode debug
)

# Active les clés étrangères pour SQLite (désactivées par défaut)
if settings.DATABASE_URL.startswith("sqlite"):
    @event.listens_for(engine, "connect")
    def set_sqlite_pragma(dbapi_connection, connection_record):
        cursor = dbapi_connection.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.close()

# --- Session locale ---
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# --- Base déclarative pour les modèles ---
Base = declarative_base()


def get_db():
    """
    Générateur de session de base de données.
    Utilisé comme dépendance FastAPI pour injecter la session dans les endpoints.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
