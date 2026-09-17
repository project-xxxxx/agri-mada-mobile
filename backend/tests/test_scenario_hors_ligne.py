"""Scénario P1.8 côté serveur : trois jours hors ligne puis reconnexion."""

from datetime import timedelta
from uuid import uuid4

import pytest

from app.core.security import create_access_token, hash_token
from app.models.parcelle import Parcelle
from app.models.refresh_token import RefreshToken


@pytest.mark.asyncio
async def test_trois_jours_hors_ligne_puis_reconnexion(async_client, db_session, test_user):
    login = await async_client.post(
        '/api/auth/login',
        data={'username': test_user.tel, 'password': 'Password123'},
    )
    assert login.status_code == 200
    tokens = login.json()

    # Trois jours passent sans réseau : le jeton de rafraîchissement a trois jours,
    # le jeton d'accès (60 min) a expiré depuis longtemps.
    stored = (
        db_session.query(RefreshToken)
        .filter(RefreshToken.token_hash == hash_token(tokens['refresh_token']))
        .one()
    )
    stored.created_at -= timedelta(days=3)
    stored.expires_at -= timedelta(days=3)
    db_session.commit()
    expired_access = create_access_token(
        {'sub': str(test_user.id)},
        expires_delta=timedelta(minutes=60) - timedelta(days=3),
    )
    payload = {'parcelles': [{'client_uuid': str(uuid4()), 'nom_parcelle': 'Tanimbary ambany'}]}

    refused = await async_client.post(
        '/api/sync/parcelles',
        json=payload,
        headers={'Authorization': f'Bearer {expired_access}'},
    )
    assert refused.status_code == 401

    renewed = await async_client.post(
        '/api/auth/refresh', json={'refresh_token': tokens['refresh_token']}
    )
    assert renewed.status_code == 200
    headers = {'Authorization': f"Bearer {renewed.json()['access_token']}"}

    synced = await async_client.post('/api/sync/parcelles', json=payload, headers=headers)
    assert synced.status_code == 200
    assert synced.json()['total_created'] == 1

    # La réponse s'est perdue en route : le téléphone renvoie la même parcelle.
    resent = await async_client.post('/api/sync/parcelles', json=payload, headers=headers)
    assert resent.status_code == 200
    assert resent.json()['total_created'] == 0
    assert db_session.query(Parcelle).count() == 1
