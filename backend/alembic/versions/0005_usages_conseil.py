"""Quota quotidien du conseil à partir des fiches (tâche P5.4)

Revision ID: 0005_usages_conseil
Revises: 0004_contexte_parcelle
Create Date: 2026-09-17
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = "0005_usages_conseil"
down_revision: Union[str, None] = "0004_contexte_parcelle"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "usages_conseil",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("jour", sa.Date(), nullable=False),
        sa.Column("nb_questions", sa.Integer(), nullable=False, server_default="0"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", "jour", name="uq_usages_conseil_user_jour"),
    )


def downgrade() -> None:
    op.drop_table("usages_conseil")
