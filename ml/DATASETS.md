# Registre des jeux de données AgriMada

Tâche P0.4 du plan de correction. Ce registre est la seule porte d'entrée des images dans l'entraînement : un jeu absent d'ici n'est pas utilisé.

- **Sources et paramètres de téléchargement :** `ml/data/sources.yaml`
- **Téléchargement :** `python ml/scripts/fetch_public_data.py` (dépendances : `ml/requirements.txt`)
- **Destination :** `ml/data/raw/<id>/` pour les images, `knowledge/sources/<id>/` pour les documents. Ces dossiers ne sont pas versionnés.
- **Journal :** `ml/data/raw/downloads.csv`, avec date, fichier, taille, SHA-256, URL, licence et statut de chaque fichier

Identifiants utilisés dans `ml/taxonomy_v1.yaml` : colonne **id**.

## Règles

1. **Licences.** Décision d'équipe du 2026-09-14 : les jeux retenus sont des projets publics et peuvent être utilisés. Pour les jeux sous CC BY, citer la source (champ `attribution` de `sources.yaml`) dans toute publication ou tout rapport. IP102 est libre pour un usage académique uniquement.
2. **Test uniquement sur photos malgaches.** Aucun jeu public n'entre dans le jeu de test : il mesure ce que l'app fera à Madagascar.
3. **Images déjà augmentées exclues.** Elles ne sont pas téléchargées quand l'hébergeur les sépare (par exemple le dossier `Augmented` de `mendeley_hx6f852hw4`). Sinon, elles sont écartées de la validation et du test.
4. **Déduplication avant découpage.** Empreinte perceptuelle sur toutes les images, publiques et locales, avant de répartir entraînement, validation et test.
5. **Découpage par site et par parcelle**, jamais par photo, pour les données locales.
6. **Classes exclues.** Le tungro, absent de Madagascar, est écarté (voir `exclusions` dans la taxonomie).
7. **Traçabilité.** Chaque image du manifeste (P3.6) porte l'id de son jeu et sa licence.

## Jeux publics

