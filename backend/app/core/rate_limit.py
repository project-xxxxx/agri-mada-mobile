"""
Limitation des tentatives de connexion échouées (tâche P1.11).

Fenêtre glissante en mémoire, suffisante pour une instance unique du serveur.
Avec plusieurs instances, déplacer les compteurs dans un stockage partagé.
"""

import math
import threading
import time
from collections import deque
from typing import Callable, Optional

_MAX_TRACKED_KEYS = 10_000


class LoginRateLimiter:
    def __init__(
        self,
        window_seconds: int,
        clock: Callable[[], float] = time.monotonic,
    ) -> None:
        self._window = window_seconds
        self._clock = clock
        self._failures: dict[str, deque[float]] = {}
        self._lock = threading.Lock()

    def _prune(self, key: str, now: float) -> int:
        attempts = self._failures.get(key)
        if attempts is None:
            return 0
        while attempts and now - attempts[0] >= self._window:
            attempts.popleft()
        if not attempts:
            del self._failures[key]
            return 0
        return len(attempts)

    def retry_after(self, key: str, limit: int) -> int:
        """Secondes à attendre si la clé a atteint la limite, sinon 0."""
        with self._lock:
            now = self._clock()
            if self._prune(key, now) < limit:
                return 0
            oldest = self._failures[key][0]
            return max(1, math.ceil(self._window - (now - oldest)))

    def record_failure(self, key: str) -> None:
        with self._lock:
            now = self._clock()
            if len(self._failures) >= _MAX_TRACKED_KEYS:
                for tracked in list(self._failures):
                    self._prune(tracked, now)
            self._failures.setdefault(key, deque()).append(now)

    def reset(self, key: Optional[str] = None) -> None:
        with self._lock:
            if key is None:
                self._failures.clear()
            else:
                self._failures.pop(key, None)


def _build_default_limiter() -> LoginRateLimiter:
    from app.core.config import settings

    return LoginRateLimiter(window_seconds=settings.LOGIN_FAILURE_WINDOW_SECONDS)


login_rate_limiter = _build_default_limiter()
