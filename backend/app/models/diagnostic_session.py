"""
Modèles SQLAlchemy - Session de diagnostic et observations (tâche P2.3).

Une session regroupe une à trois observations, chacune rattachée à un organe.
La parcelle est facultative : on peut scanner avant d'avoir créé sa première
parcelle, et rattacher la session ensuite (tâche P2.6).

Les photos ne sont pas encore envoyées au serveur : seul leur chemin local est
transmis, pour que le technicien sache quelle photo demander. Le stockage
d'objets (MinIO ou S3) arrive avec la boucle technicien.
"""

from datetime import datetime, timezone

from sqlalchemy import (
    Column,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.orm import relationship

from app.db.session import Base


class DiagnosticSession(Base):
    __tablename__ = "diagnostic_sessions"
    __table_args__ = (
        UniqueConstraint("user_id", "client_uuid", name="uq_sessions_user_client_uuid"),
    )

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    parcelle_id = Column(
        Integer,
        ForeignKey("parcelles.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
        comment="null tant que la session n'est rattachée à aucune parcelle (P2.6)",
    )
    # Identifiant généré par le téléphone : rend la synchronisation idempotente (P1.9).
    client_uuid = Column(String(36), nullable=True)
    created_at = Column(
        DateTime, nullable=False, comment="Date du scan sur le téléphone"
    )
    stade = Column(String(50), nullable=True, comment="Stade de culture déclaré")
    ecosysteme = Column(
        String(50), nullable=True, comment="irrigue, bas_fond, tanety_pluvial"
    )
    resultat_fiche_id = Column(
        String(100),
        nullable=True,
        comment="Fiche retenue, null quand l'app ne nomme rien (ADR-006)",
    )
    certitude = Column(
        String(20), nullable=True, comment="probable, possible, incertain"
    )
    gravite_declaree = Column(
        String(50),
        nullable=True,
        comment="Part de parcelle déclarée : quelques_plants, moins_tiers, plus_tiers",
    )
    classement = Column(
        Text, nullable=True, comment='Top 3 au format JSON : [{"label": ..., "p": ...}]'
    )
    statut_validation = Column(
        String(30),
        nullable=False,
        default="non_valide",
        server_default="non_valide",
        comment="non_valide, valide_technicien, corrige",
    )
    synced_at = Column(
        DateTime, default=lambda: datetime.now(timezone.utc), nullable=False
    )

    observations = relationship(
        "Observation",
        back_populates="session",
        cascade="all, delete-orphan",
        order_by="Observation.id",
    )

    def __repr__(self):
        return f"<DiagnosticSession {self.id} - Parcelle {self.parcelle_id}>"


class Observation(Base):
    __tablename__ = "observations"
    __table_args__ = (
        UniqueConstraint(
            "session_id", "client_uuid", name="uq_observations_session_client_uuid"
        ),
    )

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    session_id = Column(
        Integer,
        ForeignKey("diagnostic_sessions.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    client_uuid = Column(String(36), nullable=True)
    organe = Column(
        String(30),
        nullable=False,
        comment="feuille, tige_gaine, collet, racines, panicule_grains, plante_entiere",
    )
    image_path = Column(
        String(500), nullable=True, comment="Chemin de la photo sur le téléphone"
    )
    qualite_nettete = Column(
        Float, nullable=True, comment="Variance du laplacien mesurée avant l'analyse"
    )
    qualite_luminosite = Column(Float, nullable=True)
    top_k = Column(
        Text, nullable=True, comment="Sortie du modèle au format JSON, null sans modèle"
    )
    reponses = Column(
        Text, nullable=True, comment="Réponses au questionnaire au format JSON"
    )
    created_at = Column(DateTime, nullable=False)

    session = relationship("DiagnosticSession", back_populates="observations")

    def __repr__(self):
        return f"<Observation {self.organe} - Session {self.session_id}>"
