# Évaluation du modèle embarqué sur photos de terrain — 16 septembre 2026

Tâche P1.2. Modèle évalué : `assets/model/agrimada_model.tflite` (v1.0.0, 3 classes : flétrissement bactérien, tache brune, charbon foliaire).
Script : `ml/scripts/eval_off_topic.py`, qui reproduit le prétraitement et les seuils de l'app. Détail image par image : `eval_hors_sujet_2026-09-16.json`.

## Jeux utilisés

- **Hors sujet :** 50 photos Wikimedia Commons sous licence libre, 5 par catégorie : sol, mains, maïs, herbes, canne à sucre, eau, outils, zébus, écrans, autres feuilles. Liste, auteurs et licences : `ml/data/eval/hors_sujet.csv`.
- **Riz de terrain :** 600 feuilles, 100 par classe dans Paddy Doctor et dans Mendeley hx6f852hw4 (flétrissement bactérien, tache brune, feuilles saines).
- Aucun jeu public ne contient de charbon foliaire, et aucune photo n'a été prise à Madagascar.

## Avec les anciens seuils (« probable » à partir de 0,70 et d'un écart de 0,20)

| Jeu | Affiché « probable » | Dont maladie juste |
|---|---:|---:|
| Hors sujet (50) | 21 | — |
| Flétrissement bactérien (200) | 159 | 159 |
| Tache brune (200) | 137 | **0** |
| Feuilles saines (200) | 105 présentées comme malades | — |

Le modèle attribue une maladie au sol, à l'eau, aux outils et aux zébus. Il ne reconnaît jamais la tache brune, et il n'a pas de classe « sain ».

## Seuil « probable » : balayage (écart minimal de 0,20)

| Seuil | Hors sujet « probable » | Riz « probable » avec la mauvaise maladie | Maladies « probables » justes |
|---:|---:|---:|---:|
| 0,70 | 16* | 242 | 39,8 % |
| 0,90 | 5* | 83 | 13,8 % |
| 0,99 | 1* | 3 | 0 % |
| 0,995 | 0* | 1 | 0 % |
| **0,997 et plus** | **0** | **0** | 0 % |

\* avec le contrôle de végétation décrit plus bas.

Aucun seuil ne sépare les bonnes réponses des mauvaises : dès qu'il n'y a plus de « probable » faux, il n'y a plus non plus de « probable » juste.

## Contrôle de végétation

Part des pixels de teinte végétale (25° à 160°, saturation ≥ 0,18, luminosité ≥ 0,15) sur l'image d'entrée du modèle (minimum / médiane) :

- feuilles de riz : 0,15 / 0,95 (la tache brune descend jusqu'à 0,15) ;
- écrans 0,00 / 0,00, sol 0,00 / 0,12, mains 0,01 / 0,17, zébus 0,07 / 0,19 ;
- eau 0,05 / 0,39, outils 0,25 / 0,45, autres feuilles, canne, maïs, herbes : 0,19 à 0,73.

Un seuil de 0,10 écarte une partie du sol, des mains, des zébus et tous les écrans, sans toucher aux feuilles de riz de l'échantillon. Il ne peut rien contre le maïs, l'herbe ou les objets photographiés sur fond vert.

## Décision (choix de l'équipe, 16 septembre 2026)

Jusqu'aux modèles v2 (P4), les résultats du modèle sont présentés comme des **pistes à confirmer** :

- « probable » à partir de 0,999 seulement, donc jamais atteint avec ce modèle ;
- contrôle de végétation à 0,10 : en dessous, le résultat est « incertain » ;
- un résultat « possible » s'affiche « Piste à confirmer » avec la mention « modèle expérimental », et « Demander à un technicien » passe en bouton principal ;
- dans le journal, une parcelle dont le dernier résultat n'est qu'une piste est « À confirmer », pas « Malade ».

## Configuration finale de l'app

| Jeu | Probable | Piste à confirmer | Incertain |
|---|---:|---:|---:|
| Hors sujet (50) | **0** | 30 | 20 |
| Flétrissement bactérien (200) | 0 | 193 | 7 |
| Tache brune (200) | 0 | 185 | 15 |
| Feuilles saines (200) | 0 | 179 | 21 |

Critère de P1.2 tenu : aucune photo hors sujet n'est affichée comme « probable ».

## Limites

- Échantillon de 650 photos, sans photo malgache : les seuils sont à recalibrer sur le jeu de test malgache (P4.4).
- Le contrôle de végétation est une protection grossière ; la vraie porte d'entrée « riz exploitable / pas du riz » arrive en P4.2.
- Les pistes restent erronées dans la majorité des cas : seul un nouveau modèle, entraîné sur des photos de terrain, corrige le fond du problème.
