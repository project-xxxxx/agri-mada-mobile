# Cours de pathologie du riz — notes de lecture

Deux cours transmis le 16 septembre 2026 par l'école partenaire (voir
[sources.md](sources.md)) :

- **EPSA** — *Reconnaissance et gestion intégrée des principales maladies du riz*
  (`cours_epsa_pathologie_riz`), cadre général et Afrique de l'Ouest ;
- **Rafalimanana** — *Importance des maladies de riz et proposition de lutte*
  (`cours_rafalimanana_maladies_riz`), contexte malgache, avec un cas à
  Vakinankaratra.

Ces notes servent à deux choses : alimenter le RAG des fiches (P5.1) et arbitrer
la taxonomie `ml/taxonomy_v1.yaml`. Les numéros de page renvoient aux PDF.

## Ce qui n'est pas repris

Les deux cours détaillent la lutte chimique : fongicides, matières actives, doses
de traitement des semences et volumes d'application (EPSA, p. 70-77). **Rien de
cela n'entre dans l'app ni dans les réponses aux agriculteurs** (ADR-001, tâche
P1.1) : seul un technicien prescrit un produit. Ces pages restent consultables
dans le PDF d'origine.

## Noms malgaches relevés

| Maladie | Français | Malgache (cours) | État dans la taxonomie |
|---|---|---|---|
| Pyriculariose | Pyriculariose, blast | **menalavitra** (Rafalimanana, p. 4) | déjà `Menalavitra`, confirmé |
| Panachure jaune (RYMV) | Panachure jaune | **mativondrana**, **fondrabe** (Rafalimanana, p. 11) | `Mavoratsy` retenu ; les deux autres ajoutés comme noms locaux, à arbitrer |
| Helminthosporiose | Taches brunes | — (le cours garde le terme français) | cohérent avec les fiches FOFIFA |

Aucun des deux cours ne nomme le charbon foliaire, ni en français courant ni en
malgache : la classe reste sans nom malgache validé.

## Faits propres à Madagascar

- **Pyriculariose** (Rafalimanana, p. 8-9) : dégâts surtout sur les Hautes Terres,
  pertes de récolte de 20 à 60 %, jusqu'à 100 % en attaque précoce. Carte de
  répartition p. 9. Stades sensibles : jeunes plants, puis montaison à épiaison.
- **Facteurs favorables à la pyriculariose** (p. 7) : humidité relative > 90 %,
  nuits entre 20 et 25 °C, sols tourbeux, champs nouvellement défrichés, excès
  d'azote. Réservoirs : semences infectées, résidus de récolte, adventices.
- **RYMV** (p. 11-13) : régions côtières, pertes de 0 à 80 %, symptômes 7 à 10
  jours après infection ou 2 à 3 semaines après repiquage. Transmis par *Hispa
  gestroi*, *Trichispa sericea* et *Chaetocnema pulla*, mécaniquement, par le sol
  et par les déjections d'animaux ayant mangé des plants virosés.
- **Pourriture des gaines** (*Sarocladium oryzae*, p. 17-18) : observée dans toute
  l'île, pertes jusqu'à 26 %, mauvaise sortie des panicules.
- **Bactériose des gaines** (*Pseudomonas fuscovaginae*, p. 19-20) : dégâts
  importants **au-dessus de 1600 m**, zones de moyenne et haute altitude, stérilité
  variable selon les variétés, symptômes visibles à la formation de la panicule.
  Classe absente de la taxonomie jusqu'ici, ajoutée le 16 septembre 2026.
- **Cas de Vakinankaratra** (p. 25) : 40 % des surfaces touchées dont 10 %
  sévèrement, 300 tonnes perdues, sur variétés sensibles en riziculture pluviale
  avec fumure minérale.

## Seuils d'intervention

L'EPSA (p. 58-59) rattache la décision de traiter à des seuils de nuisibilité,
relevés lors de passages hebdomadaires dans la parcelle :

- pyriculariose foliaire : note 4 de l'échelle de sévérité ;
- pyriculariose paniculaire : 5 % de panicules atteintes.

À rapprocher de la gravité déclarée par l'agriculteur dans l'app (P1.3), qui
mesure la part de parcelle touchée et non la sévérité par feuille : les deux
échelles ne se confondent pas.

## Gestes de prévention utilisables dans l'app

Tous sans produit, donc diffusables tels quels une fois traduits et relus :

- semences certifiées et désinfectées, pépinière bien préparée, plants vigoureux
  (EPSA, p. 63) ;
- repiquage aux dates et stades recommandés, fertilisation recommandée sans excès
  d'azote, désherbage régulier (EPSA p. 63 ; Rafalimanana p. 10) ;
- variétés résistantes recommandées par les services techniques, sans introduction
  anarchique de variétés (EPSA, p. 62-65) ;
- gestion des résidus de récolte : brûler pailles et chaumes (Rafalimanana, p. 10) ;
- retrait des plantes hôtes : *Digitaria marginata*, *Dinebra retroflexa*,
  *Panicum repens* (Rafalimanana, p. 10) ;
- contre le RYMV : semis et repiquage synchronisés, destruction des souches et des
  plantes hôtes des vecteurs, brûlage de la parcelle atteinte ; **aucune lutte
  curative n'existe** (Rafalimanana, p. 15) ;
- grains : ne pas stocker au-dessus de 14 % d'humidité, drainer les parcelles à
  maturité (EPSA, p. 37).

## Autres apports

- **Décoloration des grains** (EPSA, p. 37) : complexe de champignons (*Alternaria*,
  *Curvularia*, *Fusarium*, *Nigrospora*, *Sarocladium*), favorisée par les pluies
  à maturité et les parcelles non drainées.
- **Toxicité ferreuse** (EPSA, p. 51) : pigmentation orange rouille commençant à la
  pointe des feuilles, dans les bas-fonds et les parties mal drainées des périmètres
  irrigués. Cohérent avec les classes `toxicite_fer_feuille` et `racines_ferreuses`.
- **Carences** (EPSA, p. 48-50) : descriptions symptomatiques de N, P, K, Ca et Mg,
  utiles pour rédiger les fiches des classes `carence_*`.
- **Nématodes** (EPSA, p. 45) : *Hirschmanniella* est cité comme endoparasite des
  racines du riz, en plus de *Meloidogyne* déjà suivi.
- **Maladies mineures citées dans le contexte malgache** (Rafalimanana, p. 23) :
  faux charbon, stries bactériennes, rhynchosporiose, *Corticium sasakii*,
  bactériose des feuilles, *Rhizoctonia solani*, gigantisme (*Fusarium moniliforme*).

## À trancher avec l'agronome

1. Nom malgache du RYMV : *mavoratsy* (retenu), *mativondrana* ou *fondrabe* —
   probablement des usages régionaux.
2. Présence à Madagascar des maladies mineures listées p. 23 : le cours les cite
   sans les localiser ; elles restent `a_confirmer` dans la taxonomie.
3. Priorité de la bactériose des gaines d'altitude par rapport à la stérilité due
   au froid : les deux touchent les Hautes Terres et se confondent à l'œil.
