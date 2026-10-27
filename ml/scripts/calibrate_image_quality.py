"""Calibre le contrôle de qualité des photos (tâche P2.2).

Le contrôle embarqué refuse une photo floue, trop sombre, brûlée ou à
contre-jour. Pour choisir les seuils, on mesure de vraies photos de riz prises
au champ, puis les mêmes photos dégradées : floutées, sous-exposées,
surexposées et à contre-jour.

Le calcul reproduit lib/core/ai/image_quality.dart : réduction au plus grand
côté de 512 pixels (plus proche voisin), luminance 0,299 R + 0,587 V + 0,114 B,
variance du laplacien à 4 voisins.

    ml/.venv/Scripts/python ml/scripts/calibrate_image_quality.py
"""

from __future__ import annotations

import io
import json
import statistics
import zipfile
from datetime import date
from pathlib import Path

import numpy as np
from PIL import Image, ImageEnhance, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
REPORTS = ROOT / "ml" / "reports"
TAILLE_ANALYSE = 512
PAR_CLASSE = 40

SOURCES = [
    ("ml/data/raw/paddy_doctor/paddy-disease-classification.zip", "train_images/brown_spot/"),
    ("ml/data/raw/paddy_doctor/paddy-disease-classification.zip", "train_images/normal/"),
    ("ml/data/raw/mendeley_hx6f852hw4/Original/Original Images.zip", "Original Images/Bacterial Leaf Blight/"),
]


def reduire(image: Image.Image) -> Image.Image:
    cote = max(image.size)
    if cote <= TAILLE_ANALYSE:
        return image
    facteur = TAILLE_ANALYSE / cote
    return image.resize(
        (max(1, round(image.width * facteur)), max(1, round(image.height * facteur))),
        Image.NEAREST,
    )


def mesures(image: Image.Image) -> dict:
    reduite = reduire(image.convert("RGB"))
    tableau = np.asarray(reduite, dtype=np.float32)
    luminance = (
        0.299 * tableau[..., 0] + 0.587 * tableau[..., 1] + 0.114 * tableau[..., 2]
    )

    laplacien = (
        4 * luminance[1:-1, 1:-1]
        - luminance[:-2, 1:-1]
        - luminance[2:, 1:-1]
        - luminance[1:-1, :-2]
        - luminance[1:-1, 2:]
    )

    return {
        "nettete": float(laplacien.var()),
        "luminosite": float(luminance.mean() / 255.0),
        "part_brulee": float((luminance >= 250).mean()),
    }


def degradations(image: Image.Image) -> dict[str, Image.Image]:
    """Dégradations courantes au champ : bougé, ombre, plein soleil, contre-jour."""
    largeur, hauteur = image.size
    contre_jour = ImageEnhance.Brightness(image).enhance(0.35)
    bande = Image.new("RGB", (max(1, round(largeur * 0.15)), hauteur), (255, 255, 255))
    contre_jour.paste(bande, (0, 0))

    return {
        "floue_legere": image.filter(ImageFilter.GaussianBlur(radius=2)),
        "floue_forte": image.filter(ImageFilter.GaussianBlur(radius=5)),
        "sombre": ImageEnhance.Brightness(image).enhance(0.25),
        "brulee": ImageEnhance.Brightness(image).enhance(2.4),
        "contre_jour": contre_jour,
    }


def echantillon() -> list[Image.Image]:
    images: list[Image.Image] = []
    for archive, dossier in SOURCES:
        chemin = ROOT / archive
        if not chemin.exists():
            continue
        with zipfile.ZipFile(chemin) as zippe:
            noms = sorted(
                nom
                for nom in zippe.namelist()
                if nom.startswith(dossier) and nom.lower().endswith((".jpg", ".jpeg", ".png"))
            )
            pas = max(1, len(noms) // PAR_CLASSE)
            for nom in noms[::pas][:PAR_CLASSE]:
                images.append(Image.open(io.BytesIO(zippe.read(nom))).convert("RGB"))
    return images


def resume(valeurs: list[float]) -> dict:
    ordonnees = sorted(valeurs)
    return {
        "n": len(ordonnees),
        "min": round(ordonnees[0], 4),
        "p05": round(ordonnees[max(0, int(0.05 * len(ordonnees)) - 1)], 4),
        "mediane": round(statistics.median(ordonnees), 4),
        "p95": round(ordonnees[min(len(ordonnees) - 1, int(0.95 * len(ordonnees)))], 4),
        "max": round(ordonnees[-1], 4),
    }


def main() -> None:
    images = echantillon()
    if not images:
        raise SystemExit("Aucune photo de riz trouvée dans ml/data/raw/")

    groupes: dict[str, list[dict]] = {"nettes": [mesures(image) for image in images]}
    for image in images:
        for nom, degradee in degradations(image).items():
            groupes.setdefault(nom, []).append(mesures(degradee))

    stats = {
        nom: {
            "nettete": resume([m["nettete"] for m in mesures_groupe]),
            "luminosite": resume([m["luminosite"] for m in mesures_groupe]),
            "part_brulee": resume([m["part_brulee"] for m in mesures_groupe]),
        }
        for nom, mesures_groupe in groupes.items()
    }

    # Seuil de netteté : entre le flou léger et les photos nettes.
    nettes = sorted(m["nettete"] for m in groupes["nettes"])
    floues = sorted(m["nettete"] for m in groupes["floue_legere"])
    plancher_net = nettes[max(0, int(0.05 * len(nettes)) - 1)]
    plafond_flou = floues[min(len(floues) - 1, int(0.95 * len(floues)))]
    seuil_nettete = round((plancher_net + plafond_flou) / 2)

    # Seuils d'exposition : entre les photos dégradées et les cas extrêmes
    # des photos correctes.
    sombres = sorted(m["luminosite"] for m in groupes["sombre"])
    luminosites_nettes = sorted(m["luminosite"] for m in groupes["nettes"])
    seuil_sombre = round((sombres[-1] + luminosites_nettes[0]) / 2, 3)

    brulees = sorted(m["luminosite"] for m in groupes["brulee"])
    seuil_clair = round((brulees[0] + luminosites_nettes[-1]) / 2, 3)

    propositions = {
        "netteteMin": seuil_nettete,
        "luminositeMin": seuil_sombre,
        "luminositeMax": seuil_clair,
        "contreJourPartBrulee": resume(
            [m["part_brulee"] for m in groupes["contre_jour"]]
        )["p05"],
        "contreJourLuminosite": resume(
            [m["luminosite"] for m in groupes["contre_jour"]]
        )["p95"],
    }

    REPORTS.mkdir(parents=True, exist_ok=True)
    stamp = date.today().isoformat()
    sortie = REPORTS / f"qualite_photo_{stamp}.json"
    sortie.write_text(
        json.dumps(
            {"date": stamp, "photos": len(images), "mesures": stats, "propositions": propositions},
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )

    print(f"{len(images)} photos de riz mesurées, plus {len(groupes) - 1} dégradations chacune")
    for nom, valeurs in stats.items():
        print(
            f"  {nom:<14} netteté médiane {valeurs['nettete']['mediane']:>9.1f} | "
            f"luminosité médiane {valeurs['luminosite']['mediane']:.3f} | "
            f"brûlé médian {valeurs['part_brulee']['mediane']:.3f}"
        )
    print("propositions :", json.dumps(propositions, ensure_ascii=False))
    print(f"rapport : {sortie.relative_to(ROOT).as_posix()}")


if __name__ == "__main__":
    main()
