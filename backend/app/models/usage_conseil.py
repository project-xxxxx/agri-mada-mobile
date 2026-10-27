"""
Modèle SQLAlchemy - Consommation du conseil par jour (tâche P5.4).

Chaque question posée au conseil est facturée par l'API Gemini : un compteur
par utilisateur et par jour plafonne le coût. Seul le nombre de questions est
conservé, jamais leur texte.
"""

from sqlalchemy import Column, Date, ForeignKey, Integer, UniqueConstraint

from app.db.session import Base


class UsageConseil(Base):
    __tablename__ = "usages_conseil"
    __table_args__ = (
        UniqueConstraint("user_id", "jour", name="uq_usages_conseil_user_jour"),
    )

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    jour = Column(Date, nullable=False)
    nb_questions = Column(Integer, nullable=False, default=0)

    def __repr__(self):
        return f"<UsageConseil user={self.user_id} jour={self.jour} nb={self.nb_questions}>"
