#!/usr/bin/env python3
"""Télécharge les jeux de données et documents publics listés dans ml/data/sources.yaml.

Usage :
    python ml/scripts/fetch_public_data.py                 # tout ce qui est téléchargeable
    python ml/scripts/fetch_public_data.py --only sethy_5932,fofifa
    python ml/scripts/fetch_public_data.py --list

Destinations (non versionnées) :
    ml/data/raw/<id>/            jeux de données
    knowledge/sources/<id>/      documents

Chaque fichier est vérifié (SHA-256 fourni par l'hébergeur quand il existe) et
consigné dans ml/data/raw/downloads.csv. Un fichier déjà présent et intact n'est
pas retéléchargé. Les requêtes passent par curl : l'API Mendeley refuse les
clients HTTP Python.
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path
from urllib.parse import quote, unquote, urlsplit

ROOT = Path(__file__).resolve().parents[2]
SOURCES = ROOT / "ml" / "data" / "sources.yaml"
RAW = ROOT / "ml" / "data" / "raw"
DOCS = ROOT / "knowledge" / "sources"
LOG = RAW / "downloads.csv"
MENDELEY_API = "https://data.mendeley.com/public-api"


def load_sources() -> dict:
    try:
        import yaml
    except ImportError:
        sys.exit("PyYAML est requis : pip install pyyaml")
    with SOURCES.open(encoding="utf-8") as f:
        return yaml.safe_load(f)


def curl(url: str, out: Path | None = None, timeout: int = 3600) -> bytes:
    cmd = ["curl", "-sSfL", "--retry", "3", "-m", str(timeout)]
    if out is not None:
        cmd += ["-o", str(out)]
    cmd.append(url)
    res = subprocess.run(cmd, capture_output=True)
    if res.returncode != 0:
        err = res.stderr.decode("utf-8", "replace").strip()
        raise RuntimeError(f"curl a échoué (code {res.returncode}) pour {url} : {err}")
    return res.stdout


def curl_json(url: str):
    return json.loads(curl(url, timeout=120).decode("utf-8"))


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def now() -> str:
    return dt.datetime.now().isoformat(timespec="seconds")


def write_log(rows: list[list]) -> None:
    RAW.mkdir(parents=True, exist_ok=True)
    is_new = not LOG.exists()
    with LOG.open("a", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        if is_new:
            writer.writerow(["date", "id", "fichier", "octets", "sha256", "url", "licence", "statut"])
        writer.writerows(rows)


def download(url: str, dest: Path, expected_sha: str | None = None,
             expected_size: int | None = None) -> tuple[str, str]:
    """Télécharge `url` vers `dest` ; renvoie (statut, sha256)."""
    if dest.exists() and (expected_size is None or dest.stat().st_size == expected_size):
        digest = sha256(dest)
        if expected_sha is None or digest == expected_sha:
            return "deja_present", digest

    dest.parent.mkdir(parents=True, exist_ok=True)
    partial = dest.with_name(dest.name + ".part")
    curl(url, partial)
    digest = sha256(partial)
    if expected_sha and digest != expected_sha:
        partial.unlink(missing_ok=True)
        raise RuntimeError(f"empreinte SHA-256 inattendue pour {dest.name}")
    partial.replace(dest)
    return "telecharge", digest


def row(src: dict, dest: Path, url: str, status: str, digest: str) -> list:
    return [now(), src["id"], dest.relative_to(ROOT).as_posix(), dest.stat().st_size,
            digest, url, src.get("licence", ""), status]


def mendeley_folders(base: str, version: int) -> list[tuple[str, str]]:
    """Renvoie (chemin, identifiant) de la racine et de chaque sous-dossier du jeu."""
    folders = curl_json(f"{base}/folders/{version}")
    by_id = {folder["id"]: folder for folder in folders}

    def path_of(folder: dict | None) -> str:
        parts, seen = [], set()
        while folder and folder["id"] not in seen:
            seen.add(folder["id"])
            parts.append(folder["name"])
            folder = by_id.get(folder.get("parent_id"))
        return "/".join(reversed(parts))

    return [("", "root")] + [(path_of(folder), folder["id"]) for folder in folders]


_WINDOWS_FORBIDDEN = str.maketrans({char: "_" for char in '<>:"|?*'})


def safe_relpath(*parts: str) -> Path:
    """Chemin relatif valide sous Windows : sans caractère interdit ni espace ou point final."""
    segments = []
    for part in parts:
        for segment in part.split("/"):
            cleaned = segment.translate(_WINDOWS_FORBIDDEN).strip().rstrip(".")
            if cleaned:
                segments.append(cleaned)
    return Path(*segments)


def fetch_mendeley(src: dict) -> list[list]:
    dataset_id = src["mendeley_id"]
    base = f"{MENDELEY_API}/datasets/{dataset_id}"
    version = src.get("version") or curl_json(base)["version"]
    excluded = set(src.get("exclude_folders", []))

    rows = []
    for folder_path, folder_id in mendeley_folders(base, version):
        if excluded & {segment.strip() for segment in folder_path.split("/")}:
            continue
        listing_url = f"{base}/files?folder_id={folder_id}&version={version}"
        for f in curl_json(listing_url):
            dest = RAW / src["id"] / safe_relpath(folder_path, f["filename"])
            details = f["content_details"]
            try:
                status, digest = download(details["download_url"], dest,
                                          details.get("sha256_hash"), details.get("size"))
            except RuntimeError:
                # Les liens de téléchargement signés expirent : relire la liste et réessayer une fois.
                fresh = {g["filename"]: g for g in curl_json(listing_url)}[f["filename"]]["content_details"]
                status, digest = download(fresh["download_url"], dest,
                                          fresh.get("sha256_hash"), fresh.get("size"))
            rows.append(row(src, dest, base, status, digest))

    if not rows:
        raise RuntimeError("aucun fichier trouvé dans ce jeu Mendeley")
    return rows


def fetch_huggingface(src: dict) -> list[list]:
    try:
        from huggingface_hub import hf_hub_download
    except ImportError as exc:
        raise RuntimeError("huggingface_hub est requis : pip install huggingface_hub") from exc

    rows = []
    for name in src["files"]:
        path = Path(hf_hub_download(src["repo_id"], name, repo_type="dataset",
                                    local_dir=RAW / src["id"]))
        url = f"https://huggingface.co/datasets/{src['repo_id']}/blob/main/{name}"
        rows.append(row(src, path, url, "telecharge_ou_present", sha256(path)))
    return rows


def fetch_kaggle(src: dict) -> list[list]:
    kaggle = shutil.which("kaggle")
    has_token = (Path.home() / ".kaggle" / "kaggle.json").exists() or (
        os.environ.get("KAGGLE_USERNAME") and os.environ.get("KAGGLE_KEY"))
    if not kaggle or not has_token:
        raise RuntimeError(
            "ignoré : installer le CLI Kaggle (pip install kaggle) et placer un jeton API "
            "dans ~/.kaggle/kaggle.json (kaggle.com › Settings › API)")

    dest_dir = RAW / src["id"]
    dest_dir.mkdir(parents=True, exist_ok=True)
    if src.get("competition"):
        cmd = [kaggle, "competitions", "download", "-c", src["competition"], "-p", str(dest_dir)]
        url = f"https://www.kaggle.com/competitions/{src['competition']}"
    else:
        cmd = [kaggle, "datasets", "download", "-d", src["dataset"], "-p", str(dest_dir)]
        url = f"https://www.kaggle.com/datasets/{src['dataset']}"
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        raise RuntimeError((res.stderr or res.stdout).strip())
    return [row(src, p, url, "telecharge", sha256(p)) for p in sorted(dest_dir.glob("*")) if p.is_file()]


def fetch_urls(src: dict) -> list[list]:
    rows = []
    errors = []
    for url in src["urls"]:
        safe_url = quote(url, safe=":/%?=&+")
        dest = DOCS / src["id"] / unquote(Path(urlsplit(url).path).name)
        try:
            status, digest = download(safe_url, dest)
            rows.append(row(src, dest, url, status, digest))
        except RuntimeError as exc:
            errors.append(str(exc))
    if errors:
        write_log(rows)
        raise RuntimeError(f"{len(errors)} document(s) en échec :\n    " + "\n    ".join(errors))
    return rows


FETCHERS = {
    "mendeley": fetch_mendeley,
    "huggingface": fetch_huggingface,
    "kaggle": fetch_kaggle,
    "urls": fetch_urls,
}


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--only", help="identifiants à traiter, séparés par des virgules")
    parser.add_argument("--list", action="store_true", help="affiche les sources sans rien télécharger")
    args = parser.parse_args()

    config = load_sources()
    entries = list(config.get("datasets", [])) + list(config.get("documents", []))
    wanted = set(args.only.split(",")) if args.only else None

    if args.list:
        for src in entries:
            print(f"{src['id']:<28} {src['type']:<12} {src.get('licence', '')}")
        return 0

    failures = 0
    for src in entries:
        if wanted and src["id"] not in wanted:
            continue
        print(f"→ {src['id']} ({src['type']})", flush=True)
        if src["type"] == "manual":
            print(f"  à télécharger à la main : {src['url']}  {src.get('note', '')}", flush=True)
            continue
        try:
            rows = FETCHERS[src["type"]](src)
            write_log(rows)
            for r in rows:
                print(f"  {r[7]:<22} {r[2]}  ({int(r[3]) / 1e6:.1f} Mo)", flush=True)
        except Exception as exc:  # une source en échec n'arrête pas les autres
            failures += 1
            print(f"  ÉCHEC : {exc}", flush=True)
            write_log([[now(), src["id"], "", "", "", "", src.get("licence", ""), f"echec : {exc}"]])

    print(f"\nTerminé, {failures} source(s) en échec. Journal : {LOG.relative_to(ROOT).as_posix()}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
