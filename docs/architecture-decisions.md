# Journal des décisions d'architecture

Chaque décision structurante du projet AgriMada est consignée ici : contexte, décision, conséquences, alternatives écartées. On relit ce journal plutôt que de redécouvrir l'historique des choix.

---

## ADR-001 — Intégration continue et quarantaine des tests (2026-09-14)

**Statut :** adopté (tâche P0.3)

- **Contexte :** le dépôt n'avait pas de CI. Au 14 septembre 2026, `flutter analyze` signalait 12 problèmes (3 avertissements) et `flutter test` 23 échecs. Une partie venait du harnais de test lui-même :
  - mock du stockage sécurisé mal typé ;
  - chemin Isar codé en dur vers le poste d'un développeur (`C:/Users/dilan/...`) ;
  - `ProviderScope` ou `AppLocalizations.delegate` absents ;
  - texte sans accent.

  L'autre partie révélait de vrais défauts de l'application. Le backend passait (17 tests).
- **Décision :**
  - `.github/workflows/ci.yml` sur GitHub Actions, déclenché sur `push` vers `main`, sur les pull requests et à la demande :
    - job Flutter : SDK 3.41.9 épinglé, `flutter analyze --fatal-warnings --no-fatal-infos`, puis `flutter test` ;
    - job backend : Python 3.12, `pytest`.
  - Les tests d'intégration (`integration_test/`, Patrol) ne tournent pas en CI : ils demandent un appareil.
  - Les tests dont le harnais était faux sont corrigés.
  - Dans les tests, Isar charge sa bibliothèque native depuis le package `isar_flutter_libs`, via `test/helpers/isar_test_core.dart`, sans réseau : le harnais `flutter test` bloque le HTTP.
  - Les tests qui échouent à cause d'un vrai défaut de l'app sont **mis en quarantaine** (`skip` avec la raison et la tâche du plan qui les réactivera). La liste ci-dessous fait foi.
- **Conséquences :** une CI verte signifie « aucune régression en dehors de la quarantaine ». Une tâche du plan n'est terminée que si elle réactive les tests qui lui sont rattachés. Les infos d'analyse ne bloquent pas encore ; les rendre bloquantes une fois la dette résorbée.
- **Alternatives écartées :**
  - CI non bloquante (`continue-on-error`) : elle n'empêche aucune régression.
  - Réécrire les tests pour valider le comportement actuel : cela entérinerait des régressions relevées par l'audit.
  - Tout réparer en P0 : hors périmètre, ces écrans sont refondus en P1.

### Tests en quarantaine

| Test | Défaut réel de l'app | Réactivation |
|---|---|---|
| ~~`test/features/home/presentation/screens/home_screen_test.dart`, groupe « HomeScreen callbacks » (4 tests)~~ | ~~`AppSidebar` est rendu hors de tout widget `Material` : ses `ListTile` lèvent « No Material widget found ». Il remplace aussi le drawer attendu par ces tests.~~ | **Réactivé** le 2026-09-15 (P1.10) : `HomeDrawer` et `AppSidebarOverlay` fusionnés en un seul `Drawer` Material (`AppMenuDrawer`) ; tests rendus dans le shell `MainLayout`, plus 5 tests d'états réels |
| ~~`test/features/scan/presentation/screens/scan_result_screen_test.dart`, groupe « ScanResultScreen » (3 tests)~~ | ~~L'écran de résultat n'appelle plus la sauvegarde ni le partage attendus.~~ | **Réactivé** le 2026-09-15 : écran et tests réécrits en P1.1 / P1.7 (6 tests) |
| ~~`test/app/router_guard_test.dart`, « redirige vers home quand connecte et acces login »~~ | ~~Même défaut `AppSidebar` sur l'accueil.~~ | **Réactivé** le 2026-09-15 (P1.10) |
| ~~`test/app/router_guard_test.dart`, « redirige vers onboarding si onboarding non termine »~~ | ~~`onboarding_screen.dart:207` déborde verticalement : 107 px sur la surface de test 800×600, 184 px sur un téléphone de 360×780.~~ | **Réactivé** le 2026-09-15 (P1.10) : diapositives défilantes, cartes d'état fusionnées et masquées sous 680 px de hauteur |

