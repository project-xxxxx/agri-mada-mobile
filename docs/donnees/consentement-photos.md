# Consentement pour les photos de parcelles

Tâche P0.4 du plan de correction. Texte utilisé par les collecteurs (techniciens, étudiants ISPM) avant de photographier les plants d'un agriculteur. Il est lu à voix haute ; l'agriculteur peut aussi le lire lui-même.

> **Statut : PROJET, version 0.1 — non utilisé pour l'instant**
> - La version malgache est à relire et valider par un locuteur natif du milieu agricole avant tout usage.
> - Le cadre juridique est à vérifier par l'ISPM : loi malgache sur la protection des données personnelles (loi n° 2014-038) et, le cas échéant, déclaration auprès de l'autorité compétente.
> - Les champs entre crochets sont à compléter.
> - ADR-008 (2026-09-16) : le mode de collecte de l'app qui devait utiliser ce
>   texte (tâche P3.3) n'est pas construit — l'équipe s'appuie sur les jeux
>   publics déjà rassemblés. Ce document reste la référence si une collecte
>   terrain est décidée plus tard.

## Règles pour le collecteur

- Toujours lire le texte **avant** la première photo, dans la langue choisie par l'agriculteur.
- Ne photographier **ni visage, ni personne**, ni document portant un nom.
- Enregistrer la réponse dans l'app (voir « Données enregistrées »). Un refus est une réponse normale : aucune photo n'est prise et rien d'autre ne change.
- Laisser à l'agriculteur un moyen de joindre le projet pour retirer ses photos.

## Texte à lire — français

Bonjour. Je m'appelle [prénom], je travaille avec l'ISPM pour le projet AgriMada[, en partenariat avec FOFIFA].

Nous prenons des photos de plants de riz, malades ou sains, pour apprendre à une application de téléphone à reconnaître les maladies du riz.

- Nous photographions seulement les plants, jamais les personnes.
- Nous notons la commune et, si vous êtes d'accord, l'emplacement exact de la parcelle.
- Votre nom et votre numéro de téléphone ne sont jamais publiés.
- Vous pouvez refuser. Vous pouvez aussi demander plus tard que vos photos soient retirées, en appelant le [numéro du projet]. Cela n'a aucune conséquence pour vous.

Êtes-vous d'accord ?

- [ ] **J'accepte** que les photos de mes plants servent à entraîner et à tester l'application.
- [ ] **J'accepte** que l'emplacement exact (GPS) de ma parcelle soit enregistré. *Sinon, seule la commune est notée.*
- [ ] **J'accepte** que ces photos, sans mon nom, apparaissent dans des publications scientifiques ou des jeux de données partagés.

## Texte à lire — malgache (PROJET, à valider)

Manao ahoana. Izaho dia [anarana], miara-miasa amin'ny ISPM ho an'ny tetikasa AgriMada[, miaraka amin'ny FOFIFA].

Maka sary ny zana-bary izahay, na marary na salama, mba hampianarana rindranasa amin'ny finday hamantatra ny aretin'ny vary.

- Ny zana-bary ihany no alainay sary, tsy mba maka sarin'olona mihitsy izahay.
- Soratanay ny kaominina ary, raha manaiky ianao, ny toerana marina misy ny tanimbary.
- Tsy havoaka mihitsy ny anaranao sy ny laharan'ny findainao.
- Afaka mandà ianao. Afaka mangataka any aoriana ihany koa ianao mba hanesorana ireo sary, amin'ny fiantsoana ny [laharana]. Tsy misy fiantraikany aminao izany.

Manaiky ve ianao ?

- [ ] **Manaiky aho** ny hampiasana ny sarin'ny zana-bariko hampianarana sy hanandramana ny rindranasa.
- [ ] **Manaiky aho** ny handraisana ny toerana marina (GPS) misy ny tanimbariko. *Raha tsy izany, ny kaominina ihany no soratana.*
- [ ] **Manaiky aho** ny hisehoan'ireo sary ireo, tsy misy ny anarako, amin'ny famoahana ara-tsiansa na angon-drakitra zaraina.

## Données enregistrées avec chaque session de collecte

Ces champs seront implémentés dans le mode collecte (P3.3).

| Champ | Contenu |
|---|---|
| `consentement_id` | identifiant unique |
| `version_texte` | version du présent document, ex. `0.1` |
| `langue` | `fr` ou `mg` |
| `date` | date et heure |
| `collecteur_id` | identifiant du collecteur, pas son nom |
| `accepte_photos` | oui / non |
| `accepte_gps_precis` | oui / non |
| `accepte_publication` | oui / non |
| `mode` | lu à voix haute / lu par l'agriculteur |
| `commune` | commune de la parcelle |

Le nom et le téléphone de l'agriculteur ne sont **pas** stockés avec les photos. Si un contact est nécessaire pour un retrait, il est conservé à part, avec un accès restreint.

## Historique

| Version | Date | Changement |
|---|---|---|
| 0.1 | 2026-09-14 | Premier projet, à valider (traduction et cadre juridique) |
