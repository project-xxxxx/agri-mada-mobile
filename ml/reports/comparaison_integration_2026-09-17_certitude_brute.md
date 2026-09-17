# Certitude lue sur les scores bruts de la photo (2026-09-17, ADR-015)

Mesure demandée avant de livrer la correction d'ADR-015. Script :
`ml/scripts/comparer_integration.py --rapport ml/reports/comparaison_integration_2026-09-17_certitude_brute.json`
(résultats bruts dans ce JSON).

## Pourquoi cette mesure

Une photo de feuille envoyée par l'équipe donnait « L'application ne reconnaît
pas cette photo », alors que le modèle ne la rejetait pas : tache brune 0,606,
BLB 0,361, cercosporiose 0,016. La fusion de `diagnosis_fusion.dart` (poids
0,5, probabilités bornées à [0,05 ; 0,95], renormalisation sur le top 3)
ramenait 0,606 à 0,486, sous le seuil « possible » de 0,5. Ce seuil a été
calibré sur les scores bruts du modèle (ADR-006), pas sur les scores fusionnés.

Correction : la certitude est lue sur les scores bruts des photos acceptées ;
la fusion ne sert plus qu'à classer les fiches et à intégrer le questionnaire.
Or les chiffres d'ADR-014 (1 photo hors sujet sur 50, 6 % de fausses alertes)
avaient été mesurés avec l'ancienne règle : il fallait les refaire.

## Méthode

Identique au rapport `comparaison_integration_2026-09-17.md` : une photo de
feuille, sans questionnaire, prétraitement et seuils de l'app, 2 987 photos de
validation de `train_feuille.py` et 50 photos hors sujet de P1.2.

- **C** : `feuille_v2`, règle d'ADR-014 (certitude lue sur les scores fusionnés).
  Retrouve exactement les chiffres d'ADR-014, ce qui confirme que la mesure est
  reproductible.
- **D** : `feuille_v2`, règle d'ADR-015 (mêmes rejets `pas_riz` et végétation,
  certitude lue sur les scores bruts, seuil « possible » 0,5 inchangé).

## Résultats

| Ce que voit l'agriculteur | C (ADR-014) | D (ADR-015) |
|---|---:|---:|
| Photo hors sujet avec une maladie nommée (50) | 1 (2 %) | 2 (4 %) |
| Feuille saine avec une fausse alerte (670) | 42 (6,3 %) | 59 (8,8 %) |
| Feuille saine affichée « saine » (670) | 472 (70,4 %) | 495 (73,9 %) |
| BLB ou tache brune : bon nom (806) | 540 (67,0 %) | 568 (70,5 %) |
| BLB ou tache brune : mauvais nom (806) | 57 (7,1 %) | 80 (9,9 %) |
| Toutes maladies : bon nom (2 233) | 1 486 (66,5 %) | 1 579 (70,7 %) |
| Toutes maladies : rien ou « saine » (2 233) | 581 (26,0 %) | 441 (19,7 %) |
| Toutes maladies : mauvais nom (2 233) | 166 (7,4 %) | 213 (9,5 %) |

Par maladie (bon nom / rien ou « saine » / mauvais nom, de C vers D) :

| Maladie | Photos | Bon nom | Rien ou saine | Mauvais nom |
|---|---:|---:|---:|---:|
| cercosporiose | 23 | 6 → 6 | 8 → 7 | 9 → 10 |
| bls | 57 | 54 → 54 | 1 → 1 | 2 → 2 |
| carence_phosphore | 66 | 60 → 62 | 3 → 0 | 3 → 4 |
| carence_potassium | 76 | 69 → 71 | 5 → 3 | 2 → 2 |
| echaudure | 76 | 26 → 30 | 41 → 35 | 9 → 11 |
| carence_azote | 87 | 84 → 86 | 3 → 0 | 0 → 1 |
| mildiou | 97 | 77 → 80 | 17 → 13 | 3 → 4 |
| blb | 289 | 219 → 227 | 52 → 39 | 18 → 23 |
| degats_hispa | 297 | 206 → 222 | 72 → 52 | 19 → 23 |
| helminthosporiose | 517 | 321 → 341 | 157 → 119 | 39 → 57 |
| pyriculariose_feuille | 648 | 364 → 400 | 222 → 172 | 62 → 76 |

## Ce que ces chiffres disent

- **La correction fait ce qu'elle doit** : 140 photos de maladie de moins
  restent sans réponse (26 % → 20 %), dont la photo de terrain qui a déclenché
  l'enquête.
- **Elle a un coût** : sur ces 140 photos désormais nommées, 93 ont le bon nom
  et 47 un mauvais (un tiers d'erreurs, contre environ une sur dix pour les
  photos déjà nommées avant). S'y ajoutent 17 fausses alertes de plus sur les
  feuilles saines (6,3 % → 8,8 %) et une photo hors sujet de plus (1 → 2 sur 50).
- **Toutes ces pistes restent « possibles »** : jamais « probable », bandeau
  « modèle expérimental », technicien proposé. Aucune n'est présentée comme un
  diagnostic.
- **Rien n'est mesuré sur des photos malgaches** (P4.6) : ces chiffres portent
  sur les jeux publics de validation.
- Si l'équipe juge le coût trop élevé, le levier est le seuil brut « possible »
  (`CertaintyThresholds.possibleMinScore`), à balayer sur ces mêmes photos,
  plutôt qu'un retour à la règle sur scores fusionnés, dont l'échelle ne
  correspond à aucun seuil calibré.
