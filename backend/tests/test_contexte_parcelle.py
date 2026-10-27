"""Contexte de culture d'une parcelle (tâche P2.5)."""

from datetime import datetime, timezone
from uuid import uuid4

import pytest

from app.models.parcelle import Parcelle


def _parcelle(client_uuid, **contexte):
    payload = {
        'client_uuid': client_uuid,
        'nom_parcelle': 'Tanety avaratra',
        'surface': 0.25,
        'ecosysteme': 'tanety_pluvial',
        'region': 'Vakinankaratra',
        'altitude_tranche': '1200_1500',
        'altitude_metres': 1480.0,
        'variete': 'FOFIFA 184',
        'saison': 'saison_principale',
        'date_repiquage': datetime(2026, 1, 15, tzinfo=timezone.utc).isoformat(),
    }
    payload.update(contexte)
    return payload


@pytest.mark.asyncio
async def test_le_contexte_de_culture_arrive_au_serveur(
    async_client, auth_headers, db_session
):
    reponse = await async_client.post(
        '/api/sync/parcelles',
        headers=auth_headers,
        json={'parcelles': [_parcelle(str(uuid4()))]},
    )

    assert reponse.status_code == 200
    parcelle = db_session.query(Parcelle).one()
    assert parcelle.ecosysteme == 'tanety_pluvial'
    assert parcelle.region == 'Vakinankaratra'
    assert parcelle.altitude_tranche == '1200_1500'
    assert parcelle.altitude_metres == 1480.0
    assert parcelle.variete == 'FOFIFA 184'
    assert parcelle.saison == 'saison_principale'
    assert parcelle.date_repiquage.date().isoformat() == '2026-01-15'
    assert reponse.json()['parcelles'][0]['variete'] == 'FOFIFA 184'


@pytest.mark.asyncio
async def test_un_contexte_corrige_remplace_l_ancien(
    async_client, auth_headers, db_session
):
    client_uuid = str(uuid4())
    await async_client.post(
        '/api/sync/parcelles',
        headers=auth_headers,
        json={'parcelles': [_parcelle(client_uuid)]},
    )

    reponse = await async_client.post(
        '/api/sync/parcelles',
        headers=auth_headers,
        json={
            'parcelles': [
                _parcelle(client_uuid, ecosysteme='bas_fond', variete='locale_ou_inconnue')
            ]
        },
    )

    assert reponse.json()['total_created'] == 0
    parcelle = db_session.query(Parcelle).one()
    assert parcelle.ecosysteme == 'bas_fond'
    assert parcelle.variete == 'locale_ou_inconnue'
    assert parcelle.region == 'Vakinankaratra'


@pytest.mark.asyncio
async def test_une_parcelle_sans_contexte_reste_acceptee(
    async_client, auth_headers, db_session
):
    reponse = await async_client.post(
        '/api/sync/parcelles',
        headers=auth_headers,
        json={
            'parcelles': [
                {'client_uuid': str(uuid4()), 'nom_parcelle': 'Sans contexte'}
            ]
        },
    )

    assert reponse.status_code == 200
    parcelle = db_session.query(Parcelle).one()
    assert parcelle.ecosysteme is None
    assert parcelle.date_repiquage is None
