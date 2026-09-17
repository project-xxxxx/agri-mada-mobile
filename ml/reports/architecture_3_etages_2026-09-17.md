# Architecture à trois étages (P4.2) : premier essai (2026-09-17)

Candidats expérimentaux, **non intégrés à l'app** (`assets/model/` non
touché). Comparés au modèle plat `ml/models/feuille_v2` (13 classes dans un
seul softmax, voir `ml/reports/entrainement_feuille_2026-09-17.md`) sur les
**mêmes données et la même validation** : 14 942 images publiques
dédoublonnées, découpage stratifié 80/20, graine 123, 2 987 images de
validation. Tout est mesuré sur des photos publiques (Inde, Bangladesh,
Wikimedia), jamais sur des photos malgaches : aucun chiffre ci-dessous ne
remplit le critère P4.6.

## Ce qui a été construit

| Étage | Plan (P4.2) | Construit | Pourquoi l'écart |
|---|---|---|---|
| A — porte | 8 sorties : 6 organes, pas du riz, photo inexploitable | `ml/models/porte_v1` : 2 sorties, `pas_riz` / `riz_exploitable` | Aucune photo publique de collet, racines ou plante entière, très peu de tige et de panicule. L'organe est déjà choisi par l'agriculteur (P2.1) et la photo inexploitable déjà refusée par des seuils de netteté et d'exposition (P2.2). |
| B — organe | Un modèle multi-étiquette par organe | `ml/models/feuille_multilabel_v1` : feuille seulement, 11 sorties sigmoïdes, seuil par classe, « saine » quand rien ne dépasse | Seul organe avec des données. Les autres restent sur questionnaire + technicien, comme aujourd'hui. |
| C — fusion | Règles de P2.4 alimentées par les sorties calibrées | `ml/scripts/eval_chaine.py` : décision déterministe porte puis organe, pour mesurer la chaîne | Le branchement dans `lib/core/ai/diagnosis_fusion.dart` relève de P4.5 (intégration), non engagée. |

Scripts : `ml/scripts/train_porte.py`, `ml/scripts/train_feuille_multilabel.py`,
`ml/scripts/eval_chaine.py`, tests dans `ml/scripts/test_architecture_3_etages.py`
(8 tests). Les deux modèles réutilisent le cache de features de
`train_feuille.py` : aucune nouvelle passe dans MobileNetV2, quelques minutes
par entraînement sur CPU.

## Résultats

### Étage A seul (porte)

| Mesure | Résultat | Cible P4.6 |
|---|---:|---:|
| Photos négatives rejetées, validation interne | 98,8 % | ≥ 95 % |
| Riz exploitable rejeté à tort, validation interne | 0,0 % | ≤ 5 % |
| **Photos hors sujet P1.2 rejetées (jamais vues)** | **82 % (41/50)** | ≥ 95 % |

L'écart entre 98,8 % et 82 % est le résultat important : les photos
négatives de validation viennent du même script et des mêmes requêtes
Wikimedia que celles d'entraînement. La porte a appris leur style plus que
« ce qui n'est pas du riz ». Seul le jeu indépendant dit la vérité, et il est
sous la cible. Même score que la classe `pas_riz` du modèle plat : séparer la
porte ne l'a pas rendue meilleure à rejeter.

### Chaîne complète contre modèle plat (même validation)

| | Chaîne A → B | Modèle plat `feuille_v2` |
|---|---:|---:|
| Exactitude (13 réponses) | 78,7 % | **83,0 %** |
| Macro-F1 | 82,3 % | **83,6 %** |
| F1 `feuille_saine` | 0,70 | **0,85** |
| F1 `pas_riz` | **0,99** | 0,96 |

Les maladies ont des F1 très proches d'un modèle à l'autre (écart de ±0,02,
sauf `bls` un peu meilleur dans la chaîne). **Presque tout l'écart vient des
feuilles saines** : dans la chaîne, 26 % d'entre elles déclenchent au moins
une maladie. Les seuils de l'étage B sont choisis classe par classe pour le
meilleur F1, ce qui les pousse bas (0,18 pour la pyriculariose, 0,20 pour
l'hispa, 0,23 pour l'helminthosporiose) : chaque classe est optimisée seule,
personne n'optimise « ne rien signaler sur une feuille saine ». Or ADR-006 a
précisément été écrit parce que le modèle actuel déclarait malades 105
feuilles saines sur 200.

### Photos hors sujet P1.2 (50, jamais vues)

| | Chaîne A → B | Modèle plat `feuille_v2` |
|---|---:|---:|
| Rejetées (`pas_riz`) | 41 | 41 |
| Prises pour une feuille saine | 6 | 1 |
| **Maladie nommée à tort** | **3** | **8** |

Sur l'erreur la plus grave, nommer une maladie sur une photo de sol ou de
zébu, la chaîne fait nettement mieux : 3 au lieu de 8. Sans la porte, l'étage
B seul en déclencherait 26 sur 50.

## Lecture honnête

Aucun des deux modèles ne domine l'autre :
- le **modèle plat** reconnaît mieux les feuilles saines (moins de fausses
  alertes sur du riz sain) ;
- la **chaîne** nomme moins souvent une maladie sur une photo qui n'est pas
  du riz, et sa structure correspond à celle du plan (ajout d'organes au fil
  des données, plusieurs problèmes par feuille possibles).

Aucun ne remplit P4.6 : la porte rejette 82 % des photos hors sujet
indépendantes (cible 95 %), et rien n'est mesuré sur des photos malgaches.

## Limites à ne pas oublier

- **Multi-étiquette non vérifié.** Toutes les photos publiques portent une
  seule étiquette : l'étage B n'a jamais vu une feuille avec deux problèmes, et
  sa capacité à en signaler deux n'est pas mesurée.
- **Seuils choisis sur la validation qui sert aussi à les mesurer.** Les F1 de
  l'étage B sont donc un peu optimistes. `--kfold` existe dans
  `train_feuille.py`, pas encore dans `train_feuille_multilabel.py`.
- **Deux backbones identiques.** Chaque `.tflite` (2,9 Mo) embarque son propre
  MobileNetV2 gelé : déployée telle quelle, la chaîne ferait deux passes
  complètes par photo sur le téléphone. Les deux têtes partagent les mêmes
  features, un seul modèle à deux sorties suffirait (à faire en P4.5).
- **145 groupes de quasi-doublons à cheval sur plusieurs classes** restent non
  résolus (voir le rapport d'entraînement) : ils pèsent sur tous les modèles
  entraînés sur ces données.

## Prochaines étapes proposées

1. **Seuils de l'étage B réglés conjointement**, sous contrainte « au moins
   X % des feuilles saines reconnues saines » plutôt que meilleur F1 classe par
   classe, avec une validation croisée pour ne pas les choisir sur les données
   qui les mesurent. C'est le levier le plus direct sur le principal défaut de
   la chaîne.
2. **Porte plus robuste** : les 420 négatifs viennent d'une seule source et de
   14 catégories. Il faut plus de diversité (autres sources, autres cadrages)
   pour passer de 82 % à 95 % sur des photos indépendantes.
3. **Un seul modèle à deux sorties** (porte + feuille) partageant le backbone,
   avant toute intégration (P4.5).