**La quarantaine est vide depuis le 2026-09-15.** Le débordement de 144 px de `login_screen.dart:212` à 360 dp est aussi corrigé (`Wrap`). Le garde-fou `test/app/small_screen_layout_test.dart` rend connexion, inscription, bienvenue, onboarding et accueil en 360×640 et 360×780, en français et en malgache (20 tests).

---

## ADR-002 — Taxonomie organe × problème en trois étages (2026-09-14)

**Statut :** proposé, en attente de validation par l'agronome référent (tâche P0.2)

- **Contexte :** le modèle actuel est un classifieur fermé à 3 classes, limité à la feuille. Il attribue une maladie à toute image, et beaucoup de problèmes du riz à Madagascar ne se lisent pas sur la feuille : galles de nématodes et toxicité ferreuse sur les racines, *voana* au collet, foreurs dans la tige, pyriculariose du cou, foyers de RYMV dans la parcelle.
- **Décision :** la taxonomie de référence est `ml/taxonomy_v1.yaml`.
  - **Étage A :** porte d'entrée (riz exploitable, pas du riz, photo inexploitable) et organe photographié (6 organes).
  - **Étage B :** problèmes par organe, destinés à des modèles multi-étiquettes où « sain » correspond à aucune sortie au-dessus du seuil.
  - Une classe `a_confirmer` n'entre dans aucun modèle tant que sa présence à Madagascar n'est pas confirmée.
  - Le tungro est exclu.
  - Un nom malgache n'est renseigné que s'il vient d'une fiche FOFIFA ; sinon il reste vide jusqu'à validation.
- **Conséquences :**
  - Un modèle par organe, ajouté au rythme des données.
  - Collecte locale obligatoire pour les classes sans jeu public (racines, RYMV, *voana*, toxicité ferreuse).
  - Les correspondances avec les étiquettes des jeux publics sont définies en P3.2 (`ml/label_map.yaml`).
- **Alternatives écartées :**
  - Un classifieur softmax unique d'une quarantaine de classes : il force un choix même sans symptôme et mélange les organes.
  - Garder le seul classifieur de feuille : il ne couvre pas les problèmes visibles ailleurs.

---

## ADR-003 — Récupération directe des données publiques (2026-09-14)

**Statut :** adopté

- **Contexte :** le plan prévoyait une convention avec FOFIFA et les DRAE (tâche P0.1) avant de réutiliser leurs fiches, ainsi qu'une relecture des licences de chaque jeu d'images. L'équipe considère que ces sources sont publiques.
- **Décision :**
  - Pas de note de partenariat.
  - Les jeux d'images et les documents publics sont récupérés directement par `ml/scripts/fetch_public_data.py`, à partir du manifeste `ml/data/sources.yaml`.
  - Les licences sont acceptées par l'équipe. La licence déclarée par l'hébergeur est tout de même relevée, et la source est citée pour les jeux sous CC BY.
  - Les fichiers téléchargés ne sont pas versionnés (`ml/data/raw/`, `knowledge/sources/`). Chacun est vérifié par SHA-256 et consigné dans `ml/data/raw/downloads.csv`.
- **Conséquences :**
  - N'importe quel membre de l'équipe peut reconstituer les mêmes données avec une seule commande.
  - Les jeux hébergés sur Kaggle demandent un jeton personnel.
  - La validation agronomique des fiches, des traductions et des annotations reste nécessaire, mais n'est plus encadrée par une convention.
- **Alternatives écartées :**
  - Versionner les images dans git : trop volumineux.
  - Téléchargements manuels : non reproductibles et sans traçabilité.

---

## ADR-004 — Session hors ligne, synchronisation idempotente et durcissement du backend (2026-09-15)

