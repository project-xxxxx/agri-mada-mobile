"""Endpoint du conseil (P5.4) : authentification, quota et indisponibilité du fournisseur."""

from datetime import date

import pytest

from app.api.endpoints import conseil
from app.core.config import settings
from app.main import app
from app.rag.gemini import ErreurFournisseur
from app.rag.moteur import Avertissement, FicheCitee, ReponseConseil

QUESTION = {'question': 'Taches en losange sur les feuilles ?', 'langue': 'fr'}


class FauxMoteur:
    def __init__(self, erreur: Exception | None = None):
        self.erreur = erreur
        self.questions: list[tuple[str, str]] = []

    def repondre(self, question, langue):
        self.questions.append((question, langue))
        if self.erreur:
            raise self.erreur
        return ReponseConseil(
            trouve=True,
            reponse='Piste possible : pyriculariose.',
            fiches=[FicheCitee('pyriculariose', 'Pyriculariose', 'Menalavitra', 'brouillon', 0.82)],
            avertissements=[Avertissement('fiches_brouillon', 'Brouillon.')],
        )


@pytest.fixture
def faux_moteur(monkeypatch):
    moteur = FauxMoteur()
    app.dependency_overrides[conseil.get_moteur_conseil] = lambda: moteur
    monkeypatch.setattr(settings, 'RAG_QUOTA_JOUR', 2)
    return moteur


async def test_sans_token_retourne_401(async_client, faux_moteur):
    response = await async_client.post('/api/conseil/question', json=QUESTION)

    assert response.status_code == 401
    assert faux_moteur.questions == []


async def test_repond_avec_fiches_avertissements_et_quota_restant(async_client, auth_headers, faux_moteur):
    response = await async_client.post('/api/conseil/question', json=QUESTION, headers=auth_headers)

    assert response.status_code == 200
    corps = response.json()
    assert corps['trouve'] is True
    assert corps['fiches'][0]['id'] == 'pyriculariose'
    assert corps['fiches'][0]['statut_validation'] == 'brouillon'
    assert corps['avertissements'][0]['code'] == 'fiches_brouillon'
    assert corps['questions_restantes'] == 1


async def test_quota_du_jour_epuise_retourne_429_sans_solliciter_le_moteur(
    async_client, auth_headers, faux_moteur
):
    for _ in range(2):
        assert (await async_client.post('/api/conseil/question', json=QUESTION, headers=auth_headers)).status_code == 200

    response = await async_client.post('/api/conseil/question', json=QUESTION, headers=auth_headers)

    assert response.status_code == 429
    assert len(faux_moteur.questions) == 2


async def test_le_quota_repart_le_lendemain(async_client, auth_headers, faux_moteur, monkeypatch):
    monkeypatch.setattr(conseil, 'jour_madagascar', lambda: date(2026, 9, 17))
    for _ in range(2):
        await async_client.post('/api/conseil/question', json=QUESTION, headers=auth_headers)

    monkeypatch.setattr(conseil, 'jour_madagascar', lambda: date(2026, 9, 18))
    response = await async_client.post('/api/conseil/question', json=QUESTION, headers=auth_headers)

    assert response.status_code == 200
    assert response.json()['questions_restantes'] == 1


async def test_une_panne_du_fournisseur_rend_la_question_au_quota(async_client, auth_headers, faux_moteur):
    faux_moteur.erreur = ErreurFournisseur('délai dépassé')
    response = await async_client.post('/api/conseil/question', json=QUESTION, headers=auth_headers)
    assert response.status_code == 503

    faux_moteur.erreur = None
    response = await async_client.post('/api/conseil/question', json=QUESTION, headers=auth_headers)

    assert response.status_code == 200
    assert response.json()['questions_restantes'] == 1


async def test_sans_cle_gemini_retourne_503(async_client, auth_headers, monkeypatch):
    monkeypatch.setattr(settings, 'GEMINI_API_KEY', None)

    response = await async_client.post('/api/conseil/question', json=QUESTION, headers=auth_headers)

    assert response.status_code == 503


@pytest.mark.parametrize('corps', [
    {'question': '   a  ', 'langue': 'fr'},
    {'question': 'x' * 501, 'langue': 'fr'},
    {'question': 'Taches sur les feuilles ?', 'langue': 'en'},
])
async def test_question_invalide_retourne_422(async_client, auth_headers, faux_moteur, corps):
    response = await async_client.post('/api/conseil/question', json=corps, headers=auth_headers)

    assert response.status_code == 422
    assert faux_moteur.questions == []
