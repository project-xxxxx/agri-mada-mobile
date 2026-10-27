from datetime import datetime, timezone
from uuid import uuid4

import pytest

from app.crud import create_user
from app.models.diagnostic import Diagnostic
from app.models.diagnostic_session import DiagnosticSession
from app.models.parcelle import Parcelle


@pytest.mark.asyncio
async def test_journal_sans_token_retourne_401(async_client):
    response = await async_client.get('/api/journal/')

    assert response.status_code == 401


@pytest.mark.asyncio
async def test_journal_avec_token_retourne_200(async_client, auth_headers):
    response = await async_client.get('/api/journal/', headers=auth_headers)

    assert response.status_code == 200
    payload = response.json()
    assert 'parcelles' in payload
    assert 'total_parcelles' in payload


@pytest.mark.asyncio
async def test_journal_detail_parcelle_valide_retourne_200(
    async_client,
    auth_headers,
    user_parcelle,
):
    response = await async_client.get(
        f'/api/journal/parcelle/{user_parcelle.id}',
        headers=auth_headers,
    )

    assert response.status_code == 200
    assert isinstance(response.json(), list)


@pytest.mark.asyncio
async def test_journal_detail_parcelle_invalide_retourne_404(async_client, auth_headers):
    response = await async_client.get('/api/journal/parcelle/99999', headers=auth_headers)

    assert response.status_code == 404


# --- Statut des parcelles (ADR-006, ADR-007) ---------------------------------


def _parcelle(db, user, nom):
    parcelle = Parcelle(user_id=user.id, nom_parcelle=nom, created_at=datetime.now(timezone.utc))
    db.add(parcelle)
    db.commit()
    return parcelle


def _session(db, user, parcelle, etiquette, certitude, jour=16):
    db.add(DiagnosticSession(
        user_id=user.id, parcelle_id=parcelle.id, client_uuid=str(uuid4()),
        created_at=datetime(2026, 9, jour, 9), resultat_fiche_id=etiquette, certitude=certitude,
    ))
    db.commit()


def _ancien_diagnostic(db, user, parcelle, maladie, certitude=None):
    db.add(Diagnostic(
        user_id=user.id, parcelle_id=parcelle.id, client_uuid=str(uuid4()),
        maladie_detectee=maladie, certitude=certitude, date_diagnostic=datetime(2026, 9, 1, 9),
    ))
    db.commit()


async def _journal(client, headers):
    response = await client.get('/api/journal/', headers=headers)
    assert response.status_code == 200
    corps = response.json()
    return corps, {p['nom_parcelle']: p for p in corps['parcelles']}


@pytest.mark.asyncio
async def test_une_piste_du_modele_reste_a_confirmer(async_client, auth_headers, db_session, test_user):
    piste = _parcelle(db_session, test_user, 'Piste')
    _session(db_session, test_user, piste, 'Bacterial leaf blight', 'possible')
    probable = _parcelle(db_session, test_user, 'Probable')
    _session(db_session, test_user, probable, 'Bacterial leaf blight', 'probable')
    saine = _parcelle(db_session, test_user, 'Saine')
    _session(db_session, test_user, saine, 'healthy', 'possible')
    sans_nom = _parcelle(db_session, test_user, 'Sans nom')
    _session(db_session, test_user, sans_nom, None, 'incertain')
    _parcelle(db_session, test_user, 'Jamais scannée')

    corps, parcelles = await _journal(async_client, auth_headers)

    assert parcelles['Piste']['statut'] == 'a_confirmer'
    assert parcelles['Piste']['derniere_certitude'] == 'possible'
    assert parcelles['Probable']['statut'] == 'malade'
    assert parcelles['Saine']['statut'] == 'sain'
    assert parcelles['Sans nom']['statut'] == 'a_confirmer'
    assert parcelles['Jamais scannée']['statut'] == 'aucun_diagnostic'
    assert (corps['parcelles_malades'], corps['parcelles_a_confirmer'], corps['parcelles_saines']) == (1, 2, 1)


@pytest.mark.asyncio
async def test_le_dernier_scan_decide(async_client, auth_headers, db_session, test_user):
    parcelle = _parcelle(db_session, test_user, 'Suivie')
    _session(db_session, test_user, parcelle, 'Brown spot', 'probable', jour=10)
    _session(db_session, test_user, parcelle, 'healthy', 'possible', jour=16)

    _, parcelles = await _journal(async_client, auth_headers)

    assert parcelles['Suivie']['statut'] == 'sain'
    assert parcelles['Suivie']['nb_diagnostics'] == 2


@pytest.mark.asyncio
async def test_les_anciens_diagnostics_servent_de_repli_sans_etre_dits_malades(
    async_client, auth_headers, db_session, test_user
):
    ancienne = _parcelle(db_session, test_user, 'Ancienne app')
    _ancien_diagnostic(db_session, test_user, ancienne, 'Brown spot')
    migree = _parcelle(db_session, test_user, 'Migrée')
    _ancien_diagnostic(db_session, test_user, migree, 'Brown spot')
    _session(db_session, test_user, migree, 'Brown spot', 'possible')

    _, parcelles = await _journal(async_client, auth_headers)

    assert parcelles['Ancienne app']['statut'] == 'a_confirmer'
    assert parcelles['Ancienne app']['nb_diagnostics'] == 1
    # Diagnostic déjà migré en session par le téléphone : compté une seule fois.
    assert parcelles['Migrée']['nb_diagnostics'] == 1


@pytest.mark.asyncio
async def test_les_scans_d_un_autre_compte_ne_comptent_pas(async_client, auth_headers, db_session, test_user):
    parcelle = _parcelle(db_session, test_user, 'Mienne')
    autre = create_user(db_session, nom='Rabe', prenom='Paul', region='Itasy',
                        tel=f'033{uuid4().hex[:8]}', password='Password123')
    db_session.add(DiagnosticSession(
        user_id=autre.id, parcelle_id=parcelle.id, client_uuid=str(uuid4()),
        created_at=datetime(2026, 9, 16, 9), resultat_fiche_id='Brown spot', certitude='probable',
    ))
    db_session.commit()

    _, parcelles = await _journal(async_client, auth_headers)

    assert parcelles['Mienne']['statut'] == 'aucun_diagnostic'