**Statut :** adopté (tâches P1.8, P1.9 et P1.11)

- **Contexte :**
  - le jeton JWT de 24 h, combiné à `clearSession()` sur toute réponse 401, déconnectait l'agriculteur et effaçait aussi sa langue et son onboarding ;
  - la synchronisation associait les réponses du serveur par position : un renvoi après une réponse perdue créait des doublons ;
  - le backend démarrait avec une `SECRET_KEY` par défaut, un CORS `*` avec identifiants, `--reload` en production, un compte admin/admin, des mots de passe de 4 caractères, sans limite de tentatives de connexion et sans migrations.
- **Décision :**
  - **Sessions :** jeton d'accès de 60 min et jeton de rafraîchissement opaque de 60 jours, stocké haché (SHA-256) et renouvelé à chaque usage (rotation). Présenter un jeton déjà révoqué révoque tous les jetons de l'utilisateur. Routes `POST /api/auth/refresh` et `POST /api/auth/logout`.
  - **App :** `AuthInterceptor` (`QueuedInterceptor`) renouvelle le jeton une seule fois sur 401 puis rejoue la requête. Il ne vide jamais la session :
    - si le serveur refuse le renouvellement, la session est marquée « reconnexion requise » et seule la synchronisation attend ;
    - hors ligne, rien n'est modifié.
    
    `clearSession()` conserve la langue et l'onboarding.
  - **Synchronisation :** chaque parcelle et chaque diagnostic porte un `client_uuid` (UUID v4 généré sur le téléphone, attribué aux anciens enregistrements lors de la synchro).
    - Le serveur impose l'unicité de `(user_id, client_uuid)` : un renvoi met à jour la parcelle ou ignore le diagnostic déjà reçu.
    - Le client associe la réponse par `client_uuid`.
    - Un diagnostic désigne sa parcelle par `parcelle_client_uuid` (prioritaire) ou `parcelle_id`, et transmet sa `certitude`.
  - **Backend :**
    - `SECRET_KEY` obligatoire : 32 caractères minimum, valeur d'exemple refusée ;
    - CORS fermé par défaut (`CORS_ORIGINS`) et `DEBUG` désactivé par défaut ;
    - mot de passe de 8 caractères minimum, côté serveur et app ;
    - au plus 5 échecs de connexion par couple compte et IP, et 20 par IP, sur 15 min (réponse 429 avec `Retry-After`) ;
    - schéma géré par Alembic (`0001_schema_initial`, `0002_sessions_et_sync`) au lieu de `create_all` ;
    - Docker sans `--reload`, avec un utilisateur non root et les migrations au démarrage ;
    - `seed.py` sans identifiants par défaut.
- **Conséquences :**
  - Une base locale créée avant Alembic se met à niveau avec `alembic stamp 0001_schema_initial` puis `alembic upgrade head`. Le compte hérité `admin` est à supprimer.
  - Un `.env` qui contient encore la valeur d'exemple de `SECRET_KEY` empêche le serveur de démarrer : il faut générer une clé.
  - Le limiteur de tentatives est en mémoire. Il suffit pour une instance unique ; avec plusieurs instances, il faudra un stockage partagé.
  - Si la réponse d'un renouvellement se perd, le jeton présenté ensuite est déjà révoqué : l'agriculteur doit se reconnecter pour synchroniser, sans perdre ses données locales.
  - Tests :
    - backend : `backend/tests/test_securite.py`, `test_sync_idempotence.py`, `test_migrations.py` ;
    - app : `test/core/network/auth_interceptor_test.dart`, `test/core/sync/sync_provider_test.dart`, `test/core/local_db/session_service_test.dart`.
- **Alternatives écartées :**
  - Allonger la durée du JWT : un jeton volé resterait valable des semaines, sans révocation possible.
  - Garder la déconnexion sur 401 : un agriculteur hors ligne perdrait l'accès à ses parcelles.
  - Dédoublonner côté serveur sur le contenu (nom, date) : deux parcelles homonymes légitimes seraient fusionnées.
  - Utiliser slowapi pour limiter les tentatives : une dépendance de plus pour une seule route.

