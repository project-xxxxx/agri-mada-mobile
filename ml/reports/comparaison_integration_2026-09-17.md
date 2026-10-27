# Intégration de feuille_v2 dans l'app : ce que voit l'agriculteur (2026-09-17)

Mesure préalable au remplacement du modèle embarqué (P4.5, ADR-014). Script :
`ml/scripts/comparer_integration.py`, résultats bruts dans
`ml/reports/comparaison_integration_2026-09-17.json`.

## Méthode

Le script reproduit le parcours de scan de l'app pour **une photo de feuille,
sans réponse au questionnaire** : prétraitement de `tflite_service.dart`
(224 × 224, plus proche voisin, pixels [0, 1]), top 3 du modèle, fusion de
`diagnosis_fusion.dart`, seuils de `diagnosis_certainty.dart`. Pour chaque
photo, il note ce qui s'affiche : aucune maladie, « plante saine », ou le nom
d'une maladie.

Photos : les 2 987 images de validation de `train_feuille.py` (jamais vues
par `feuille_v2`, et indépendantes aussi pour l'ancien modèle, entraîné sur un
autre jeu) et les 50 photos hors sujet de P1.2.

Trois configurations :
- **A** : ancien modèle (3 classes), parcours tel qu'il était avant ADR-014 ;
- **B** : ancien modèle, garde-fous d'ADR-006 rétablis (rien de nommé si
  « incertain » ou si moins de 10 % de pixels végétaux) ;
- **C** : `feuille_v2`, mêmes garde-fous, et rien de nommé si la première
  classe est `pas_riz`.

## Résultats

| Ce que voit l'agriculteur | A | B | C |
|---|---:|---:|---:|
| Photo hors sujet avec une maladie nommée (50) | 50 (100 %) | 21 (42 %) | **1 (2 %)** |
| Feuille saine avec une fausse alerte (670) | 670 (100 %) | 420 (63 %) | **42 (6 %)** |
| BLB ou tache brune : bon nom (806) | 41 % | 31 % | **67 %** |
| BLB ou tache brune : mauvais nom (806) | 59 % | 39 % | **7 %** |
| Toutes maladies : bon nom (2 233) | 15 % | 11 % | **67 %** |
| Toutes maladies : mauvais nom (2 233) | 85 % | 55 % | **7 %** |

Détail de C par maladie (bon nom / aucune maladie ou « saine » / mauvais nom) :

| Maladie | Photos | Bon nom | Rien ou saine | Mauvais nom |
|---|---:|---:|---:|---:|
| carence_azote | 87 | 84 | 3 | 0 |
| bls | 57 | 54 | 1 | 2 |
| carence_potassium | 76 | 69 | 5 | 2 |
| carence_phosphore | 66 | 60 | 3 | 3 |
| mildiou | 97 | 77 | 17 | 3 |
| blb | 289 | 219 | 52 | 18 |
| degats_hispa | 297 | 206 | 72 | 19 |
| helminthosporiose | 517 | 321 | 157 | 39 |
| pyriculariose_feuille | 648 | 364 | 222 | 62 |
| echaudure | 76 | 26 | 41 | 9 |
| cercosporiose | 23 | 6 | 8 | 9 |

## Ce que ces chiffres disent

- **L'app d'avant ADR-014 nommait une maladie sur toute photo passée par le
  modèle (colonne A).** Lors de la refonte en sessions (P2), deux garde-fous
  d'ADR-006 ont été perdus en route : la certitude calculée par le service
  (qui applique le contrôle de végétation) n'était plus transmise à la fusion,
  et l'écran de résultat affichait le nom même quand la certitude était
  « incertain ». Aucun test ne le couvrait.
- Rétablir ces garde-fous améliore déjà l'ancien modèle (B), mais il reste
  très mauvais : il ne connaît que 3 classes et aucune feuille saine.
- `feuille_v2` fait mieux sur toutes les lignes (C). Le rejet est surtout dû
  à la combinaison classe `pas_riz` + fusion + seuil « possible » : en argmax
  brut, 8 photos hors sujet sur 50 recevaient un nom de maladie, contre 1 ici.
- Le prix des garde-fous : 26 % des vraies maladies n'affichent rien ou
  « saine » (pyriculariose 34 %, helminthosporiose 30 %). L'app renvoie alors
  vers le technicien, ce qui est le comportement voulu par ADR-006.

## Limites

- Photos publiques (Inde, Bangladesh) : **rien n'est mesuré sur des photos
  malgaches, le critère P4.6 n'est pas rempli.** Les résultats restent donc
  présentés comme des pistes à confirmer (`probableMinScore` inchangé à 0,999).
- La validation vient de la même distribution que l'entraînement de
  `feuille_v2` : ses chiffres sont optimistes par rapport au terrain.
- Une photo seule, sans questionnaire : les réponses peuvent faire basculer
  un résultat dans un sens comme dans l'autre.
- `cercosporiose` et `echaudure` restent peu fiables (peu de données).
