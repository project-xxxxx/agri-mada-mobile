"""
Modèle SQLAlchemy - Trace d'un échange avec l'agent de conseil (ADR-012).

Conserve la question (téléphones et courriels masqués) et la réponse, pour
améliorer les fiches et surveiller les garde-fous. Rien n'est enregistré sans
le consentement de l'utilisateur, et les traces sont purgées après
AGENT_CONSERVATION_JOURS.
"""

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String, Text

from app.db.session import Base


class TraceAgent(Base):
    __tablename__ = "traces_agent"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    conversation_id = Column(String(36), nullable=True)
    cree_le = Column(DateTime, nullable=False, index=True)
    langue = Column(String(2), nullable=False)
    question = Column(Text, nullable=False)
    reponse = Column(Text, nullable=False)
    issue = Column(String(30), nullable=False)
    outils = Column(Text, nullable=True, comment="Outils appelés, JSON")
    garde_fous = Column(Text, nullable=True, comment="Garde-fous déclenchés, JSON")
    fiches = Column(Text, nullable=True, comment="Fiches citées, JSON")
    sessions = Column(Text, nullable=True, comment="Scans consultés, JSON")
    orienter_technicien = Column(Boolean, nullable=False, default=False)
    jetons_entree = Column(Integer, nullable=False, default=0)
    jetons_sortie = Column(Integer, nullable=False, default=0)
    duree_ms = Column(Integer, nullable=False, default=0)
    modele = Column(String(60), nullable=True)

    def __repr__(self):
        return f"<TraceAgent {self.id} user={self.user_id} issue={self.issue}>"
