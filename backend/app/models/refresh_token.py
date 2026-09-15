"""
Modèle SQLAlchemy - Jeton de rafraîchissement (tâche P1.8).

Seule l'empreinte SHA-256 du jeton est stockée. Chaque utilisation le révoque
et en émet un nouveau (rotation) ; présenter un jeton déjà révoqué révoque tous
les jetons actifs de l'utilisateur.
"""

from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship

from app.db.session import Base


def utcnow_naive() -> datetime:
    """Horodatage UTC sans fuseau, comparable aux colonnes DateTime relues."""
    return datetime.now(timezone.utc).replace(tzinfo=None)


class RefreshToken(Base):
    __tablename__ = "refresh_tokens"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    token_hash = Column(String(64), unique=True, nullable=False, index=True)
    expires_at = Column(DateTime, nullable=False)
    revoked_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=utcnow_naive, nullable=False)

    user = relationship("User", back_populates="refresh_tokens")

    def __repr__(self):
        return f"<RefreshToken user={self.user_id} revoked={self.revoked_at is not None}>"
