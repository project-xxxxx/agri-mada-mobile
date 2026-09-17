# Verification des fonctionnalites MVP et ecarts

Ce document verifie les exigences de [docs/Cahier_des_charges_MVP.md](docs/Cahier_des_charges_MVP.md) par rapport au code actuel.

## Legende
- Present fonctionnel: fonctionnalite implementee avec comportement metier.
- Present UI: ecran et parcours visibles, donnees encore mockees ou hardcodees.
- Partiel: present mais incomplet.
- Absent: non implemente.

## Matrice de couverture

| Exigence MVP | Statut | Preuves dans le code | Commentaire |
|---|---|---|---|
| Prise de photo depuis appareil | Present UI | [lib/features/scan/presentation/screens/scanning_screen.dart](lib/features/scan/presentation/screens/scanning_screen.dart) | Capture simulee via interface, pas encore branchee au plugin camera/image_picker dans le parcours scan. |
| Analyse locale IA embarquee | Partiel | [README.md](README.md), [lib/features/scan/presentation/screens/scan_result_screen.dart](lib/features/scan/presentation/screens/scan_result_screen.dart) | Le resultat est actuellement statique dans l'ecran. |
| Detection de maladies prioritaires | Present UI | [lib/features/scan/presentation/screens/scan_result_screen.dart](lib/features/scan/presentation/screens/scan_result_screen.dart) | Maladie affichee en dur. |
| Affichage score de confiance | Partiel | [lib/features/scan/presentation/screens/scan_result_screen.dart](lib/features/scan/presentation/screens/scan_result_screen.dart) | Mention Diagnostic IA fiable presente, score numerique non expose. |
| Affichage niveau de gravite | Present UI | [lib/features/scan/presentation/screens/scan_result_screen.dart](lib/features/scan/presentation/screens/scan_result_screen.dart) | Barre et label de gravite visibles. |
| Recommandations contextualisees | Present UI | [lib/features/scan/presentation/screens/scan_result_screen.dart](lib/features/scan/presentation/screens/scan_result_screen.dart) | Cartes de recommandations presentes avec contenus statiques. |
| Journal local par parcelle | Present UI | [lib/features/journal/presentation/screens/journal_screen.dart](lib/features/journal/presentation/screens/journal_screen.dart) | Liste mockee, pas de persistance reliee au bouton Enregistrer. |
| Interface bilingue Malagasy/Francais | Partiel | [pubspec.yaml](pubspec.yaml), [lib/features](lib/features) | Texte majoritairement en Francais. Basculer Malagasy reste a implementer. |
| Fonctionnement hors ligne | Present UI | [lib/features/home/presentation/screens/home_screen.dart](lib/features/home/presentation/screens/home_screen.dart), [lib/features/scan/presentation/screens/scanning_screen.dart](lib/features/scan/presentation/screens/scanning_screen.dart) | Labels hors ligne presentes. Validation reseau/systeme offline non encore automatisee. |

## Tests e2e ajoutes

Objectif: robustesse du parcours critique MVP.

- Fichier cree: [integration_test/mvp_flow_test.dart](integration_test/mvp_flow_test.dart)
- Scenarios couverts:
  - offline principal: home -> scan -> resultat -> enregistrer -> journal
  - re-scan depuis resultat vers scan
  - navigation home -> journal via barre basse

## Robustesse technique ajoutee

Pour fiabiliser les selectors e2e, des cles de test stables ont ete introduites:
- [lib/core/constants/test_keys.dart](lib/core/constants/test_keys.dart)
- Ecrans instrumentes:
  - [lib/features/auth/presentation/screens/welcome_screen.dart](lib/features/auth/presentation/screens/welcome_screen.dart)
  - [lib/features/home/presentation/screens/home_screen.dart](lib/features/home/presentation/screens/home_screen.dart)
  - [lib/features/scan/presentation/screens/scanning_screen.dart](lib/features/scan/presentation/screens/scanning_screen.dart)
  - [lib/features/scan/presentation/screens/scan_result_screen.dart](lib/features/scan/presentation/screens/scan_result_screen.dart)
  - [lib/features/journal/presentation/screens/journal_screen.dart](lib/features/journal/presentation/screens/journal_screen.dart)

## Ecarts prioritaires a traiter

### Haute priorite
1. Brancher la capture photo reelle au flux scan.
2. Brancher inference IA locale et retourner un resultat dynamique.
3. Connecter Enregistrer au stockage local du journal.

### Priorite moyenne
1. Exposer un score de confiance numerique.
2. Implementer la bascule Malagasy/Francais complete.
3. Ajouter gestion explicite des cas photo non exploitable.

### Priorite basse
1. Export du journal (CSV/PDF) et options avancees de suivi.