---

## ADR-005 — Guide des maladies à la place de « Solutions agricoles » (2026-09-15)

**Statut :** adopté (tâches P1.1 et P1.5)

- **Contexte :** l'écran `GuidesScreen` s'intitulait « Solutions agricoles » et recommandait, sans source, des « fongicides et insecticides raisonnés », des « apports NPK » et l'essai de nouveaux traitements. Le menu l'annonçait pourtant comme « Guides des maladies ». Les fiches traduites `guideDisease*` et les conseils `prevention*` existaient dans les ARB, mais aucun écran ne les affichait.
- **Décision :**
  - `GuidesScreen` affiche une fiche par classe du modèle, tirée de `DiseaseCatalog` : nom, nom scientifique, description, symptômes, causes et gestes recommandés. Un rappel invite à consulter un technicien avant tout traitement.
  - `PreventionScreen` utilise ses clés ARB.
  - Corrections de contenu :
    - charbon foliaire : « tiges noires » devient « petites taches noires » (FR et MG) ;
    - tache brune en malgache : « mainty » (noir) devient « volontany » (brun).
- **Conséquences :**
  - Le test du catalogue vérifie aussi qu'aucune fiche ne cite de produit ni de dosage.
  - Le contenu des fiches reste à valider par FOFIFA (P2).
  - Le garde-fou `test/l10n/no_hardcoded_text_test.dart` bloque tout nouveau texte visible écrit en dur dans `lib/`.
- **Alternative écartée :** traduire l'écran tel quel, ce qui aurait diffusé des conseils non sourcés en malgache.

---

## ADR-006 — Résultats du modèle actuel présentés comme des pistes à confirmer (2026-09-16)

**Statut :** adopté par l'équipe (tâche P1.2)

- **Contexte :** l'évaluation du 16 septembre (`ml/reports/eval_hors_sujet_2026-09-16.md`) porte sur 50 photos hors sujet et 600 feuilles de riz prises au champ. Avec le seuil provisoire de 0,70 :
  - 21 photos hors sujet (sol, eau, outils, zébus…) étaient des maladies « probables » ;
  - 105 feuilles saines sur 200 étaient présentées comme malades ;
  - la tache brune n'était jamais reconnue.

  Aucun seuil ne sépare le vrai du faux : à partir de 0,997, il n'y a plus de « probable » faux, mais plus de « probable » juste non plus.
- **Décision :**
  - `CertaintyThresholds.probableMinScore` passe à 0,999 : avec ce modèle, aucun résultat n'est « probable ».
  - Contrôle de végétation (`lib/core/ai/image_checks.dart`) : sous 10 % de pixels végétaux, le résultat est « incertain ».
  - Un résultat « possible » s'affiche « Piste à confirmer », avec la mention « modèle expérimental ». « Demander à un technicien » (partage de la photo et des pistes) passe avant « Enregistrer ».
  - Journal et détail de parcelle : une parcelle dont le dernier résultat n'est qu'une piste est « À confirmer », pas « Malade ».
- **Conséquences :**
  - L'app ne donne plus de diagnostic affirmatif tant que les modèles v2 ne sont pas validés sur le jeu de test malgache (P4.6) ; les seuils seront alors recalibrés (P4.4).
  - Le script d'évaluation lit les seuils dans le code de l'app : il reste la référence pour mesurer chaque futur modèle.
  - Les pistes restent souvent fausses : la mention « modèle expérimental » et le renvoi au technicien sont indispensables.
- **Alternatives écartées :**
  - Relever le seuil sans rien changer d'autre : la plupart des photos hors sujet et des feuilles saines seraient restées affichées comme « possible » avec un nom de maladie, sans mise en garde.
  - Ne nommer aucune maladie : plus sûr, mais cela privait les techniciens des pistes du modèle.
  - Retirer le scan : il reste utile pour photographier la plante et l'envoyer à un technicien.
