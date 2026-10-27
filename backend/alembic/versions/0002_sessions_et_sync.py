"""Jetons de rafraîchissement, client_uuid et certitude (tâches P1.8 et P1.9)

Revision ID: 0002_sessions_et_sync
Revises: 0001_schema_initial
Create Date: 2026-09-15
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = "0002_sessions_et_sync"
down_revision: Union[str, None] = "0001_schema_initial"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "refresh_tokens",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("token_hash", sa.String(length=64), nullable=False),
        sa.Column("expires_at", sa.DateTime(), nullable=False),
        sa.Column("revoked_at", sa.DateTime(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_refresh_tokens_id", "refresh_tokens", ["id"], unique=False)
    op.create_index(
        "ix_refresh_tokens_user_id", "refresh_tokens", ["user_id"], unique=False
    )
    op.create_index(
        "ix_refresh_tokens_token_hash", "refresh_tokens", ["token_hash"], unique=True
    )

    with op.batch_alter_table("parcelles") as batch_op:
        batch_op.add_column(sa.Column("client_uuid", sa.String(length=36), nullable=True))
        batch_op.create_unique_constraint(
            "uq_parcelles_user_client_uuid", ["user_id", "client_uuid"]
        )

    with op.batch_alter_table("diagnostics") as batch_op:
        batch_op.add_column(sa.Column("client_uuid", sa.String(length=36), nullable=True))
        batch_op.add_column(sa.Column("certitude", sa.String(length=20), nullable=True))
        batch_op.create_unique_constraint(
            "uq_diagnostics_user_client_uuid", ["user_id", "client_uuid"]
        )


def downgrade() -> None:
    with op.batch_alter_table("diagnostics") as batch_op:
        batch_op.drop_constraint("uq_diagnostics_user_client_uuid", type_="unique")
        batch_op.drop_column("certitude")
        batch_op.drop_column("client_uuid")

    with op.batch_alter_table("parcelles") as batch_op:
        batch_op.drop_constraint("uq_parcelles_user_client_uuid", type_="unique")
        batch_op.drop_column("client_uuid")

    op.drop_index("ix_refresh_tokens_token_hash", table_name="refresh_tokens")
    op.drop_index("ix_refresh_tokens_user_id", table_name="refresh_tokens")
    op.drop_index("ix_refresh_tokens_id", table_name="refresh_tokens")
    op.drop_table("refresh_tokens")
