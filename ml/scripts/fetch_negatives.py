"""Récupère des photos négatives pour le modèle de porte (tâche P3.7).

Généralisation de fetch_off_topic.py (P1.2) à un plus grand nombre de
catégories et un quota par catégorie réglable, pour constituer le jeu
d'entraînement `negatifs_v1` (distinct du jeu d'évaluation figé `hors_sujet`
de P1.2, qui ne doit pas grossir : voir ml/data/eval/hors_sujet.csv).

Limite connue (voir ADR-008) : seul Wikimedia Commons est utilisé ici. Le
plan mentionne aussi Open Images et iNaturalist ; ils ne sont pas implémentés
dans ce script (Open Images demande des index de plusieurs Go, iNaturalist une
intégration d'API distincte) — reste à faire si Wikimedia ne suffit pas à
atteindre les volumes voulus par catégorie.

Usage :
    ml/.venv/Scripts/python ml/scripts/fetch_negatives.py --per-category 200
    ml/.venv/Scripts/python ml/scripts/fetch_negatives.py --per-category 2  # essai rapide
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import html
import json
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
IMAGES_DIR = ROOT / "ml" / "data" / "raw" / "negatifs_v1"
MANIFEST = ROOT / "ml" / "data" / "eval" / "negatifs_v1.csv"
HORS_SUJET_CSV = ROOT / "ml" / "data" / "eval" / "hors_sujet.csv"

API = "https://commons.wikimedia.org/w/api.php"
USER_AGENT = "AgriMadaML/1.0 (ISPM Madagascar; jeu de photos negatives pour le modele de porte)"
THUMB_WIDTH = 960
PAUSE_SECONDS = 3

# Catégories plus larges que hors_sujet (P1.2) : ce jeu sert l'entraînement, pas
# une évaluation figée, donc peut grossir avec le temps.
CATEGORIES: dict[str, list[str]] = {
    "sol": ["bare soil field", "laterite soil", "plowed soil", "dry cracked soil"],
    "mains": ["human hand palm", "farmer hands", "hands close-up"],
    "mais": ["maize plant leaves", "corn field leaves", "Zea mays leaf"],
    "herbes": ["grass close-up", "lawn grass blades", "Poaceae meadow", "weeds field"],
    "canne_a_sucre": ["sugarcane leaves", "sugarcane field"],
    "eau": ["pond water surface", "irrigation canal water", "puddle water"],
    "outils": ["hoe farm tool", "shovel garden tool", "machete tool", "sickle tool"],
    "zebus": ["zebu Madagascar", "zebu cattle", "cattle grazing"],
    "ecrans": ["smartphone screen", "computer monitor screen", "television screen"],
    "autres_feuilles": ["cassava leaves", "banana leaf", "bean plant leaves", "sweet potato leaves"],
    "arbres": ["tree bark close-up", "tree canopy leaves", "eucalyptus leaves"],
    "ciel": ["blue sky clouds", "overcast sky"],
    "route": ["dirt road", "village path"],
    "batiment": ["mud brick house", "rural house wall", "corrugated roof"],
}

ALLOWED_LICENSES = re.compile(r"^(cc0|cc[- ]by(-sa)?[- ][\d.]+|public domain|pd)", re.I)
RICE_WORDS = re.compile(r"rice|paddy|oryza|riz|rizi|vary", re.I)


def _get(url: str, params: dict | None = None, attempts: int = 6) -> bytes:
    if params:
        url = f"{url}?{urllib.parse.urlencode(params)}"
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    for attempt in range(1, attempts + 1):
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                return response.read()
        except urllib.error.HTTPError as error:
            if error.code not in (429, 503) or attempt == attempts:
                raise
            retry_after = error.headers.get("Retry-After", "")
            wait = int(retry_after) if retry_after.isdigit() else min(60, 5 * 2**attempt)
            print(f"  serveur saturé ({error.code}), nouvel essai dans {wait} s")
            time.sleep(wait)
    raise RuntimeError("inaccessible")


def _strip_html(value: str) -> str:
    return html.unescape(re.sub(r"<[^>]+>", "", value)).strip()


def _candidates(query: str, limit: int) -> list[dict]:
    payload = json.loads(
        _get(
            API,
            {
                "action": "query",
                "format": "json",
                "generator": "search",
                "gsrsearch": f"{query} filetype:bitmap",
                "gsrnamespace": 6,
                "gsrlimit": limit,
                "prop": "imageinfo",
                "iiprop": "url|extmetadata|mime",
                "iiurlwidth": THUMB_WIDTH,
            },
        )
    )
    pages = sorted(payload.get("query", {}).get("pages", {}).values(), key=lambda p: p.get("index", 0))
    return pages


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--per-category", type=int, default=200, help="nombre de photos visées par catégorie (défaut 200)"
    )
    args = parser.parse_args()

    IMAGES_DIR.mkdir(parents=True, exist_ok=True)
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)

    rows: list[dict] = []
    seen_titles: set[str] = set()
    seen_sha256: set[str] = set()
    if HORS_SUJET_CSV.exists():
        with HORS_SUJET_CSV.open(newline="", encoding="utf-8") as handle:
            seen_sha256.update(row["sha256"] for row in csv.DictReader(handle))
        print(f"{len(seen_sha256)} sha256 de {HORS_SUJET_CSV.name} exclus (jeu d'évaluation P1.2, ne pas contaminer l'entraînement)")

    for category, queries in CATEGORIES.items():
        kept = 0
        for query in queries:
            if kept >= args.per_category:
                break
            for page in _candidates(query, limit=min(50, args.per_category * 2)):
                if kept >= args.per_category:
                    break
                title = page.get("title", "")
                info = (page.get("imageinfo") or [{}])[0]
                meta = info.get("extmetadata", {})
                license_name = _strip_html(meta.get("LicenseShortName", {}).get("value", ""))
                description = _strip_html(meta.get("ImageDescription", {}).get("value", ""))
                if (
                    title in seen_titles
                    or info.get("mime") not in {"image/jpeg", "image/png"}
                    or not info.get("thumburl")
                    or not ALLOWED_LICENSES.match(license_name)
                    or RICE_WORDS.search(f"{title} {description}")
                ):
                    continue

                data = _get(info["thumburl"])
                sha256 = hashlib.sha256(data).hexdigest()
                if sha256 in seen_sha256:
                    continue
                kept += 1
                seen_titles.add(title)
                seen_sha256.add(sha256)
                target = IMAGES_DIR / category / f"{category}_{kept:03d}.jpg"
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(data)
                rows.append(
                    {
                        "fichier": target.relative_to(ROOT).as_posix(),
                        "categorie": category,
                        "sha256": sha256,
                        "titre": title,
                        "auteur": _strip_html(meta.get("Artist", {}).get("value", ""))[:200],
                        "licence": license_name,
                        "source": info.get("descriptionurl", ""),
                    }
                )
                time.sleep(PAUSE_SECONDS)
        print(f"{category}: {kept} photo(s)")

    if not rows:
        print("Aucune photo récupérée.")
        return 0

    with MANIFEST.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)
    print(f"{len(rows)} photo(s) consignée(s) dans {MANIFEST.relative_to(ROOT).as_posix()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
