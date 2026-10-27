#!/usr/bin/env python3
"""Consolide les images « feuille » des jeux publics pour l'entraînement (P4).

Copie, depuis les jeux déjà extraits (ml/scripts/extract_datasets.py) et
dhan_shomadhan (déjà en fichiers sur C:), chaque image dont la classe brute est
mappée par ml/label_map.yaml vers une classe de l'organe « feuille », dans une
arborescence par classe compatible avec tf.keras.utils.image_dataset_from_directory :

    <data-root>/prepared/feuille/<id_taxonomie>/<jeu>_<fichier>

Seul l'organe « feuille » est traité : c'est là que se trouve la quasi-totalité
des images publiques (~19 500 sur ~22 800 utiles, voir label_map_report.csv).
Les autres organes (tige_gaine, panicule_grains) ont trop peu d'images pour un
modèle séparé pour l'instant (voir ADR-008/rapport d'entraînement).

**Dédoublonnage avant découpage (--dedup-seuil, défaut 4) :** plusieurs jeux
publics se recoupent (mêmes photos reprises d'un jeu à l'autre, ou variantes
quasi identiques au sein d'un même jeu). train_feuille.py découpe train/val
*après* cette étape, au hasard par classe : sans dédoublonnage, une quasi-même
photo peut atterrir des deux côtés du découpage et gonfler artificiellement
l'exactitude de validation — risque d'autant plus grand que les classes rares
(cercosporiose, echaudure) ont peu d'images pour diluer l'effet. Réutilise le
hash perceptuel de ml/data/dedup.py (phash + distance de Hamming), mais garde
son propre calcul de hash local plutôt que d'importer `calculer_hashes` : ce
dernier suppose un dossier sous le dépôt git (`relative_to(ROOT)`), alors que
`<data-root>/prepared/` est en général hors dépôt (pas de bucket d'images,
voir ADR-008). Duplication mineure assumée : ce sont des scripts one-shot
indépendants (cf. les « recommandations écartées » contre un ml/scripts/common.py
mutualisé), pas une bibliothèque partagée à maintenir.

Usage :
    ml/.venv/Scripts/python ml/scripts/prepare_training_data.py
    ml/.venv/Scripts/python ml/scripts/prepare_training_data.py --data-root D:/agrimada-ml
    ml/.venv/Scripts/python ml/scripts/prepare_training_data.py --dedup-seuil 0  # désactive le dédoublonnage
"""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path, PurePosixPath

import yaml

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "ml" / "data" / "raw"
TAXONOMY = ROOT / "ml" / "taxonomy_v1.yaml"
LABEL_MAP = ROOT / "ml" / "label_map.yaml"
IMAGE_EXT = (".jpg", ".jpeg", ".png")

# id du jeu -> dossier contenant les fichiers déjà extraits.
# dhan_shomadhan est déjà en fichiers sur C: (jamais archivé, voir downloads.csv) ;
# les autres sont extraits par extract_datasets.py sur --data-root/raw/<id>/.
JEUX_DEJA_EXTRAITS_SUR_C = {"dhan_shomadhan": RAW / "dhan_shomadhan"}


def classe_of(chemin_relatif: str) -> str:
    parents = PurePosixPath(chemin_relatif).parts[:-1]
    return "/".join(parents[-2:]) or "(racine)"


def charger_organe_par_id() -> dict[str, str]:
    with TAXONOMY.open(encoding="utf-8") as handle:
        taxonomie = yaml.safe_load(handle)
    organe_par_id: dict[str, str] = {}
    for entree in taxonomie.get("porte", []):
        organe_par_id[entree["id"]] = "porte"
    for organe, problemes in taxonomie.get("problemes", {}).items():
        for entree in problemes:
            organe_par_id[entree["id"]] = organe
    return organe_par_id


