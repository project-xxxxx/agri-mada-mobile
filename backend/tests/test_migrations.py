"""Les migrations Alembic doivent produire exactement le schéma des modèles (P1.11)."""

from pathlib import Path

from alembic import command
from alembic.config import Config
from sqlalchemy import create_engine, inspect

from app.db.session import Base

BACKEND_DIR = Path(__file__).resolve().parents[1]


def _alembic_config(database_url: str) -> Config:
    # Config sans fichier : pas de reconfiguration de la journalisation de pytest.
    config = Config()
    config.set_main_option('script_location', str(BACKEND_DIR / 'alembic'))
    config.set_main_option('sqlalchemy.url', database_url)
    return config


def _schema(engine) -> dict:
    inspector = inspect(engine)
    return {
        table: {column['name'] for column in inspector.get_columns(table)}
        for table in inspector.get_table_names()
        if table != 'alembic_version'
    }


def test_upgrade_head_correspond_aux_modeles(tmp_path):
    database_url = f"sqlite:///{(tmp_path / 'migrations.db').as_posix()}"
    config = _alembic_config(database_url)

    command.upgrade(config, 'head')

    engine = create_engine(database_url)
    expected = {
        table.name: {column.name for column in table.columns}
        for table in Base.metadata.sorted_tables
    }
    assert _schema(engine) == expected

    inspector = inspect(engine)
    assert 'uq_parcelles_user_client_uuid' in {
        u['name'] for u in inspector.get_unique_constraints('parcelles')
    }
    assert 'uq_diagnostics_user_client_uuid' in {
        u['name'] for u in inspector.get_unique_constraints('diagnostics')
    }
    engine.dispose()


def test_downgrade_base_retire_toutes_les_tables(tmp_path):
    database_url = f"sqlite:///{(tmp_path / 'migrations.db').as_posix()}"
    config = _alembic_config(database_url)

    command.upgrade(config, 'head')
    command.downgrade(config, 'base')

    engine = create_engine(database_url)
    assert _schema(engine) == {}
    engine.dispose()
