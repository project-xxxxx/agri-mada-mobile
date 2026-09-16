"""Contexte de culture des parcelles (tâche P2.5)

Revision ID: 0004_contexte_parcelle
Revises: 0003_sessions_multi_photos
Create Date: 2026-09-16
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = "0004_contexte_parcelle"
down_revision: Union[str, None] = "0003_sessions_multi_photos"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

COLONNES = [
    ("ecosysteme", sa.String(length=50)),
    ("region", sa.String(length=100)),
    ("altitude_tranche", sa.String(length=20)),
    ("altitude_metres", sa.Float()),
    ("variete", sa.String(length=100)),
    ("saison", sa.String(length=30)),
    ("date_repiquage", sa.DateTime()),
]


def upgrade() -> None:
    with op.batch_alter_table("parcelles") as batch_op:
        for nom, type_ in COLONNES:
            batch_op.add_column(sa.Column(nom, type_, nullable=True))


def downgrade() -> None:
    with op.batch_alter_table("parcelles") as batch_op:
        for nom, _ in reversed(COLONNES):
            batch_op.drop_column(nom)
