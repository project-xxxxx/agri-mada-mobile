# Entraînement du classifieur feuille sur les jeux publics consolidés (2026-09-17)

Candidat expérimental, pas un remplacement du modèle embarqué. Produit par
`ml/scripts/train_feuille.py`, à partir des jeux publics déjà rassemblés
(P3.2/P3.6) plutôt que d'une collecte terrain (ADR-008). Remplace le
notebook `Model/entrainementIA.ipynb` (3 classes, 120 images Kaggle sans
classe saine) comme référence de ce qu'on peut faire avec les données déjà
en main — pas encore comme modèle intégré à l'app.

**Deux versions dans ce document :** un premier essai (12 classes, sans
porte) a d'abord donné 89,2 % d'exactitude, puis un examen a montré que ce
chiffre était gonflé par des quasi-doublons entre train et validation. La
version courante (13 classes, avec dédoublonnage et porte) corrige les deux
défauts trouvés lors du premier essai — voir « Historique » en bas de page.

## Méthode (version courante)

- **Données :** 14 942 images « feuille », 13 classes (12 maladies/carences
  + `pas_riz`), consolidées depuis 8 jeux publics via `ml/label_map.yaml`
  (`ml/scripts/prepare_training_data.py`) plus 420 photos négatives
  (`ml/scripts/fetch_negatives.py`, Wikimedia Commons). **Dédoublonnage par
  empreinte perceptuelle avant découpage** (`ml/data/dedup.py`, seuil 4) :
  4 964 quasi-doublons retirés sur 19 906 images (25 %) — plusieurs jeux
  publics se recoupent (mêmes photos ou variantes quasi identiques). Sans ce
  dédoublonnage, une quasi-même photo peut atterrir des deux côtés du
  découpage train/validation et gonfler artificiellement l'exactitude
  mesurée. Répartition 80/20 (11 955 / 2 987), graine 123.
- **Modèle :** MobileNetV2 gelé (poids ImageNet, `pooling='avg'`) + tête
  dense (256 → 13, dropout 0,4, sortie en logits). Features calculées une
  seule fois et mises en cache par fichier (`ml/models/feuille_v2/cache/`) —
  toujours pas de GPU utilisable sur cette machine (pilote NVIDIA 425.46,
  CUDA 10.1, trop ancien pour TensorFlow ≥ 2.11 sur Windows natif, voir
  ADR-008).
