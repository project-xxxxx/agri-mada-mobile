"""Synchronisation des sessions de diagnostic multi-photos (tâche P2.3)."""

from datetime import datetime, timezone
from uuid import uuid4

import pytest

from app.crud import create_user
from app.models.diagnostic_session import DiagnosticSession, Observation
from app.models.parcelle import Parcelle


def _observation(client_uuid, organe='feuille', top_k=None):
    return {
        'client_uuid': client_uuid,
        'organe': organe,
        'image_path': f'/photos/{organe}.jpg',
        'qualite_nettete': 240.5,
        'qualite_luminosite': 0.45,
        'top_k': top_k,
        'reponses': '{"feuille_taches": "brunes_ovales"}',
        'created_at': datetime.now(timezone.utc).isoformat(),
    }


def _session(client_uuid, observations, parcelle_client_uuid=None, parcelle_id=None):
    payload = {
        'client_uuid': client_uuid,
        'created_at': datetime.now(timezone.utc).isoformat(),
        'ecosysteme': 'bas_fond',
        'certitude': 'possible',
        'gravite_declaree': 'moins_tiers',
        'classement': '[{"label": "Brown spot", "p": 0.62}]',
        'observations': observations,
    }
    if parcelle_client_uuid is not None:
        payload['parcelle_client_uuid'] = parcelle_client_uuid
    if parcelle_id is not None:
        payload['parcelle_id'] = parcelle_id
    return payload


@pytest.mark.asyncio
async def test_une_session_arrive_avec_ses_observations(
    async_client, auth_headers, db_session, user_parcelle
):
    payload = _session(
        str(uuid4()),
        [
            _observation(str(uuid4()), top_k='[{"label": "Brown spot", "p": 0.62}]'),
            _observation(str(uuid4()), organe='collet'),
        ],
        parcelle_id=user_parcelle.id,
    )

    response = await async_client.post(
        '/api/sync/sessions', headers=auth_headers, json={'sessions': [payload]}
    )

    assert response.status_code == 200
    corps = response.json()
    assert corps['total_created'] == 1
    assert corps['total_observations_created'] == 2
    assert db_session.query(DiagnosticSession).count() == 1
    assert db_session.query(Observation).count() == 2
    organes = {o.organe for o in db_session.query(Observation)}
    assert organes == {'feuille', 'collet'}
    assert corps['sessions'][0]['parcelle_id'] == user_parcelle.id
    assert corps['sessions'][0]['statut_validation'] == 'non_valide'


@pytest.mark.asyncio
async def test_renvoyer_la_meme_session_ne_duplique_rien(
    async_client, auth_headers, db_session, user_parcelle
):
    payload = _session(
        str(uuid4()), [_observation(str(uuid4()))], parcelle_id=user_parcelle.id
    )

    first = await async_client.post(
        '/api/sync/sessions', headers=auth_headers, json={'sessions': [payload]}
    )
    second = await async_client.post(
        '/api/sync/sessions', headers=auth_headers, json={'sessions': [payload]}
    )

    assert first.json()['total_created'] == 1
    assert second.json()['total_created'] == 0
    assert second.json()['sessions'][0]['id'] == first.json()['sessions'][0]['id']
    assert db_session.query(DiagnosticSession).count() == 1
    assert db_session.query(Observation).count() == 1


@pytest.mark.asyncio
async def test_une_photo_ajoutee_apres_coup_rejoint_la_session(
    async_client, auth_headers, db_session, user_parcelle
):
    session_uuid = str(uuid4())
    premiere = _observation(str(uuid4()))
    await async_client.post(
        '/api/sync/sessions',
        headers=auth_headers,
        json={'sessions': [_session(session_uuid, [premiere], parcelle_id=user_parcelle.id)]},
    )

    seconde = _observation(str(uuid4()), organe='racines')
    response = await async_client.post(
        '/api/sync/sessions',
        headers=auth_headers,
        json={
            'sessions': [
                _session(session_uuid, [premiere, seconde], parcelle_id=user_parcelle.id)
            ]
        },
    )

    assert response.json()['total_created'] == 0
    assert response.json()['total_observations_created'] == 1
    assert db_session.query(DiagnosticSession).count() == 1
    assert db_session.query(Observation).count() == 2


@pytest.mark.asyncio
async def test_une_session_sans_parcelle_est_acceptee(
    async_client, auth_headers, db_session
):
    payload = _session(str(uuid4()), [_observation(str(uuid4()))])

    response = await async_client.post(
        '/api/sync/sessions', headers=auth_headers, json={'sessions': [payload]}
    )

    assert response.status_code == 200
    assert response.json()['total_created'] == 1
    assert response.json()['sessions'][0]['parcelle_id'] is None
    assert db_session.query(DiagnosticSession).one().parcelle_id is None


@pytest.mark.asyncio
async def test_une_parcelle_d_un_autre_agriculteur_est_refusee(
    async_client, auth_headers, db_session
):
    autre = create_user(
        db_session,
        nom='Rakoto',
        prenom='Naivo',
        region='Itasy',
        tel='0349999999',
        password='Password123',
    )
    parcelle_autre = Parcelle(user_id=autre.id, nom_parcelle='Tanimbary hafa')
    db_session.add(parcelle_autre)
    db_session.commit()

    response = await async_client.post(
        '/api/sync/sessions',
        headers=auth_headers,
        json={
            'sessions': [
                _session(str(uuid4()), [_observation(str(uuid4()))], parcelle_id=parcelle_autre.id)
            ]
        },
    )

    assert response.status_code == 200
    assert response.json()['total_created'] == 0
    assert response.json()['total_skipped'] == 1
    assert db_session.query(DiagnosticSession).count() == 0


@pytest.mark.asyncio
async def test_un_organe_inconnu_est_refuse(async_client, auth_headers):
    payload = _session(str(uuid4()), [_observation(str(uuid4()), organe='fleur')])

    response = await async_client.post(
        '/api/sync/sessions', headers=auth_headers, json={'sessions': [payload]}
    )

    assert response.status_code == 422
