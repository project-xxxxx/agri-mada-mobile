"""Durcissement du backend (tâches P1.8 et P1.11)."""

from datetime import timedelta

import pytest
from pydantic import ValidationError

from app.core.config import Settings
from app.core.rate_limit import LoginRateLimiter
from app.core.security import hash_token
from app.models.refresh_token import RefreshToken, utcnow_naive


# --- Configuration -----------------------------------------------------------

def test_secret_key_absente_refusee(monkeypatch):
    monkeypatch.delenv('SECRET_KEY', raising=False)
    with pytest.raises(ValidationError):
        Settings(_env_file=None)


def test_secret_key_d_exemple_refusee():
    with pytest.raises(ValidationError, match="valeur d'exemple"):
        Settings(_env_file=None, SECRET_KEY='CHANGEZ_MOI_AVEC_UNE_CLE_SECRETE_TRES_LONGUE')


def test_secret_key_trop_courte_refusee():
    with pytest.raises(ValidationError, match='32 caractères'):
        Settings(_env_file=None, SECRET_KEY='k' * 31)


def test_configuration_par_defaut_sure():
    settings = Settings(_env_file=None, SECRET_KEY='k' * 48)

    assert settings.DEBUG is False
    assert settings.CORS_ORIGINS == []


@pytest.mark.asyncio
async def test_cors_ferme_par_defaut(async_client):
    response = await async_client.options(
        '/api/auth/login',
        headers={
            'Origin': 'https://site-malveillant.example',
            'Access-Control-Request-Method': 'POST',
        },
    )

    assert 'access-control-allow-origin' not in response.headers


# --- Inscription -------------------------------------------------------------

def _register_payload(password):
    return {
        'nom': 'Rabe',
        'prenom': 'Soa',
        'region': 'Vakinankaratra',
        'tel': '0341112233',
        'password': password,
    }


@pytest.mark.asyncio
async def test_register_mot_de_passe_de_7_caracteres_refuse(async_client):
    response = await async_client.post(
        '/api/auth/register', json=_register_payload('court12')
    )

    assert response.status_code == 422


@pytest.mark.asyncio
async def test_register_mot_de_passe_de_8_caracteres_accepte(async_client):
    response = await async_client.post(
        '/api/auth/register', json=_register_payload('assez123')
    )

    assert response.status_code == 201


# --- Limitation des tentatives de connexion -------------------------------------

async def _login(async_client, tel, password):
    return await async_client.post(
        '/api/auth/login', data={'username': tel, 'password': password}
    )


@pytest.mark.asyncio
async def test_login_bloque_apres_5_echecs_meme_avec_le_bon_mot_de_passe(
    async_client, test_user
):
    for _ in range(5):
        response = await _login(async_client, test_user.tel, 'mauvais-mdp')
        assert response.status_code == 401

    response = await _login(async_client, test_user.tel, 'Password123')

    assert response.status_code == 429
    assert int(response.headers['retry-after']) > 0


@pytest.mark.asyncio
async def test_login_reussi_remet_le_compteur_a_zero(async_client, test_user):
    for _ in range(4):
        await _login(async_client, test_user.tel, 'mauvais-mdp')
    assert (await _login(async_client, test_user.tel, 'Password123')).status_code == 200

    for _ in range(4):
        await _login(async_client, test_user.tel, 'mauvais-mdp')

    assert (await _login(async_client, test_user.tel, 'Password123')).status_code == 200


def test_limiteur_libere_la_cle_apres_la_fenetre():
    now = [1000.0]
    limiter = LoginRateLimiter(window_seconds=900, clock=lambda: now[0])
    for _ in range(5):
        limiter.record_failure('cle')

    assert limiter.retry_after('cle', limit=5) == 900

    now[0] += 900
    assert limiter.retry_after('cle', limit=5) == 0


# --- Jetons de rafraîchissement ----------------------------------------------

async def _tokens(async_client, test_user):
    response = await _login(async_client, test_user.tel, 'Password123')
    assert response.status_code == 200
    return response.json()


async def _refresh(async_client, refresh_token):
    return await async_client.post(
        '/api/auth/refresh', json={'refresh_token': refresh_token}
    )


@pytest.mark.asyncio
async def test_login_retourne_un_refresh_token(async_client, test_user):
    tokens = await _tokens(async_client, test_user)

    assert tokens['refresh_token']
    assert tokens['expires_in'] > 0


@pytest.mark.asyncio
async def test_refresh_emet_une_nouvelle_paire_utilisable(async_client, test_user):
    tokens = await _tokens(async_client, test_user)

    response = await _refresh(async_client, tokens['refresh_token'])

    assert response.status_code == 200
    renewed = response.json()
    assert renewed['refresh_token'] != tokens['refresh_token']
    me = await async_client.get(
        '/api/auth/me',
        headers={'Authorization': f"Bearer {renewed['access_token']}"},
    )
    assert me.status_code == 200


@pytest.mark.asyncio
async def test_refresh_reutilise_revoque_toute_la_session(async_client, test_user):
    tokens = await _tokens(async_client, test_user)
    renewed = (await _refresh(async_client, tokens['refresh_token'])).json()

    reuse = await _refresh(async_client, tokens['refresh_token'])
    after_reuse = await _refresh(async_client, renewed['refresh_token'])

    assert reuse.status_code == 401
    assert after_reuse.status_code == 401


@pytest.mark.asyncio
async def test_logout_revoque_le_refresh_token(async_client, test_user):
    tokens = await _tokens(async_client, test_user)

    logout = await async_client.post(
        '/api/auth/logout', json={'refresh_token': tokens['refresh_token']}
    )

    assert logout.status_code == 204
    assert (await _refresh(async_client, tokens['refresh_token'])).status_code == 401


@pytest.mark.asyncio
async def test_refresh_inconnu_retourne_401(async_client):
    response = await _refresh(async_client, 'x' * 40)

    assert response.status_code == 401


@pytest.mark.asyncio
async def test_refresh_expire_retourne_401(async_client, db_session, test_user):
    tokens = await _tokens(async_client, test_user)
    stored = (
        db_session.query(RefreshToken)
        .filter(RefreshToken.token_hash == hash_token(tokens['refresh_token']))
        .one()
    )
    stored.expires_at = utcnow_naive() - timedelta(minutes=1)
    db_session.commit()

    response = await _refresh(async_client, tokens['refresh_token'])

    assert response.status_code == 401


def test_le_jeton_en_clair_n_est_pas_stocke(db_session, test_user):
    from app.crud import create_refresh_token

    raw = create_refresh_token(db_session, test_user.id)

    stored = db_session.query(RefreshToken).one()
    assert stored.token_hash == hash_token(raw)
    assert raw not in stored.token_hash
