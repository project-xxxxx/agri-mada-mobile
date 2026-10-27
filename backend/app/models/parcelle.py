"""
Modèle SQLAlchemy - Parcelle (Journal Agricole).
Chaque parcelle appartient à un agriculteur et regroupe des diagnostics.
"""

from datetime import datetime, timezone
from sqlalchemy import (
    Column,
    Integer,
    String,
    Float,
    DateTime,
    ForeignKey,
    UniqueConstraint,
)
from sqlalchemy.orm import relationship

from app.db.session import Base


class Parcelle(Base):
    __tablename__ = "parcelles"
    __table_args__ = (
        UniqueConstraint("user_id", "client_uuid", name="uq_parcelles_user_client_uuid"),
    )

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    # Identifiant généré par le téléphone : rend la synchronisation idempotente (P1.9).
    client_uuid = Column(String(36), nullable=True)
    nom_parcelle = Column(String(200), nullable=False)
    description = Column(String(500), nullable=True)
    surface = Column(Float, nullable=True, comment="Surface en hectares")
    latitude = Column(Float, nullable=True, comment="Coordonnées GPS")
    longitude = Column(Float, nullable=True, comment="Coordonnées GPS")
    created_at = Column(
        DateTime, default=lambda: datetime.now(timezone.utc), nullable=False
    )

    # --- Contexte de culture (tâche P2.5) ---
    ecosysteme = Column(
        String(50), nullable=True, comment="irrigue, bas_fond, tanety_pluvial"
    )
    region = Column(
        String(100), nullable=True, comment="Une des 23 régions de Madagascar"
    )
    altitude_tranche = Column(
        String(20),
        nullable=True,
        comment="moins_800, 800_1200, 1200_1500, plus_1500",
    )
    altitude_metres = Column(Float, nullable=True, comment="Altitude GPS si connue")
    variete = Column(
        String(100), nullable=True, comment="Variété FOFIFA ou locale_ou_inconnue"
    )
    saison = Column(
        String(30),
        nullable=True,
        comment="vary_aloha, saison_principale, contre_saison",
    )
    date_repiquage = Column(
        DateTime, nullable=True, comment="Sert à situer le stade de la culture"
    )

    # --- Relations ---
    owner = relationship("User", back_populates="parcelles")
    diagnostics = relationship(
        "Diagnostic", back_populates="parcelle", cascade="all, delete-orphan"
    )

    def __repr__(self):
        return f"<Parcelle {self.nom_parcelle} (User: {self.user_id})>"
