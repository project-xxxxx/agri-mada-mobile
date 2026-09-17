from datetime import datetime, timezone

import pytest


@pytest.mark.asyncio
async def test_sync_parcelles_sans_token_retourne_401(async_client):
    response = await async_client.post(
        '/api/sync/parcelles',
        json={
            'parcelles': [
                {
                    'nom_parcelle': 'Parcelle A',
                    'description': 'desc',
                    'surface': 1.0,
                    'latitude': -18.9,
                    'longitude': 47.5,
                }
            ]
        },
    )

    assert response.status_code == 401


@pytest.mark.asyncio
async def test_sync_parcelles_avec_token_valide_retourne_200(async_client, auth_headers):
    response = await async_client.post(
        '/api/sync/parcelles',
        headers=auth_headers,
        json={
            'parcelles': [
                {
                    'nom_parcelle': 'Parcelle B',
                    'description': 'desc',
                    'surface': 2.0,
                    'latitude': -18.91,
                    'longitude': 47.51,
                }
            ]
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload['total_received'] == 1
    assert payload['total_created'] == 1


@pytest.mark.asyncio
async def test_sync_diagnostics_sans_token_retourne_401(async_client):
    response = await async_client.post(
        '/api/sync/diagnostics',
        json={
            'diagnostics': [
                {
                    'parcelle_id': 1,
                    'maladie_detectee': 'Brown spot',
                    'confiance': 0.8,
                    'niveau_gravite': 'modere',
                    'recommandations': 'Traiter',
                    'date_diagnostic': datetime.now(timezone.utc).isoformat(),
                }
            ]
        },
    )

    assert response.status_code == 401


@pytest.mark.asyncio
async def test_sync_diagnostics_avec_token_valide_retourne_200(
    async_client,
    auth_headers,
    user_parcelle,
):
    response = await async_client.post(
        '/api/sync/diagnostics',
        headers=auth_headers,
        json={
            'diagnostics': [
                {
                    'parcelle_id': user_parcelle.id,
                    'maladie_detectee': 'Leaf smut',
                    'confiance': 0.9,
                    'niveau_gravite': 'severe',
                    'recommandations': 'Appliquer traitement',
                    'date_diagnostic': datetime.now(timezone.utc).isoformat(),
                }
            ]
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload['total_received'] == 1
    assert payload['total_created'] == 1