| id | Jeu | Images | Classes utiles | Organes | Conditions | Licence | Récupération | Usage prévu |
|---|---|---|---|---|---|---|---|---|
| `sethy_5932` | [Rice Leaf Disease Image Samples](https://data.mendeley.com/datasets/fwcj7stb8r/2) | 5 932 | BLB, pyriculariose, helminthosporiose (tungro exclu) | feuille | terrain, Odisha (Inde), une partie issue du web | CC BY 4.0 | script (archive `.7z`, 179 Mo) | entraînement |
| `riceseg_5932` | [RiceSeg-5932](https://data.mendeley.com/datasets/92jc6w6mcy/1) | 5 932 masques | masques des lésions de `sethy_5932` | feuille | segmentation | CC BY 4.0 | script (21 Mo) | évaluer où regarde le modèle |
| `mendeley_hx6f852hw4` | [Rice Leaf Bacterial and Fungal Disease Dataset](https://data.mendeley.com/datasets/hx6f852hw4/2) | 1 701 originales | BLB, helminthosporiose, pyriculariose, échaudure, hispa, cercosporiose, rhizoctone, sain | feuille, gaine | terrain, smartphone, Bangladesh | CC BY 4.0 | script, dossier `Original` seulement | entraînement |
| `dhan_shomadhan` | [Dhan-Shomadhan](https://data.mendeley.com/datasets/znsxdctwtt/1) | 1 106 | helminthosporiose, pyriculariose, échaudure, rhizoctone (tungro exclu) | feuille | fonds terrain et blanc, Bangladesh | CC BY 4.0 | script | robustesse au fond de l'image |
| `riceleafbd` | [RiceLeafBD](https://data.mendeley.com/datasets/kx9rx8p2mz/1) | 1 555 | BLB, helminthosporiose, sain (tungro exclu) | feuille | terrain, smartphone, Sylhet et Dhaka (Bangladesh), validé par des experts | CC BY 4.0 | script (498 Mo) | entraînement |
| `hf_rice_disease` | [Rice-Disease-Classification-Dataset](https://huggingface.co/datasets/Subh775/Rice-Disease-Classification-Dataset) | 4 078 | pyriculariose du cou, pyriculariose foliaire, helminthosporiose, sain | feuille, panicule | à examiner | Apache-2.0 | script (archive de 2 Go) | panicule |
| `paddy_doctor` | [Paddy Doctor](https://arxiv.org/abs/2205.11108), [compétition Kaggle](https://www.kaggle.com/competitions/paddy-disease-classification) | 10 407 étiquetées + 3 469 de test sans étiquette | BLB, BLS, pyriculariose, helminthosporiose, hispa, cœur mort (foreurs), sain ; mildiou et brunissure bactérienne de la panicule à confirmer | feuille, tige, panicule | terrain, smartphone, Inde ; variété et âge de la plante dans `train.csv` | CC BY | ajout manuel depuis Kaggle (1,09 Go) | socle du pré-entraînement |
| `nutrient_deficiency_rice` | [Nutrient-Deficiency-Symptoms-in-Rice](https://www.kaggle.com/datasets/guy007/nutrientdeficiencysymptomsinrice) | 1 156 | carences en azote, phosphore, potassium | feuille | à examiner | non précisée | ajout manuel depuis Kaggle (1,04 Go) | distinguer carence et maladie |
| `ip102` | [IP102](https://github.com/xpwu95/IP102) (14 classes riz sur 102) | 8 417 riz | insectes du riz (foreurs, cécidomyie, enrouleuse, cicadelles…) | insecte | espèces surtout asiatiques | usage académique | à la main (Google Drive), reporté | plus tard : module insecte |

### Jeux écartés

| Jeu | Raison |
|---|---|
| [BanglaRiceLeaf](https://pubmed.ncbi.nlm.nih.gov/42434504/) | aucun lien de téléchargement public trouvé |
| [Rice grain disease (BRRI)](https://arxiv.org/abs/2004.09870) | données non publiées |
| [Automatic Diagnosis of Rice Diseases](https://pmc.ncbi.nlm.nih.gov/articles/PMC8416767/) (33 026 images) | données non publiées |
| [RiceyLeafDisease](https://data.mendeley.com/datasets/t46kkgh2yw/1) | doublon de `mendeley_hx6f852hw4` (même description, mêmes auteurs) |
| [Annotated Rice Panicle Image](https://data.mendeley.com/datasets/ndb6t28xbk/4) | détection de panicules par drone, sans maladies |
| [Rice Leaf Diseases (Kaggle, 120 images)](https://www.kaggle.com/datasets/vbookshelf/rice-leaf-diseases) | jeu du modèle actuel, feuilles détachées sur fond blanc |
| Jeu Kaggle de 11 790 images cité dans [arXiv 2512.22239](https://arxiv.org/pdf/2512.22239) | déjà augmenté, source exacte non identifiée |

### Contenu vérifié (2026-09-14)

Comptes produits par `python ml/scripts/inventory_raw.py` ; détail dans `ml/data/raw/inventory.csv`. La colonne « Utiles » exclut les classes écartées (tungro).

| id | Images | Répartition | Utiles |
|---|---|---|---|
| `sethy_5932` | 5 932 | BLB 1 584 · pyriculariose 1 440 · helminthosporiose 1 600 · tungro 1 308 | 4 624 |
| `riceseg_5932` | 5 932 masques | un masque par image de `sethy_5932` | sans objet |
| `mendeley_hx6f852hw4` | 1 701 | BLB 180 · helminthosporiose 267 · sain 157 · pyriculariose 305 · échaudure 189 · cercosporiose 117 · hispa 215 · rhizoctone 271 | 1 701 |
| `riceleafbd` | 1 560 (1 555 annoncées) | BLB 422 · helminthosporiose 356 · sain 252 · tungro 530 | 1 030 |
| `hf_rice_disease` | 4 078 | helminthosporiose 613 · sain 1 488 · pyriculariose foliaire 977 · pyriculariose du cou 1 000 | 4 078 |
| `dhan_shomadhan` | 1 106 (fond terrain 337, fond blanc 769) | helminthosporiose 139 · échaudure 217 · pyriculariose 272 · rhizoctone 283 · tungro 195 | 911 |
| `paddy_doctor` | 10 407 étiquetées (+ 3 469 de test sans étiquette) | sain 1 764 · pyriculariose 1 738 · hispa 1 594 · cœur mort 1 442 · helminthosporiose 965 · mildiou 620 · BLB 479 · BLS 380 · brunissure bactérienne de la panicule 337 · tungro 1 088 | 9 319 |
| `nutrient_deficiency_rice` | 1 156 | azote 440 · phosphore 333 · potassium 383 | 1 156 |

**Total :** 25 940 photos étiquetées, dont 22 819 utiles. S'y ajoutent 3 469 photos de test sans étiquette (Paddy Doctor) et 5 932 masques. Environ 8,4 Go dans `ml/data/raw/`.

Ces jeux portent surtout sur la feuille. Hors feuille, on dispose de 1 442 photos de cœur mort causé par les foreurs (tige), 1 000 de pyriculariose du cou, 554 de rhizoctone de la gaine et 337 de brunissure bactérienne de la panicule. La présence à Madagascar du rhizoctone, du mildiou et de la brunissure bactérienne de la panicule reste à confirmer.

## Documents de référence

Récupérés par le même script dans `knowledge/sources/`, pour la base de fiches et le RAG (P5).

| id | Contenu | Licence |
|---|---|---|
| `fofifa` | 37 fiches techniques riz du site FOFIFA : bactérioses (FR et MG), maladies et insectes de l'Alaotra, *voana* et Metarhizium, bonnes pratiques, calendriers MIRR, P-dipping, fiches variétales | documents publics, citer FOFIFA |
| `references_scientifiques` | IRD (toxicité ferreuse dans les rizières), mémoire CIRAD (pyriculariose du riz pluvial au Vakinankaratra), IRRI (diagnostic des maladies courantes du riz) | libre accès, citer la source |

## Classes sans données publiques

Aucun jeu public trouvé pour : racines de riz (toutes classes), RYMV malgache (*mavoratsy*), dégâts de *voana*, toxicité ferreuse, pourriture de la gaine, stérilité due au froid, dégâts de punaises. Ces classes dépendent entièrement de la collecte locale (P3.3 à P3.5).

## Données locales

| id | Origine | Consentement | Statut |
|---|---|---|---|
| `collecte_mg_v1` | Mode collecte de l'app (P3.3), sites Vakinankaratra, Alaotra, Marovoay, côte Est | formulaire `docs/donnees/consentement-photos.md`, version enregistrée avec chaque photo | à venir |
| `negatifs_v1` | Photos locales et images sous licence ouverte (Open Images, iNaturalist) | sans objet pour les images publiques | à venir |

## Journal des décisions

| Date | Décision |
|---|---|
| 2026-09-14 | Registre initial. |
| 2026-09-14 | Licences acceptées par l'équipe (projets publics). Récupération directe des données publiques, sans convention préalable. RiceLeafBD ajouté ; RiceyLeafDisease et le jeu de panicules par drone écartés. |