- **Régularisation :** lissage des étiquettes (0,05) et mixup en espace
  features (α = 0,2, Zhang et al. 2018 — mélange convexe de paires
  d'exemples déjà encodés, sans nouvelle passe dans MobileNetV2), avec
  rééquilibrage des classes rares par tirage pondéré. Ajoutés après le
  premier essai pour réduire la sur-confiance du softmax.
- **Calibration par température** (Guo et al. 2017) : ajustée sur les
  logits de validation puis intégrée au graphe exporté.
- **Entraînement :** 40 epochs, `EarlyStopping`/`ReduceLROnPlateau` sur
  `val_loss` (jamais déclenché).
- **Export :** le graphe exporté attend des pixels **déjà normalisés en
  [0, 1]** (`Rescaling(2.0, -1.0)` puis MobileNetV2), pour correspondre
  exactement à `lib/core/ai/tflite_service.dart` (`pixel.rNormalized`) — le
  premier essai supposait des pixels bruts [0, 255], ce qui aurait cassé un
  déploiement sans erreur visible. Fichiers dans `ml/models/feuille_v2/` :
  `model.tflite` (2,8 Mo), `labels.txt`, `metrics.json`,
  `confusion_matrix.csv` (`saved_model/` et `cache/` non versionnés).

## Résultats sur la validation (2 987 images, jeux publics)

**Exactitude globale : 83,0 %, macro-F1 : 83,6 %.** Plus bas que les 89,2 %
du premier essai — c'est attendu et plus honnête : ce premier chiffre
mesurait en partie la capacité du modèle à reconnaître des quasi-doublons de
ses propres images d'entraînement, pas de vraies images inédites.

| Classe | Support | Précision | Rappel | F1 |
|---|---:|---:|---:|---:|
| carence_azote | 87 | 99 % | 99 % | 99 % |
| **pas_riz** | 84 | 94 % | 98 % | **96 %** |
| carence_phosphore | 66 | 93 % | 95 % | 94 % |
| carence_potassium | 76 | 96 % | 92 % | 94 % |
| bls | 57 | 87 % | 96 % | 92 % |
| blb | 289 | 87 % | 85 % | 86 % |
| feuille_saine | 670 | 84 % | 86 % | 85 % |
| degats_hispa | 297 | 79 % | 83 % | 81 % |
| mildiou | 97 | 74 % | 87 % | 80 % |
| helminthosporiose | 517 | 84 % | 76 % | 80 % |
| pyriculariose_feuille | 648 | 82 % | 78 % | 80 % |
| echaudure | 76 | 58 % | 75 % | 66 % |
| **cercosporiose** | **23** | **46 %** | **70 %** | **55 %** |

`cercosporiose` (92 images d'entraînement) et `echaudure` (306) restent les
classes les plus fragiles — sans surprise, ce sont les moins représentées.
Calibration : ECE 0,046 → 0,019 après température (T = 0,821), Brier 0,252 →
0,249 — les probabilités affichées sont un peu plus honnêtes, mais la
calibration ne remplace pas la porte (ci-dessous).

## La porte change vraiment le comportement sur les photos hors sujet

Le jeu hors sujet de P1.2 (50 photos, aucune n'est du riz — sol, mains,
outils, zébus…), **jamais vu à l'entraînement** (`fetch_negatives.py` exclut
ses sha256), a été repassé dans ce modèle :

| Mesure | Premier essai (sans porte) | Version courante (avec porte) |
|---|---:|---:|
| Rejetées comme `pas_riz` | 0 / 50 (pas de classe de rejet) | **41 / 50** |
| Prises pour une feuille saine | — | 1 / 50 |
| Maladie nommée à tort | toutes (une classe est toujours choisie) | **8 / 50** |
| Confiance ≥ 0,70 | 37 / 50 | 42 / 50 |
| Confiance ≥ 0,90 | 23 / 50 | 37 / 50 |

La colonne « confiance » se lit différemment selon la version : sans porte,
une confiance élevée signifiait toujours une maladie affirmée à tort. Avec
la porte, une confiance élevée est *voulue* quand la prédiction est
`pas_riz` — ce qui arrive pour 41 des 50 photos (82 %). Il reste **8 photos
sur 50 (16 %) avec une maladie nommée à tort**, et 1 prise pour une feuille
saine : mieux qu'avant, mais pas encore fiable pour un usage réel.

*Correction du 2026-09-17 :* une première version de ce rapport indiquait
« 9/50 étiquetées à tort comme une maladie ». `metrics.json` ne compte que les
rejets (41) ; la répartition des 9 autres a été mesurée ensuite en repassant
les 50 photos dans `saved_model/` : 8 maladies et 1 feuille saine.

## Constat inattendu : quasi-doublons à cheval sur plusieurs classes

Le dédoublonnage a mis au jour **145 groupes de quasi-doublons répartis sur
plusieurs classes différentes** (ex. une même photo, ou une variante très
proche, présente à la fois dans `blb` et `helminthosporiose`, ou dans `bls`
et `mildiou`). `ml/scripts/prepare_training_data.py` ne les résout pas
automatiquement : masquer un de ces cas au hasard cacherait une possible
erreur de correspondance dans `ml/label_map.yaml` plutôt que de la signaler.
**À vérifier avant tout entraînement ultérieur** — la liste complète est
dans la sortie de `prepare_training_data.py` (non conservée automatiquement,
à relancer pour l'obtenir).

## Conséquence pour l'app

Ce modèle reste un candidat expérimental dans `ml/models/feuille_v2/`,
**non intégré à l'app** (`assets/model/` non touché). La discussion du
2026-09-16/17 sur ce point (voir mémoire projet) tient toujours : même avec
la porte, ce modèle n'a jamais vu de photo malgaque et ne remplit pas le
critère d'acceptation P4.6 (jeu de test malgache, collecte non engagée,
ADR-008). Les 8/50 maladies nommées à tort, même réduites, suffisent à ne pas
le déployer sans décision explicite de l'équipe. L'architecture à trois
étages qui a suivi est comparée à ce modèle dans
`ml/reports/architecture_3_etages_2026-09-17.md`.

## Prochaines étapes (P4, pas engagées ici)

1. Élucider les 145 groupes de quasi-doublons inter-classes : erreur de
   `label_map.yaml`, ou vraie ambiguïté visuelle entre maladies proches ?
2. `cercosporiose` et `echaudure` resteront fragiles tant que leurs jeux
   publics ne sont pas complétés — `--kfold` (ajouté à `train_feuille.py`)
   permettrait de vérifier si leur faiblesse est structurelle ou due au
   découpage 80/20 précis de ce run.
3. Toujours mesuré uniquement sur des photos publiques (Inde, Bangladesh) :
   ne remplit pas le critère P4.6.
4. Pas de fine-tuning du réseau de base (features gelées, contrainte CPU) :
   marge de progression si un GPU ou plus de temps de calcul devient
   disponible.

## Historique

| Date | Changement |
|---|---|
| 2026-09-17 (premier essai) | 12 classes, sans dédoublonnage ni porte : 89,2 % d'exactitude, mais 37/50 photos hors sujet à confiance ≥ 0,70 (pire que le modèle actuel) |
| 2026-09-17 (version courante) | + dédoublonnage (-25 % d'images), + classe `pas_riz`, + label smoothing/mixup/calibration, + contrat d'entrée [0,1] aligné sur l'app : 83,0 % d'exactitude (plus honnête), 41/50 photos hors sujet rejetées, 8/50 avec une maladie nommée à tort |