def _hasher_repertoire(dossier: Path) -> dict[str, "object"]:
    """Hash perceptuel de chaque image sous `dossier`, clé = chemin relatif à
    `dossier` (pas au dépôt : voir la note en tête de fichier), toujours en
    slashes POSIX (`.as_posix()`) : sous Windows, `relative_to()` renvoie des
    antislashs, que `PurePosixPath(...).parts` (utilisé pour détecter un
    conflit inter-classes) ne découpe pas — chaque fichier semblerait alors
    appartenir à sa propre « classe » à lui tout seul."""
    import imagehash
    from PIL import Image

    hashes: dict[str, object] = {}
    for chemin in sorted(dossier.rglob("*")):
        if chemin.suffix.lower() not in IMAGE_EXT or not chemin.is_file():
            continue
        try:
            with Image.open(chemin) as image:
                hashes[chemin.relative_to(dossier).as_posix()] = imagehash.phash(image)
        except Exception as erreur:  # image corrompue ou illisible
            print(f"  [dedup] ignorée ({erreur}) : {chemin}")
    return hashes


def deduper_avant_decoupage(destination_racine: Path, seuil: int) -> None:
    """Retire les quasi-doublons de `destination_racine` avant que
    train_feuille.py ne découpe train/val (voir la note en tête de fichier).
    Un groupe de quasi-doublons à cheval sur plusieurs classes n'est PAS
    résolu automatiquement : en garder un au hasard masquerait une vraie
    erreur de correspondance dans label_map.yaml plutôt que la signaler."""
    if seuil <= 0:
        print("[dedup] désactivé (--dedup-seuil 0)")
        return

    sys.path.insert(0, str(ROOT / "ml" / "data"))
    from dedup import grouper_par_similarite  # noqa: E402

    hashes = _hasher_repertoire(destination_racine)
    groupes = grouper_par_similarite(hashes, seuil=seuil)

    supprimees = 0
    conflits: list[list[str]] = []
    for groupe in groupes:
        classes = {PurePosixPath(f).parts[0] for f in groupe}
        if len(classes) > 1:
            conflits.append(sorted(groupe))
            continue
        for fichier in sorted(groupe)[1:]:  # garde le premier (ordre déterministe), retire le reste
            (destination_racine / fichier).unlink()
            supprimees += 1

    print(f"[dedup] {len(hashes)} image(s) hashée(s), {supprimees} quasi-doublon(s) retiré(s) avant découpage (seuil {seuil}).")
    if conflits:
        print(f"[dedup] {len(conflits)} groupe(s) de quasi-doublons à cheval sur PLUSIEURS CLASSES, non résolus automatiquement (à vérifier dans label_map.yaml) :")
        for groupe in conflits[:10]:
            print(f"    {groupe}")
        if len(conflits) > 10:
            print(f"    ... et {len(conflits) - 10} de plus")


