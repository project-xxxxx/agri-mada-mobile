"""
Historique de conversation signé (agent, ADR-012).

Le serveur ne garde pas l'état d'une conversation : l'application renvoie les
derniers échanges. Chaque échange est signé (HMAC) par le serveur au moment de
la réponse, lié au compte et à la conversation : un client ne peut ni fabriquer
une fausse réponse de l'agent pour l'influencer, ni rejouer l'échange d'un autre.
"""

from __future__ import annotations

import hashlib
import hmac
import json
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone

_DOMAINE = b"agrimada-agent-historique-v1"
# Tolérance d'horloge pour un échange daté légèrement dans le futur.
_AVANCE_TOLEREE = timedelta(minutes=5)


class HistoriqueInvalide(Exception):
    """Un échange a été modifié, fabriqué ou vient d'un autre compte."""


@dataclass(frozen=True)
class Echange:
    question: str
    reponse: str
    emis_le: datetime


def _horodatage(emis_le: datetime) -> str:
    if emis_le.tzinfo is None:
        raise HistoriqueInvalide("date d'échange sans fuseau horaire")
    return emis_le.astimezone(timezone.utc).isoformat(timespec="seconds")


def _cle(secret: str) -> bytes:
    return hmac.new(secret.encode("utf-8"), _DOMAINE, hashlib.sha256).digest()


def signer(secret: str, *, user_id: int, conversation_id: str, echange: Echange) -> str:
    charge = json.dumps(
        [user_id, conversation_id, _horodatage(echange.emis_le), echange.question, echange.reponse],
        ensure_ascii=False,
        separators=(",", ":"),
    )
    return hmac.new(_cle(secret), charge.encode("utf-8"), hashlib.sha256).hexdigest()


def maintenant() -> datetime:
    return datetime.now(timezone.utc).replace(microsecond=0)


def verifier(
    secret: str,
    *,
    user_id: int,
    conversation_id: str,
    echanges: list[tuple[Echange, str]],
    validite: timedelta,
    instant: datetime | None = None,
) -> tuple[list[Echange], int]:
    """
    Renvoie les échanges valides encore récents, du plus ancien au plus récent,
    et le nombre d'échanges écartés parce que trop anciens.
    Lève HistoriqueInvalide dès qu'une signature ne correspond pas.
    """
    instant = instant or maintenant()
    retenus: list[Echange] = []
    expires = 0
    for echange, signature in echanges:
        attendue = signer(secret, user_id=user_id, conversation_id=conversation_id, echange=echange)
        if not hmac.compare_digest(attendue, signature):
            raise HistoriqueInvalide("signature d'échange invalide")
        emis = echange.emis_le.astimezone(timezone.utc)
        if emis > instant + _AVANCE_TOLEREE:
            raise HistoriqueInvalide("échange daté dans le futur")
        if instant - emis > validite:
            expires += 1
            continue
        retenus.append(echange)
    retenus.sort(key=lambda e: e.emis_le)
    return retenus, expires
