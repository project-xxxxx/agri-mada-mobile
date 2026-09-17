# Téléphone de référence et protocole de mesure

Tâche P0.5 du plan de correction. AgriMada doit tenir sur les téléphones que les riziculteurs et les techniciens possèdent réellement. Chaque version candidate est donc mesurée sur un même téléphone d'entrée de gamme, avec le même protocole.

> **Statut : PROJET.** Les seuils sont des cibles initiales, à ajuster après le premier relevé et avec l'équipe.

## 1. Choisir le téléphone

On ne choisit pas le modèle depuis un bureau : on relève d'abord les téléphones présents sur le terrain.

**Relevé (semaine 1, zones pilotes Vakinankaratra et Alaotra), auprès de 20 à 30 agriculteurs et techniciens :**

| Champ | Où le lire |
|---|---|
| Marque et modèle | Paramètres › À propos du téléphone |
| Version d'Android | Paramètres › À propos › Informations sur le logiciel |
| Mémoire vive (RAM) | Paramètres › À propos |
| Stockage libre | Paramètres › Stockage |
| État de la batterie et de l'écran | Observation, question à l'utilisateur |
| Téléphone partagé dans le foyer | Question |
| Accès habituel à internet | Question : jamais, au marché, quotidien |

**Règle de choix :**

1. **Téléphone de référence :** le modèle Android le plus fréquent du relevé parmi ceux qui ont **3 Go de RAM ou moins**. En acheter 2 exemplaires (un pour les mesures, un de réserve).
2. **Téléphone plancher :** l'appareil le plus ancien du relevé encore compatible avec la version minimale d'Android de l'app (`minSdk` dans `android/app/build.gradle.kts`). Il sert à vérifier que l'app démarre et que le scan aboutit, sans objectif de performance.

Consigner le choix et le résumé du relevé dans la section « Appareils retenus ».

## 2. Conditions de mesure

- Batterie chargée à plus de 80 %, câble débranché pendant les mesures de batterie.
- Mode avion activé (sauf mesure de synchronisation), luminosité de l'écran à 50 %.
- Applications en arrière-plan fermées, téléphone redémarré avant la série.
- Build en mode **profile** : proche du release, avec les outils de mesure.
- Jeu de 20 photos de référence toujours identique, rangé dans `ml/bench/photos/` : 10 cas de riz variés et 10 photos hors sujet.

> **Limite actuelle :** le scan n'accepte que la caméra (`scanning_screen.dart` appelle `ImageSource.camera`). Pour un banc de mesure reproductible, il faudra une option « choisir dans la galerie » réservée au mode développeur. À ajouter en P2.2. D'ici là, photographier les 20 photos affichées sur un écran, ce qui est moins reproductible.

## 3. Mesures

L'identifiant de l'application est `com.agrimada.agri_mada`.

```bash
# Construire et installer
flutter build apk --profile
adb install -r build/app/outputs/flutter-apk/app-profile.apk

# Taille de l'APK release (arm64) avec détail
flutter build apk --release --target-platform android-arm64 --analyze-size
```

| Mesure | Méthode | Cible initiale |
|---|---|---|
| **Démarrage à froid** | `adb shell am force-stop com.agrimada.agri_mada`, puis `adb shell am start -W -n <activité>`, où `<activité>` est donné par `adb shell cmd package resolve-activity --brief com.agrimada.agri_mada`. Relever `TotalTime`, 5 répétitions, garder la médiane. | ≤ 4 s |
| **Temps d'analyse** | Durée entre la validation de la photo et l'affichage du résultat, sur les 20 photos. Le temps d'inférence est déjà enregistré dans `DiagnosticLocal.inferenceTimeMs`, mais aucun log ne l'expose : ajouter un log structuré `inference_ms` (voir « Suites »). | ≤ 600 ms de bout en bout (cible P4.6) |
| **Mémoire** | `adb shell dumpsys meminfo com.agrimada.agri_mada` juste après chaque scan ; garder le `TOTAL PSS` le plus élevé. | ≤ 300 Mo en pic (cible P4.6) |
| **Batterie** | `adb shell dumpsys battery unplug`, puis `adb shell dumpsys batterystats --reset`, puis 50 scans enchaînés, puis `adb shell dumpsys batterystats --charged com.agrimada.agri_mada`. Relever aussi le pourcentage avant et après, puis `adb shell dumpsys battery reset`. | ≤ 5 % pour 50 scans |
| **Stockage** | Paramètres › Applications › AgriMada › Stockage, après installation puis après 100 diagnostics avec photos. | suivi, sans seuil pour l'instant |
| **Taille de l'APK** | Sortie de `--analyze-size`. | suivi, sans seuil pour l'instant |
| **Rejet hors sujet** | Nombre de photos hors sujet affichées comme un diagnostic « probable », sur les 10 du jeu. | 0 (critère P1.2) |

## 4. Relevé des résultats

Créer un fichier par série : `docs/qualite/mesures/AAAA-MM-JJ-<version>.md`.

```markdown
# Mesures <version> — <date>

Appareil : <modèle>, Android <version>, <RAM> · Build : profile, commit <sha>
Opérateur : <nom>

| Mesure | Résultat | Cible | Verdict |
|---|---|---|---|
| Démarrage à froid (médiane de 5) | | ≤ 4 s | |
| Analyse de bout en bout (médiane de 20) | | ≤ 600 ms | |
| Mémoire, pic TOTAL PSS | | ≤ 300 Mo | |
| Batterie, 50 scans | | ≤ 5 % | |
| Stockage après 100 diagnostics | | suivi | |
| Taille APK arm64 | | suivi | |
| Hors sujet classés « probable » (sur 10) | | 0 | |

Remarques :
```

Une version n'est proposée aux testeurs que si toutes les lignes avec une cible sont au vert, ou si l'écart est accepté et justifié par écrit dans ce fichier.

## 5. Appareils retenus

| Rôle | Modèle | Android | RAM | Raison du choix | Date |
|---|---|---|---|---|---|
| Référence | à compléter après le relevé | | | | |
| Plancher | à compléter après le relevé | | | | |

## 6. Suites

- **P1 :** ajouter un log structuré `inference_ms` (et `pipeline_ms` en P4) via `AppLogger`.
- **P2.2 :** option galerie réservée au mode développeur pour le banc de mesure.
- **P4 :** automatiser la mesure d'inférence dans `integration_test/performance_test.dart`, aujourd'hui marqué `skip`, sur le téléphone de référence.
