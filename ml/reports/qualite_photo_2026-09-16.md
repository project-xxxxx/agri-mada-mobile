# Calibration du contrôle de qualité des photos — 16 septembre 2026

Tâche P2.2. Script : `ml/scripts/calibrate_image_quality.py`. Mesures détaillées :
`qualite_photo_2026-09-16.json`.

## Méthode

120 photos de riz prises au champ (Paddy Doctor : tache brune et plants sains ;
Mendeley hx6f852hw4 : flétrissement bactérien), puis les mêmes photos dégradées
comme elles le seraient sur un téléphone :

- **floue légère** : flou gaussien de rayon 2 (bougé de la main) ;
- **floue forte** : rayon 5 ;
- **sombre** : luminosité × 0,25 (fin de journée, ombre) ;
- **brûlée** : luminosité × 2,4 (plein soleil) ;
- **contre-jour** : sujet assombri et bande de ciel blanc sur 15 % de l'image.

Le calcul est celui de l'app (`lib/core/ai/image_quality.dart`) : réduction au
plus grand côté de 512 pixels, luminance 0,299 R + 0,587 V + 0,114 B, variance
du laplacien à quatre voisins.

## Mesures (médianes, et 5 % / 95 % pour les seuils)

| Groupe | Netteté (p05 · médiane · p95) | Luminosité (min · médiane · max) | Pixels brûlés (p95) |
|---|---|---|---|
| Photos correctes | 636 · 2591 · 6437 | 0,36 · 0,51 · 0,64 | 0,026 |
| Floue légère | 29 · 76 · 151 | inchangée | 0,016 |
| Floue forte | 3 · 9 · 18 | inchangée | 0,010 |
| Sombre | 40 · 162 · 402 | 0,09 · 0,13 · 0,16 | 0,000 |
| Brûlée | 721 · 2831 · 8700 | 0,70 · 0,85 · 0,95 | 0,560 |
| Contre-jour | 257 · 476 · 940 | 0,25 · 0,30 · 0,34 | 0,151 |

## Seuils retenus

| Seuil | Valeur | Raison |
|---|---:|---|
| `netteteMin` | 350 | Entre le plafond du flou léger (151) et le plancher des photos correctes (636). |
| `luminositeMin` | 0,25 | Entre le maximum des photos sombres (0,16) et le minimum des correctes (0,36). |
| `luminositeMax` | 0,67 | Entre le maximum des correctes (0,64) et le minimum des brûlées (0,70). |
| `partBruleeMax` | 0,12 | Une photo correcte ne dépasse pas 2,6 % de pixels brûlés. |
| `contreJourPartBrulee` | 0,08 | Les contre-jours en montrent 15 % en médiane. |
| `contreJourLuminosite` | 0,36 | Les contre-jours plafonnent à 0,34. |

## Un enseignement qui change l'ordre des contrôles

Une photo sombre a mécaniquement peu de contraste : sa netteté tombe à 162 en
médiane, contre 2591 pour la même photo correctement exposée. Si la netteté
était jugée en premier, l'app dirait « photo floue » à quelqu'un à qui il manque
seulement de la lumière. L'exposition est donc jugée avant la netteté, et la
consigne affichée parle de lumière.

## Limites

- Les dégradations sont simulées : un vrai bougé d'appareil n'est pas exactement
  un flou gaussien, et un vrai contre-jour dépend de l'optique du téléphone.
- Aucune photo malgache dans l'échantillon : à revérifier pendant le pilote (P6),
  avec le téléphone de référence (`docs/qualite/telephone-reference.md`).
- Les seuils sont volontairement larges : mieux vaut accepter une photo moyenne
  que refuser la photo d'un agriculteur qui n'a que ce téléphone-là.
