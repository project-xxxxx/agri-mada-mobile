# Planning MVP sur 8 semaines

## Hypothese de planning
Equipe multidisciplinaire (mobile, IA, data, UX, test) avec cycles hebdomadaires et validation continue.

## Semaine 1 - Cadrage et architecture
- Finaliser perimetre MVP et maladies cibles v1.
- Definir criteres de gravite et format des recommandations.
- Valider architecture Flutter (feature-first, clean architecture).
- Sortie attendue:
  - backlog priorise,
  - schema technique,
  - maquettes basses fidelites.

## Semaine 2 - Base applicative Flutter
- Initialiser navigation, theming, i18n (Malagasy/Francais).
- Construire ecrans de base (accueil, capture photo, resultat, journal).
- Mettre en place stockage local du journal.
- Sortie attendue:
  - prototype navigable,
  - persistance locale fonctionnelle.

## Semaine 3 - Pipeline IA embarquee (v0)
- Integrer modele IA on-device (inference locale).
- Implementer pre-traitement image et post-traitement resultat.
- Ajouter score de confiance + mapping gravite.
- Sortie attendue:
  - premier diagnostic local de bout en bout.

## Semaine 4 - Recommandations et robustesse UX
- Implementer moteur de recommandations (par maladie et gravite).
- Ajouter gestion des echecs (photo floue, hors cadre, faible confiance).
- Ajouter assistant de prise de photo.
- Sortie attendue:
  - experience utilisateur stable sur cas reels.

## Semaine 5 - Journal agricole et qualite produit
- Completer journal par parcelle + filtres simples.
- Ajouter export local (CSV ou rapport texte).
- Renforcer tests unitaires/providers/widgets prioritaires.
- Sortie attendue:
  - suivi historique exploitable,
  - qualite logicielle consolidee.

## Semaine 6 - Optimisation device bas de gamme
- Profilage performance (temps inference, memoire, batterie).
- Optimisation du modele et de la chaine image.
- Reduction taille app et temps demarrage.
- Sortie attendue:
  - build optimisee pour smartphone cible.

## Semaine 7 - Recette terrain pilote
- Tests utilisateurs sur scenarios reels.
- Collecte des retours (comprehension conseils, fluidite usage).
- Corrections prioritaires UI/UX et messages metier.
- Sortie attendue:
  - version candidate quasi finale (RC).

## Semaine 8 - Stabilisation et livrable
- Regression finale + correction des anomalies bloquantes.
- Preparation APK de demonstration.
- Finalisation documentation technique et guide utilisateur.
- Sortie attendue:
  - MVP pret pour soutenance/demo.

## Definition of Done (DoD) hebdomadaire
- Fonctions prevues de la semaine implementees.
- Tests minimaux executes et valides.
- Aucun bug critique ouvert sur le scope de la semaine.
- Demonstration interne realisable sur appareil Android.

## Jalons de decision
- Fin S2: go/no-go UX de base.
- Fin S4: go/no-go qualite du diagnostic sur cas tests.
- Fin S6: go/no-go performance appareil cible.
- Fin S8: validation finale de livraison MVP.

## Backlog post-MVP (optionnel)
- Synchronisation cloud optionnelle.
- Tableau de bord statistique.
- Extension a d'autres cultures.
- Mise a jour distante des modeles IA.
