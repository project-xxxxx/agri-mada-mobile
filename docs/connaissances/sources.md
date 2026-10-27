# Registre des sources de connaissances

Les documents eux-mêmes sont dans `knowledge/sources/` (non versionné : droits de
diffusion variables). Ce registre, lui, est versionné : il dit d'où vient chaque
connaissance, ce qu'on a le droit d'en faire, et ce qui entrera dans le RAG des
fiches (P5.1).

Les identifiants de la colonne « id » sont ceux utilisés par `ml/taxonomy_v1.yaml`
et, plus tard, par les fiches et le RAG.

## Règles de diffusion

1. **Aucun produit, aucune matière active, aucune dose** n'est repris dans l'app,
   quelle que soit la source (ADR-001, tâche P1.1). Les passages « lutte chimique »
   des sources restent réservés aux techniciens, dans le document d'origine.
2. Une connaissance affichée à l'agriculteur cite sa source et son année.
3. Les documents sous droits ne sont ni republiés ni recopiés intégralement : le
   dépôt n'en garde que des notes et des références.

## Cours (école partenaire)

| id | Document | Origine | Fichier local | Diffusion |
|---|---|---|---|---|
| `cours_epsa_pathologie_riz` | *Reconnaissance et gestion intégrée des principales maladies du riz*, 85 diapositives | École professionnelle supérieure agricole, niveau L2 | `knowledge/sources/cours/Pathologie riz.pdf` | Usage interne et RAG ; pas de republication |
| `cours_rafalimanana_maladies_riz` | *Importance des maladies de riz et proposition de lutte*, 25 diapositives | Halitiana Rafalimanana (contexte malgache : Vakinankaratra, Alaotra) | `knowledge/sources/cours/Maladies de riz.pdf` | Usage interne et RAG ; pas de republication |

Reçus le 16 septembre 2026. Notes de lecture : [cours-pathologie-riz.md](cours-pathologie-riz.md).

## Fiches FOFIFA et documents malgaches

Répertoriés dans `ml/taxonomy_v1.yaml` (section `sources`), fichiers dans
`knowledge/sources/fofifa/`. Principales fiches utilisées jusqu'ici :
`fofifa_blb_bls`, `fofifa_aretina_alaotra`, `fofifa_bibikely_alaotra`,
`fofifa_voana_metarhizium`, `fofifa_catalogue_rpa`, `fofifa_p_dipping`.

## Références scientifiques

Fichiers dans `knowledge/sources/references_scientifiques/`, identifiants dans la
même section `sources` : `cirad_pyriculariose`, `cirad_maliarpha`,
`ird_toxicite_ferreuse`, `cirad_toxicite_ferreuse`, `nematodes_madagascar_2016`,
`rymv_madagascar`.

## Jeux d'images

Les jeux de photos sont suivis à part : `ml/DATASETS.md` et `ml/data/sources.yaml`
(licences, volumes), plus `ml/data/eval/hors_sujet.csv` pour les 50 photos hors
sujet de l'évaluation P1.2.
