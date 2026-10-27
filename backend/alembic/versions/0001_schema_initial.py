"""Schéma initial, tel que créé jusqu'ici par Base.metadata.create_all

Revision ID: 0001_schema_initial
Revises:
Create Date: 2026-09-15
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = "0001_schema_initial"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("nom", sa.String(length=100), nullable=False),
        sa.Column("prenom", sa.String(length=100), nullable=False),
        sa.Column("region", sa.String(length=150), nullable=False),
        sa.Column("tel", sa.String(length=20), nullable=False),
        sa.Column("hashed_password", sa.String(length=255), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_users_id", "users", ["id"], unique=False)
    op.create_index("ix_users_tel", "users", ["tel"], unique=True)

    op.create_table(
        "parcelles",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("nom_parcelle", sa.String(length=200), nullable=False),
        sa.Column("description", sa.String(length=500), nullable=True),
        sa.Column("surface", sa.Float(), nullable=True),
        sa.Column("latitude", sa.Float(), nullable=True),
        sa.Column("longitude", sa.Float(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_parcelles_id", "parcelles", ["id"], unique=False)
    op.create_index("ix_parcelles_user_id", "parcelles", ["user_id"], unique=False)

    op.create_table(
        "diagnostics",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("parcelle_id", sa.Integer(), nullable=False),
        sa.Column("maladie_detectee", sa.String(length=100), nullable=False),
        sa.Column("confiance", sa.Float(), nullable=True),
        sa.Column("niveau_gravite", sa.String(length=50), nullable=True),
        sa.Column("recommandations", sa.String(length=1000), nullable=True),
        sa.Column("date_diagnostic", sa.DateTime(), nullable=False),
        sa.Column("synced_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["parcelle_id"], ["parcelles.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_diagnostics_id", "diagnostics", ["id"], unique=False)
    op.create_index(
        "ix_diagnostics_parcelle_id", "diagnostics", ["parcelle_id"], unique=False
    )
    op.create_index("ix_diagnostics_user_id", "diagnostics", ["user_id"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_diagnostics_user_id", table_name="diagnostics")
    op.drop_index("ix_diagnostics_parcelle_id", table_name="diagnostics")
    op.drop_index("ix_diagnostics_id", table_name="diagnostics")
    op.drop_table("diagnostics")
    op.drop_index("ix_parcelles_user_id", table_name="parcelles")
    op.drop_index("ix_parcelles_id", table_name="parcelles")
    op.drop_table("parcelles")
    op.drop_index("ix_users_tel", table_name="users")
    op.drop_index("ix_users_id", table_name="users")
    op.drop_table("users")