def nettoyer_en_preservant_la_porte(destination_racine: Path, organe_par_id: dict[str, str]) -> None:
    """Supprime et reconstruit (vide) `destination_racine`, en préservant les
    classes de la « porte » (ex. pas_riz, voir ml/taxonomy_v1.yaml) qu'y
    ajoute à part ml/scripts/add_negative_class.py. Sans ça, relancer
    prepare_training_data.py après coup les effacerait silencieusement avec
    le reste (aucune erreur, juste un modèle réentraîné sans porte —
    exactement le défaut du rapport du 2026-09-17). Les classes de l'organe
    traité, elles, n'ont pas besoin d'être préservées : la boucle de copie qui
    suit les repeuple entièrement à chaque lancement."""
    dossiers_porte_a_restaurer: dict[str, Path] = {}
    if destination_racine.exists():
        dossier_temp = destination_racine.parent / f".{destination_racine.name}_porte_temp"
        shutil.rmtree(dossier_temp, ignore_errors=True)
        for dossier_classe in destination_racine.glob("*"):
            if dossier_classe.is_dir() and organe_par_id.get(dossier_classe.name) == "porte":
                dossier_temp.mkdir(parents=True, exist_ok=True)
                cible = dossier_temp / dossier_classe.name
                shutil.move(str(dossier_classe), str(cible))
                dossiers_porte_a_restaurer[dossier_classe.name] = cible
                print(f"[porte] {dossier_classe.name} mis de côté (restauré après reconstruction).")

        print(f"[nettoyage] suppression de {destination_racine} (reconstruction)")
        shutil.rmtree(destination_racine)
    destination_racine.mkdir(parents=True, exist_ok=True)

    for nom, dossier_temp_classe in dossiers_porte_a_restaurer.items():
        shutil.move(str(dossier_temp_classe), str(destination_racine / nom))
    if dossiers_porte_a_restaurer:
        shutil.rmtree(destination_racine.parent / f".{destination_racine.name}_porte_temp", ignore_errors=True)


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data-root", type=Path, default=Path("D:/agrimada-ml"))
    parser.add_argument("--organe", default="feuille", help="organe à préparer (défaut feuille)")
    parser.add_argument(
        "--dedup-seuil", type=int, default=4,
        help="distance de Hamming max pour retirer les quasi-doublons avant découpage (0 = désactivé, défaut 4, comme ml/data/dedup.py)",
    )
    args = parser.parse_args()

    with LABEL_MAP.open(encoding="utf-8") as handle:
        label_map = yaml.safe_load(handle)["datasets"]
    organe_par_id = charger_organe_par_id()

    destination_racine = args.data_root / "prepared" / args.organe
    nettoyer_en_preservant_la_porte(destination_racine, organe_par_id)

    dossiers_extraits = {p.name: p for p in (args.data_root / "raw").glob("*") if p.is_dir()}
    dossiers_extraits.update(JEUX_DEJA_EXTRAITS_SUR_C)

    total_copiees = 0
    total_ignorees = 0

    for jeu, correspondances in label_map.items():
        dossier = dossiers_extraits.get(jeu)
        if dossier is None or not dossier.is_dir():
            print(f"[absent] {jeu} : dossier non trouvé sous {args.data_root} ou {RAW}")
            continue

        for chemin in sorted(dossier.rglob("*")):
            if not chemin.is_file() or chemin.suffix.lower() not in IMAGE_EXT:
                continue
            relatif = chemin.relative_to(dossier).as_posix()
            classe_brute = classe_of(relatif)
            id_taxonomie = correspondances.get(classe_brute)
            if id_taxonomie is None or id_taxonomie.startswith("exclu:") or id_taxonomie == "sans_etiquette":
                total_ignorees += 1
                continue
            if organe_par_id.get(id_taxonomie) != args.organe:
                continue

            dossier_classe = destination_racine / id_taxonomie
            dossier_classe.mkdir(parents=True, exist_ok=True)
            nom_fichier = f"{jeu}_{chemin.stem}{chemin.suffix.lower()}"
            shutil.copyfile(chemin, dossier_classe / nom_fichier)
            total_copiees += 1

        print(f"[fait] {jeu}")

    print(f"\n{total_copiees} image(s) copiée(s) vers {destination_racine}, {total_ignorees} ignorée(s) (exclues/sans étiquette/autre organe).")

    deduper_avant_decoupage(destination_racine, args.dedup_seuil)

    compte_final: dict[str, int] = {}
    for dossier_classe in sorted(p for p in destination_racine.iterdir() if p.is_dir()):
        n = sum(1 for f in dossier_classe.iterdir() if f.suffix.lower() in IMAGE_EXT)
        if n:
            compte_final[dossier_classe.name] = n

    print("\nRépartition finale par classe (après dédoublonnage) :")
    for classe, n in sorted(compte_final.items(), key=lambda kv: -kv[1]):
        print(f"  {n:>6}  {classe}")

    if len(compte_final) < 2:
        sys.exit("Moins de 2 classes trouvées : vérifier extract_datasets.py et le --data-root.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
