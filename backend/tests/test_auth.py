import pytest


@pytest.mark.asyncio
async def test_login_credentials_valides_retourne_token(async_client, test_user):
    response = await async_client.post(
        '/api/auth/login',
        data={'username': test_user.tel, 'password': 'Password123'},
    )

    assert response.status_code == 200
    payload = response.json()
    assert 'access_token' in payload
    assert payload['token_type'] == 'bearer'


@pytest.mark.asyncio
async def test_login_mauvais_password_retourne_401(async_client, test_user):
    response = await async_client.post(
        '/api/auth/login',
        data={'username': test_user.tel, 'password': 'bad-password'},
    )

    assert response.status_code == 401


@pytest.mark.asyncio
async def test_login_username_inexistant_retourne_401(async_client):
    response = await async_client.post(
        '/api/auth/login',
        data={'username': '0349999999', 'password': 'Password123'},
    )

    assert response.status_code == 401


@pytest.mark.asyncio
async def test_me_sans_token_retourne_401(async_client):
    response = await async_client.get('/api/auth/me')

    assert response.status_code == 401


@pytest.mark.asyncio
async def test_me_avec_token_valide_retourne_200(async_client, auth_headers, test_user):
    response = await async_client.get('/api/auth/me', headers=auth_headers)

    assert response.status_code == 200
    payload = response.json()
    assert payload['id'] > 0
    assert payload['tel'] == test_user.tel


@pytest.mark.asyncio
async def test_forgot_password_retourne_200_message_generique(async_client, test_user):
    response = await async_client.post(
        '/api/auth/forgot-password',
        json={'tel': test_user.tel},
    )

    assert response.status_code == 200
    payload = response.json()
    assert 'message' in payload
    assert payload['message']


@pytest.mark.asyncio
async def test_forgot_password_tel_inconnu_retourne_aussi_200(async_client):
    response = await async_client.post(
        '/api/auth/forgot-password',
        json={'tel': '0340000000'},
    )

    assert response.status_code == 200
    payload = response.json()
    assert 'message' in payload


@pytest.mark.asyncio
async def test_forgot_password_payload_invalide_retourne_422(async_client):
    response = await async_client.post(
        '/api/auth/forgot-password',
        json={'tel': ''},
    )

    assert response.status_code == 422
