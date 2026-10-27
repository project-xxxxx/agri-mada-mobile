"""Traces de l'agent de conseil (ADR-012)

Revision ID: 0006_traces_agent
Revises: 0005_usages_conseil
Create Date: 2026-09-17
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = "0006_traces_agent"
down_revision: Union[str, None] = "0005_usages_conseil"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "traces_agent",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("conversation_id", sa.String(length=36), nullable=True),
        sa.Column("cree_le", sa.DateTime(), nullable=False),
        sa.Column("langue", sa.String(length=2), nullable=False),
        sa.Column("question", sa.Text(), nullable=False),
        sa.Column("reponse", sa.Text(), nullable=False),
        sa.Column("issue", sa.String(length=30), nullable=False),
        sa.Column("outils", sa.Text(), nullable=True),
        sa.Column("garde_fous", sa.Text(), nullable=True),
        sa.Column("fiches", sa.Text(), nullable=True),
        sa.Column("sessions", sa.Text(), nullable=True),
        sa.Column("orienter_technicien", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("jetons_entree", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("jetons_sortie", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("duree_ms", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("modele", sa.String(length=60), nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_traces_agent_user_id", "traces_agent", ["user_id"])
    op.create_index("ix_traces_agent_cree_le", "traces_agent", ["cree_le"])


def downgrade() -> None:
    op.drop_index("ix_traces_agent_cree_le", table_name="traces_agent")
    op.drop_index("ix_traces_agent_user_id", table_name="traces_agent")
    op.drop_table("traces_agent")
