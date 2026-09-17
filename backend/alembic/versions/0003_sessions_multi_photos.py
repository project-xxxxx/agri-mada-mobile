"""Sessions de diagnostic multi-photos et observations (tâche P2.3)

Revision ID: 0003_sessions_multi_photos
Revises: 0002_sessions_et_sync
Create Date: 2026-09-16
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = "0003_sessions_multi_photos"
down_revision: Union[str, None] = "0002_sessions_et_sync"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "diagnostic_sessions",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("parcelle_id", sa.Integer(), nullable=True),
        sa.Column("client_uuid", sa.String(length=36), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("stade", sa.String(length=50), nullable=True),
        sa.Column("ecosysteme", sa.String(length=50), nullable=True),
        sa.Column("resultat_fiche_id", sa.String(length=100), nullable=True),
        sa.Column("certitude", sa.String(length=20), nullable=True),
        sa.Column("gravite_declaree", sa.String(length=50), nullable=True),
        sa.Column("classement", sa.Text(), nullable=True),
        sa.Column(
            "statut_validation",
            sa.String(length=30),
            nullable=False,
            server_default="non_valide",
        ),
        sa.Column("synced_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["parcelle_id"], ["parcelles.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", "client_uuid", name="uq_sessions_user_client_uuid"),
    )
    op.create_index("ix_diagnostic_sessions_id", "diagnostic_sessions", ["id"])
    op.create_index("ix_diagnostic_sessions_user_id", "diagnostic_sessions", ["user_id"])
    op.create_index(
        "ix_diagnostic_sessions_parcelle_id", "diagnostic_sessions", ["parcelle_id"]
    )

    op.create_table(
        "observations",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("session_id", sa.Integer(), nullable=False),
        sa.Column("client_uuid", sa.String(length=36), nullable=True),
        sa.Column("organe", sa.String(length=30), nullable=False),
        sa.Column("image_path", sa.String(length=500), nullable=True),
        sa.Column("qualite_nettete", sa.Float(), nullable=True),
        sa.Column("qualite_luminosite", sa.Float(), nullable=True),
        sa.Column("top_k", sa.Text(), nullable=True),
        sa.Column("reponses", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(
            ["session_id"], ["diagnostic_sessions.id"], ondelete="CASCADE"
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "session_id", "client_uuid", name="uq_observations_session_client_uuid"
        ),
    )
    op.create_index("ix_observations_id", "observations", ["id"])
    op.create_index("ix_observations_session_id", "observations", ["session_id"])


def downgrade() -> None:
    op.drop_index("ix_observations_session_id", table_name="observations")
    op.drop_index("ix_observations_id", table_name="observations")
    op.drop_table("observations")
    op.drop_index("ix_diagnostic_sessions_parcelle_id", table_name="diagnostic_sessions")
    op.drop_index("ix_diagnostic_sessions_user_id", table_name="diagnostic_sessions")
    op.drop_index("ix_diagnostic_sessions_id", table_name="diagnostic_sessions")
    op.drop_table("diagnostic_sessions")
