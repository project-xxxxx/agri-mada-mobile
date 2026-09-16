"""Récupère des photos hors sujet (tâche P1.2) depuis Wikimedia Commons.

Le critère de P1.2 exige qu'aucune photo hors sujet (sol, mains, maïs, herbes…)
ne soit présentée comme une maladie « probable ». Ce script constitue ce jeu :
50 photos réparties en 10 catégories, sous licence libre, avec leur auteur et
leur source consignés dans ml/data/eval/hors_sujet.csv (versionné). Les images
elles-mêmes vont dans ml/data/raw/hors_sujet/ (non versionné).

    ml/.venv/Scripts/python ml/scripts/fetch_off_topic.py
"""

from __future__ import annotations

import csv
import hashlib
import html
import json
import re
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
IMAGES_DIR = ROOT / "ml" / "data" / "raw" / "hors_sujet"
MANIFEST = ROOT / "ml" / "data" / "eval" / "hors_sujet.csv"

API = "https://commons.wikimedia.org/w/api.php"
USER_AGENT = "AgriMadaEval/1.0 (ISPM Madagascar; evaluation hors-sujet du modele)"
PER_CATEGORY = 5
# Largeur standard des vignettes Wikimedia : les autres tailles sont bridées.
THUMB_WIDTH = 960
PAUSE_SECONDS = 3

# Catégorie → requêtes Commons, de la plus précise à la plus large.
CATEGORIES: dict[str, list[str]] = {
    "sol": ["bare soil field", "laterite soil", "plowed soil"],
    "mains": ["human hand palm", "farmer hands", "hands close-up"],
    "mais": ["maize plant leaves", "corn field leaves", "Zea mays leaf"],
    "herbes": ["grass close-up", "lawn grass blades", "Poaceae meadow"],
    "canne_a_sucre": ["sugarcane leaves", "sugarcane field"],
    "eau": ["pond water surface", "irrigation canal water"],
    "outils": ["hoe farm tool", "shovel garden tool", "machete tool"],
    "zebus": ["zebu Madagascar", "zebu cattle"],
    "ecrans": ["smartphone screen", "computer monitor screen"],
    "autres_feuilles": ["cassava leaves", "banana leaf", "bean plant leaves"],
}

ALLOWED_LICENSES = re.compile(r"^(cc0|cc[- ]by(-sa)?[- ][\d.]+|public domain|pd)", re.I)
# Les photos qui pourraient montrer du riz fausseraient l'essai.
RICE_WORDS = re.compile(r"rice|paddy|oryza|riz|rizi|vary", re.I)


def _get(url: str, params: dict | None = None, attempts: int = 6) -> bytes:
    """GET poli : respecte Retry-After et recule progressivement sur 429 / 503."""
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
            wait = int(retry_after) if retry_after.isdigit() else min(60, 5 * 2 ** attempt)
            print(f"  serveur saturé ({error.code}), nouvel essai dans {wait} s")
            time.sleep(wait)
    raise RuntimeError("inaccessible")


def _strip_html(value: str) -> str:
    return html.unescape(re.sub(r"<[^>]+>", "", value)).strip()


def _candidates(query: str) -> list[dict]:
    payload = json.loads(
        _get(
            API,
            {
                "action": "query",
                "format": "json",
                "generator": "search",
                "gsrsearch": f"{query} filetype:bitmap",
                "gsrnamespace": 6,
                "gsrlimit": 30,
                "prop": "imageinfo",
                "iiprop": "url|extmetadata|mime",
                "iiurlwidth": THUMB_WIDTH,
            },
        )
    )
    pages = sorted(payload.get("query", {}).get("pages", {}).values(), key=lambda p: p.get("index", 0))
    return pages


def main() -> None:
    IMAGES_DIR.mkdir(parents=True, exist_ok=True)
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    rows: list[dict] = []
    seen_titles: set[str] = set()

    for category, queries in CATEGORIES.items():
        kept = 0
        for query in queries:
            if kept >= PER_CATEGORY:
                break
            for page in _candidates(query):
                if kept >= PER_CATEGORY:
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
                kept += 1
                seen_titles.add(title)
                target = IMAGES_DIR / category / f"{category}_{kept:02d}.jpg"
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(data)
                rows.append(
                    {
                        "fichier": target.relative_to(ROOT).as_posix(),
                        "categorie": category,
                        "sha256": hashlib.sha256(data).hexdigest(),
                        "titre": title,
                        "auteur": _strip_html(meta.get("Artist", {}).get("value", ""))[:200],
                        "licence": license_name,
                        "source": info.get("descriptionurl", ""),
                    }
                )
                time.sleep(PAUSE_SECONDS)  # politesse envers Wikimedia
        print(f"{category}: {kept} photo(s)")

    with MANIFEST.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)
    print(f"{len(rows)} photos consignées dans {MANIFEST.relative_to(ROOT).as_posix()}")


if __name__ == "__main__":
    main()
