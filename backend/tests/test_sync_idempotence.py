"""Synchronisation idempotente par client_uuid (tâche P1.9)."""

from datetime import datetime, timezone
from uuid import uuid4

import pytest

from app.crud import create_user
from app.models.diagnostic import Diagnostic
from app.models.parcelle import Parcelle


def _parcelle(client_uuid, nom='Tanimbary atsinanana'):
    return {'client_uuid': client_uuid, 'nom_parcelle': nom, 'surface': 0.55}


def _diagnostic(client_uuid, parcelle_client_uuid=None, parcelle_id=None):
    payload = {
        'client_uuid': client_uuid,
        'maladie_detectee': 'Brown spot',
        'confiance': 0.81,
        'certitude': 'probable',
        'niveau_gravite': 'moins_tiers',
        'date_diagnostic': datetime.now(timezone.utc).isoformat(),
    }
    if parcelle_client_uuid is not None:
        payload['parcelle_client_uuid'] = parcelle_client_uuid
    if parcelle_id is not None:
        payload['parcelle_id'] = parcelle_id
    return payload


@pytest.mark.asyncio
async def test_renvoi_d_une_parcelle_ne_la_duplique_pas(
    async_client, auth_headers, db_session
):
    client_uuid = str(uuid4())

    first = await async_client.post(
        '/api/sync/parcelles', headers=auth_headers,
        json={'parcelles': [_parcelle(client_uuid)]},
    )
    second = await async_client.post(
        '/api/sync/parcelles', headers=auth_headers,
        json={'parcelles': [_parcelle(client_uuid, nom='Nom corrigé')]},
    )

    assert first.status_code == 200 and second.status_code == 200
    assert first.json()['total_created'] == 1
    assert second.json()['total_created'] == 0
    assert second.json()['parcelles'][0]['client_uuid'] == client_uuid
    assert second.json()['parcelles'][0]['id'] == first.json()['parcelles'][0]['id']
    assert db_session.query(Parcelle).count() == 1
    assert db_session.query(Parcelle).one().nom_parcelle == 'Nom corrigé'


@pytest.mark.asyncio
async def test_meme_client_uuid_deux_fois_dans_un_envoi(async_client, auth_headers, db_session):
    client_uuid = str(uuid4())

    response = await async_client.post(
        '/api/sync/parcelles', headers=auth_headers,
        json={'parcelles': [_parcelle(client_uuid), _parcelle(client_uuid)]},
    )

    assert response.status_code == 200
    assert response.json()['total_created'] == 1
    assert db_session.query(Parcelle).count() == 1


@pytest.mark.asyncio
async def test_diagnostic_rattache_par_parcelle_client_uuid_et_non_duplique(
    async_client, auth_headers, db_session
):
    parcelle_uuid = str(uuid4())
    diagnostic_uuid = str(uuid4())
    await async_client.post(
        '/api/sync/parcelles', headers=auth_headers,
        json={'parcelles': [_parcelle(parcelle_uuid)]},
    )

    first = await async_client.post(
        '/api/sync/diagnostics', headers=auth_headers,
        json={'diagnostics': [_diagnostic(diagnostic_uuid, parcelle_client_uuid=parcelle_uuid)]},
    )
    second = await async_client.post(
        '/api/sync/diagnostics', headers=auth_headers,
        json={'diagnostics': [_diagnostic(diagnostic_uuid, parcelle_client_uuid=parcelle_uuid)]},
    )

    assert first.json()['total_created'] == 1
    assert second.json()['total_created'] == 0
    body = second.json()['diagnostics'][0]
    assert body['client_uuid'] == diagnostic_uuid
    assert body['certitude'] == 'probable'
    assert db_session.query(Diagnostic).count() == 1


@pytest.mark.asyncio
async def test_diagnostic_sans_parcelle_designee_retourne_422(async_client, auth_headers):
    response = await async_client.post(
        '/api/sync/diagnostics', headers=auth_headers,
        json={'diagnostics': [_diagnostic(str(uuid4()))]},
    )

    assert response.status_code == 422


@pytest.mark.asyncio
async def test_parcelle_d_un_autre_agriculteur_est_ignoree(
    async_client, auth_headers, db_session
):
    other = create_user(
        db=db_session, nom='Autre', prenom='Agri', region='Itasy',
        tel='0329998877', password='Password123',
    )
    foreign_uuid = str(uuid4())
    db_session.add(
        Parcelle(
            user_id=other.id, client_uuid=foreign_uuid, nom_parcelle='Pas à moi',
            created_at=datetime.now(timezone.utc),
        )
    )
    db_session.commit()

    response = await async_client.post(
        '/api/sync/diagnostics', headers=auth_headers,
        json={'diagnostics': [_diagnostic(str(uuid4()), parcelle_client_uuid=foreign_uuid)]},
    )

    assert response.status_code == 200
    assert response.json()['total_created'] == 0
    assert response.json()['total_skipped'] == 1


@pytest.mark.asyncio
async def test_client_uuid_mal_forme_retourne_422(async_client, auth_headers):
    response = await async_client.post(
        '/api/sync/parcelles', headers=auth_headers,
        json={'parcelles': [_parcelle('pas-un-uuid')]},
    )

    assert response.status_code == 422
