import os
from datetime import datetime, timezone
from uuid import uuid4

# SECRET_KEY est obligatoire (P1.11) : clé propre aux tests, posée avant tout import
# de l'application. Une variable d'environnement déjà définie (CI) est conservée.
os.environ.setdefault('SECRET_KEY', 'pytest-only-key-never-used-outside-tests-0001')

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import create_engine, event
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.rate_limit import login_rate_limiter
from app.core.security import create_access_token
from app.crud import create_user
from app.db.session import Base, get_db
from app.main import app
from app.models.parcelle import Parcelle


@pytest.fixture(autouse=True)
def _reset_login_rate_limiter():
    login_rate_limiter.reset()
    yield
    login_rate_limiter.reset()


@pytest.fixture(scope='session')
def test_engine():
    engine = create_engine(
        'sqlite://',
        connect_args={'check_same_thread': False},
        poolclass=StaticPool,
    )

    @event.listens_for(engine, 'connect')
    def _set_sqlite_pragma(dbapi_connection, connection_record):
        cursor = dbapi_connection.cursor()
        cursor.execute('PRAGMA foreign_keys=ON')
        cursor.close()

    Base.metadata.create_all(bind=engine)
    yield engine
    Base.metadata.drop_all(bind=engine)


@pytest.fixture
def db_session(test_engine):
    Base.metadata.drop_all(bind=test_engine)
    Base.metadata.create_all(bind=test_engine)

    testing_session_local = sessionmaker(
        autocommit=False,
        autoflush=False,
        bind=test_engine,
    )
    session = testing_session_local()
    try:
        yield session
    finally:
        session.close()


@pytest.fixture
async def async_client(db_session):
    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url='http://testserver') as client:
        yield client

    app.dependency_overrides.clear()


@pytest.fixture
def test_user(db_session):
    suffix = uuid4().hex[:8]
    user = create_user(
        db=db_session,
        nom='Rakoto',
        prenom='Jean',
        region='Analamanga',
        tel=f'034{suffix}',
        password='Password123',
    )
    return user


@pytest.fixture
def auth_token(test_user):
    return create_access_token({'sub': str(test_user.id)})


@pytest.fixture
def auth_headers(auth_token):
    return {'Authorization': f'Bearer {auth_token}'}


@pytest.fixture
def user_parcelle(db_session, test_user):
    parcelle = Parcelle(
        user_id=test_user.id,
        nom_parcelle='Parcelle test',
        description='Description test',
        surface=1.2,
        latitude=-18.91,
        longitude=47.53,
        created_at=datetime.now(timezone.utc),
    )
    db_session.add(parcelle)
    db_session.commit()
    db_session.refresh(parcelle)
    return parcelle
