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

---

## ADR-007 — Session de scan multi-organes, multi-photos (2026-09-16)

**Statut :** adopté (phase P2)

- **Contexte :** jusqu'ici, une photo de feuille valait un diagnostic. Trois problèmes :
  - le modèle ne connaît que la feuille, alors que le flétrissement bactérien, la pyriculariose du collet ou les maladies de racines se lisent ailleurs sur la plante ;
  - trois photos de la même plante créaient trois lignes de journal, donc trois « maladies » là où il n'y en avait qu'une (P1.7) ;
  - une photo floue ou à contre-jour produisait quand même un nom de maladie.

  Les cours de pathologie de l'école partenaire (`docs/connaissances/sources.md`) décrivent les symptômes par organe et par stade : c'est la structure retenue.
- **Décision :**
  - **Unité de travail : la session.** `DiagnosticSessionLocal` (une session) porte N `ObservationLocal` (une photo + sa qualité + son top-k + ses réponses). Le journal, l'export et la synchronisation lisent les sessions ; un seul résultat par session. Les anciens diagnostics sont migrés au démarrage (`session_migration.dart`, idempotente par `origineDiagnosticId`).
  - **Étape « Qu'observez-vous ? »** (P2.1) : six organes plus « Je ne sais pas », qui enchaîne la séquence guidée plante entière → feuille → collet. Seule la feuille passe par le modèle (`Organe.usesModel`).
  - **Contrôle de qualité avant analyse** (P2.2) : netteté (variance du laplacien) et exposition mesurées hors du thread UI ; une photo refusée n'est ni analysée ni enregistrée, et le message dit quoi corriger. Les seuils viennent de 120 photos de terrain (`ml/reports/qualite_photo_2026-09-16.md`). L'exposition est jugée **avant** la netteté : une photo sombre est floue par conséquence, dire « trop sombre » est la consigne utile.
  - **Fusion** (P2.4) : somme des log-probabilités des photos, pondérée à `poidsModele = 0.5`, probabilités bornées à [0,05 ; 0,95] ; les réponses au questionnaire et le contexte de parcelle ajoutent des indices ; softmax, top-3. Sans aucune observation passée par un modèle, `nommable` est faux : **aucune maladie n'est nommée**, la session part au technicien.
  - **Contexte de parcelle** (P2.5) : écosystème, région, tranche d'altitude, variété, saison, date de repiquage. Il suit la session, alimente l'a priori de la fusion et le message au technicien.
  - **Scan sans parcelle** (P2.6) : `parcelleLocalId` est nullable partout (local et serveur). Une session peut être rattachée à une parcelle après coup, depuis l'écran de résultat.
- **Conséquences :**
  - Le poids 0,5 et le bornage traduisent l'ADR-006 dans la fusion : le modèle ne peut à lui seul écraser ce que l'observateur déclare, et une fiche absente du top-k du modèle reste atteignable par les réponses.
  - Les pondérations du questionnaire sont des estimations d'expert, pas des mesures : elles seront recalibrées en P4 sur des diagnostics validés par des techniciens.
  - Le refus de photo peut bloquer un utilisateur sur un vieux téléphone ; les seuils sont volontairement plus permissifs que la calibration (p05 des photos nettes à 636, seuil à 350).
  - Le garde-fou petit écran (P1.10) couvre les quatre écrans du parcours, en français et en malgache.
- **Alternatives écartées :**
  - Garder une photo = un diagnostic et dédupliquer à l'affichage : le journal aurait menti sur ce qui a été observé, et rien n'aurait permis de croiser feuille et collet.
  - Moyenne des probabilités entre photos : une seule photo très confiante (souvent à tort, cf. ADR-006) aurait emporté la décision.
  - Analyser quand même les photos floues en baissant la certitude : le modèle donne des scores élevés sur du flou, la baisse de certitude n'aurait rien corrigé.

---

## ADR-008 — Phase P3 limitée aux jeux publics, pas de collecte terrain dans l'app (2026-09-16)

**Statut :** adopté par l'équipe (tâches P3.2, P3.6, P3.7 ; P3.3 abandonnée)

- **Contexte :** le plan de correction prévoyait un mode de collecte dans l'app
  (tâche P3.3, réservé aux techniciens et étudiants ISPM) pour photographier sur le
  terrain les classes absentes des jeux publics : racines, RYMV malgache
  (*mavoratsy*), dégâts de *voana*, toxicité ferreuse, pourriture de la gaine,
  stérilité au froid, dégâts de punaises (voir `ml/DATASETS.md`, section « Classes
  sans données publiques »). En cours de chantier, l'équipe a décidé de ne pas
  construire cette collecte terrain dans l'app et de s'appuyer plutôt sur
  l'ensemble des jeux déjà rassemblés (P0.4/ADR-003) : 8 jeux publics inventoriés
  (`ml/data/raw/inventory.csv`), environ 29 400 images utiles une fois les classes
  hors sujet écartées (`ml/data/manifest.csv`).
- **Décision :**
  - **P3.3 (mode collecte, rôle technicien, endpoint backend, consentement dans
    l'app) n'est pas construite.** Aucune colonne de rôle, aucun nouvel endpoint,
    aucun écran ajouté pour ce chantier.
  - **P3.2** : `ml/label_map.yaml` fait correspondre chaque étiquette brute des 8
    jeux déjà inventoriés à un id de `ml/taxonomy_v1.yaml` (44 classes brutes
    mappées, aucune oubliée — vérifié par `ml/scripts/apply_label_map.py`, qui
    échoue si une classe brute n'a pas de correspondance).
  - **P3.6** : `ml/data/manifest.csv` (versionné) trace chaque image utile
    (id, sha256, source, licence, organe, classe, site, date, annotateur, split),
    à la granularité image pour les fichiers déjà extraits et à la granularité
    archive pour les jeux publics pas encore décompressés (l'extraction réelle est
    laissée à P4.1). `ml/data/dedup.py` calcule les quasi-doublons par empreinte
    perceptuelle sur un dossier déjà extrait. DVC n'est pas initialisé : le
    manifeste reste versionné par git seul tant qu'aucun bucket d'images n'existe.
  - **P3.7** : `ml/scripts/fetch_negatives.py` (généralisation du script de P1.2)
    reste sur Wikimedia Commons pour les photos négatives du modèle de porte.
    Open Images et iNaturalist, mentionnés dans le plan, ne sont pas implémentés
    (Open Images demande des index de plusieurs Go, iNaturalist une intégration
    d'API distincte).
  - **P3.4 (protocole de collecte terrain) et P3.5 (annotation/contrôle par
    l'agronome)** sont recentrées sur les jeux publics : la validation à faire
    par l'agronome porte sur les correspondances de `ml/label_map.yaml` et sur
    les classes « à confirmer » de la taxonomie, pas sur des photos de terrain
    (voir `docs/donnees/annotation-controle-qualite.md`).
- **Conséquences :**
  - Les classes sans jeu public (racines, RYMV malgache, *voana*, toxicité
    ferreuse, pourriture de la gaine, stérilité au froid, punaises) restent non
    couvertes par un modèle. L'app doit le dire explicitement (« non couvert : à
    montrer à un technicien ») plutôt que deviner, comme le prévoyait déjà le
    tableau des risques du plan de correction.
  - P4 (modèles) démarre uniquement sur les jeux publics disponibles : le rappel
    et la précision par classe (critères P4.6) ne pourront être mesurés que pour
    les classes couvertes.
  - Si l'équipe décide plus tard de combler ces classes, une nouvelle décision
    (mode de collecte, partenariat, ou jeu tiers à trouver) sera nécessaire :
    ce chantier n'est pas fermé, seulement non engagé maintenant.
- **Alternatives écartées :**
  - Construire P3.3 comme prévu au plan : rôle technicien, stockage de photos
    côté serveur, écrans dédiés — écarté pour rester concentré sur l'exploitation
    des données déjà disponibles plutôt que sur une collecte terrain qui demande
    des techniciens sur site, hors du périmètre décidé pour ce chantier.
  - Utiliser Open Images/iNaturalist pour P3.7 dès maintenant : reporté, la
    volumétrie de mise en place (Open Images) ou l'intégration d'API distincte
    (iNaturalist) n'était pas justifiée pour ce tour.

---

## ADR-009 — Fiches de connaissance regroupées par problème, pas par classe de taxonomie (2026-09-17)

**Statut :** adopté (tâche P5.1 ; P5.2 à P5.6 non engagées)

- **Contexte :** `ml/taxonomy_v1.yaml` découpe chaque maladie par organe pour
  les besoins de la classification (ex. `pyriculariose_feuille`,
  `pyriculariose_noeud_collet` et `pyriculariose_cou` sont trois ids
  distincts). Le format de fiche du plan (P5.1) veut une fiche par problème
  qu'un agriculteur reconnaît, avec une entrée par organe où il se manifeste
  — pas une fiche par id de classification, qui aurait dupliqué le nom, les
  sources et la prévention de la pyriculariose trois fois.
- **Décision :**
  - `ml/scripts/generate_fiches.py` regroupe les ids de taxonomie en fiches
    par problème (table `FICHES`, champ `taxonomy_ids`) et calcule noms,
    agent et sources depuis `ml/taxonomy_v1.yaml` pour rester cohérent sans
    dupliquer à la main. Le contenu par organe (symptômes, confusions,
    conditions, prévention) est écrit à la main à partir du plan de
    correction (section « Diagnostiquer au-delà de la feuille ») et des
    `notes` déjà sourcées de la taxonomie.
  - Les classes « saines » et les catégories techniques de la porte
    (`riz_exploitable`, `pas_riz`, `photo_inexploitable`, `*_sain(e)`) n'ont
    pas de fiche : rien à prévenir ni à traiter.
  - 30 fiches livrées dans `knowledge/fiches/*.json` (27 générées + 3 déjà
    écrites à la main pour les carences NPK), toutes au statut `brouillon`
    (`validation.statut`), aucune relue par l'agronome.
  - `knowledge/schema.json` (JSON Schema) + `ml/scripts/validate_fiches.py`,
    intégré à la CI (job `fiches`) : vérifie la structure, qu'aucun produit
    ni dosage n'apparaît (`lutte_chimique.produits` toujours vide), et
    qu'aucune fiche brouillon n'est référencée dans `lib/` — vrai
    aujourd'hui par construction, puisque P5.3 (consultation hors ligne)
    n'est pas fait : le critère « terminé quand » de P5.1 est donc
    vérifiable mécaniquement dès qu'une intégration sera tentée.
- **Conséquences :**
  - Un contenu manquant au-delà de la `note` de taxonomie n'est jamais
    inventé : quelques fiches (`racines_rongees`, `foyers_desseches`) n'ont
    qu'une phrase, honnêtement incomplète, en attendant l'agronome.
  - P5.2 (rédaction) est fait dans son volume (~30 fiches, conforme à
    l'estimation du plan) mais pas dans sa validation : aucune fiche n'a de
    `validation.par`/`date` renseignés, et les noms malgaches restent `null`
    sauf ceux déjà sourcés d'une fiche FOFIFA dans la taxonomie.
  - P5.3 (écran Guides relié aux fiches), P5.4 (endpoint RAG, pgvector,
    SDK Anthropic) et P5.6 (boucle technicien, qui suppose une collecte
    terrain écartée par ADR-008) ne sont pas engagées : ce sont des chantiers
    à part entière (nouvelle fonctionnalité Flutter, choix d'infrastructure
    vectorielle sur une base actuellement SQLite, coût réel d'appels API),
    pas une suite mécanique de P5.1.
- **Alternatives écartées :**
  - Une fiche par id de taxonomie (comme les jeux d'entraînement) : aurait
    dupliqué pyriculariose, toxicité ferreuse et les foreurs plusieurs fois
    et cassé l'usage RAG visé (« une fiche = un sujet de conversation »).
  - Écrire du contenu par organe pour toutes les classes même sans source :
    écarté, contraire à l'honnêteté déjà pratiquée dans la taxonomie
    (`a_confirmer`, `symptome_a_preciser`).

---

## ADR-010 — Consultation hors ligne des fiches, brouillon compris (2026-09-17)

**Statut :** adopté (tâche P5.3)

- **Contexte :** le critère « terminé quand » de P5.1 (ADR-009) interdisait
  d'embarquer une fiche brouillon dans l'app — écrit avant que P5.3 (écran
  Guides relié aux fiches) ne soit engagée, en supposant une validation
  agronomique préalable. L'équipe a choisi d'avancer sur P5.3 sans attendre
  cette validation, comme elle affiche déjà des résultats de modèle non
  validés avec un bandeau « modèle expérimental » (ADR-006) plutôt que de ne
  rien montrer.
- **Décision :**
  - Les 30 fiches de `assets/knowledge/fiches.json` sont embarquées dans
    l'écran Guides, brouillon compris, à condition d'un bandeau visible par
    fiche (clé ARB `guidesDraftBadge`) indiquant qu'elle n'est pas validée
    par un agronome — même logique de divulgation qu'ADR-006.
  - `ml/scripts/validate_fiches.py` ne bloque plus l'embarquement de fiches
    brouillon ; il vérifie à la place que la clé de divulgation existe et
    est réellement utilisée dans `lib/` dès que `fiches.json` y est
    référencé. Une fiche embarquée sans divulgation reste bloquée en CI.
  - Le questionnaire de confusion (champ `confusions` d'une fiche) est un
    outil de lecture dans le guide, séparé du questionnaire de diagnostic de
    P2 (`lib/features/scan/domain/questionnaire.dart`, indices de fusion
    calibrés) : il aide à choisir entre deux fiches en les lisant, il n'ajoute
    aucun indice à la fusion d'une session de scan.
- **Conséquences :**
  - Un agriculteur ou un technicien peut désormais consulter hors ligne les
    30 classes de la taxonomie, pas seulement les 3 que le modèle embarqué
    sait reconnaître — utile même si le modèle ne progresse pas.
  - Le bandeau de divulgation devra rester quand des fiches seront validées
    une à une (P5.2) : `ml/scripts/validate_fiches.py` continuera de
    l'exiger tant qu'au moins une fiche reste brouillon.
- **Alternatives écartées :**
  - Attendre la validation agronomique de toutes les fiches avant d'écrire
    l'écran : aurait bloqué P5.3 indéfiniment, sans bénéfice pour
    l'utilisateur en attendant (le contenu brouillon reste plus utile que
    l'absence de contenu, tant qu'il est signalé comme tel).
  - Fusionner le questionnaire de confusion dans celui de P2 : aurait mélangé
    des indices calibrés (P2.4) avec un outil de lecture non calibré.
- **Suivi (revue de code du 2026-09-17) :**
  - La divulgation est désormais garantie par un test widget
    (`test/features/knowledge/presentation/widgets/fiche_card_test.dart`) et
    non plus seulement par la recherche de texte de `validate_fiches.py` :
    celle-ci restait verte si quelqu'un supprimait la condition d'affichage
    en laissant la clé ARB dans le fichier.
  - `validate_fiches.py` vérifie en plus que le bundle embarqué est le reflet
    exact de `knowledge/fiches/` (l'app ne lit que le bundle : le valider seul
    laissait passer un bundle périmé), que les confusions pointent vers des
    fiches existantes, et que les codes d'organe du schéma correspondent à
    l'enum `Organe` — un code connu du seul schéma ferait disparaître des
    symptômes en silence côté Flutter.
  - Une question de confusion non traduite vaut `null` et l'écran affiche le
    français : les fiches embarquaient un texte d'attente
    (« …à traduire et valider… ») qui s'affichait tel quel en malgache.

---

## ADR-011 — Conseil à partir des fiches : index en mémoire et API Gemini (2026-09-17)

**Statut :** adopté (tâches P5.4 et P5.5)

- **Contexte :** le plan prévoyait un endpoint RAG sur pgvector avec le SDK
  Anthropic (rappelé dans ADR-009). Le backend tourne sur SQLite, le corpus se
  limite aux 30 fiches (environ 150 extraits), et l'équipe dispose d'une clé
  Google AI Studio. P5.5 prévoyait 150 cas validés par l'agronome référent,
  qui n'est pas disponible.
- **Décision :**
  - Index vectoriel dans un fichier versionné
    (`backend/app/rag/index_fiches.json`), construit hors ligne par
    `backend/scripts/build_rag_index.py` avec `gemini-embedding-001`
    (768 dimensions) et chargé en mémoire ; recherche exacte par similarité
    cosinus. Ni pgvector ni migration vers Postgres.
  - Génération par l'API Gemini, SDK `google-genai`, modèle
    `gemini-3.5-flash-lite` par défaut (variable `RAG_MODELE_GENERATION`).
  - `POST /api/conseil/question` : compte connecté obligatoire, quota de
    20 questions par compte et par jour (heure de Madagascar), question rendue
    au quota quand Gemini ne répond pas. Seul le nombre de questions est
    stocké (table `usages_conseil`), jamais leur texte.
  - Trois barrières contre l'invention : seuil de similarité (sous le seuil,
    réponse fixe sans appel au modèle), réponse `HORS_FICHES` exigée du modèle
    quand les extraits ne répondent pas, et filtre appliqué après génération
    qui remplace toute réponse citant un produit ou une dose (ADR-005) — la
    consigne seule ne le garantit pas.
  - Réponses en français ou en malgache selon la demande. Chaque réponse
    porte des avertissements codés, que l'application pourra traduire :
    `reponse_automatique`, `fiches_brouillon` (ADR-010), `malgache_non_relu`.
  - P5.5 : 150 cas (`knowledge/eval/cas_rag.yaml`) validés par l'équipe
    elle-même, sans agronome — décision explicite de l'équipe.
    `backend/scripts/eval_rag.py` mesure la recherche, propose un seuil,
    vérifie abstention, sécurité et avertissements, et produit un CSV des
    réponses à relire.
- **Conséquences :**
  - Toute modification de `knowledge/fiches/` impose de reconstruire l'index,
    clé API comprise : `tests/test_rag.py` échoue en CI tant que l'empreinte
    des fiches ne correspond plus.
  - Le conseil exige une connexion : il complète le guide hors ligne
    (ADR-010), il ne le remplace pas. L'application Flutter ne l'appelle pas
    encore.
  - Les résultats de P5.5 mesurent la cohérence du conseil avec les fiches,
    pas la vérité agronomique : ni les fiches ni les cas n'ont été relus par un
    agronome.
  - Sur l'offre gratuite de Google AI Studio, les contenus envoyés peuvent
    servir à Google pour améliorer ses services (à vérifier dans les
    conditions en vigueur). Aucune identité ni localisation n'est transmise,
    mais un agriculteur peut écrire ce qu'il veut dans sa question : passer à
    l'offre payante avant un usage réel.
- **Alternatives écartées :**
  - pgvector sur Postgres : migration d'infrastructure complète pour environ
    150 vecteurs.
  - sqlite-vec : dépendance binaire à installer en local, en CI et dans
    l'image Docker, sans gain à cette échelle.
  - Quota en mémoire, comme la limite de connexion (P1.11) : remis à zéro à
    chaque redémarrage, il ne plafonnerait pas la facture de façon fiable.
  - SDK Anthropic prévu au plan : l'équipe dispose d'une clé Google et
    n'en voit pas le besoin.

---

## ADR-012 — Agent de conseil relié aux fiches, parcelles et scans, derrière des garde-fous déterministes (2026-09-17)

**Statut :** adopté

- **Contexte :** le conseil RAG (ADR-011) ne voit que les fiches. L'équipe
  veut un agent qui relie les briques existantes — fiches, parcelles et leur
  contexte de culture, scans synchronisés (sessions, pistes de la fusion,
  réponses au questionnaire) — et les garde-fous qui manquent pour que le
  système soit complet. Deux constats faits avec le vrai modèle avant de
  concevoir : `gemini-3.5-flash-lite` sait appeler des outils, mais il a
  appelé `dernier_scan(parcelle_id=12)` avec un identifiant tiré de la
  question, et il a classé « Quel fongicide pour ma rizière ? » comme une
  question sur la parcelle plutôt qu'une demande de produit.
- **Décision :**
  - **Agent à outils, boucle bornée** (`backend/app/agent/`,
    `POST /api/agent/message`) : Gemini choisit parmi quatre outils en lecture
    seule — `rechercher_fiches`, `lire_fiche`, `lister_parcelles`,
    `derniers_scans` —, 4 appels au plus par question, plafond de jetons en
    entrée, arguments validés strictement (tout argument inconnu, dont un
    `user_id`, est refusé).
  - **Cloisonnement dans le code** : chaque outil filtre par le compte
    authentifié ; une parcelle d'un autre compte répond « introuvable ». Les
    champs saisis par l'agriculteur (nom de parcelle, variété, réponses) sont
    nettoyés, raccourcis et présentés comme des données.
  - **Pont modèle → fiches** explicite (`correspondances.py`) : les sessions
    portent les étiquettes du modèle embarqué (`Bacterial leaf blight`…), pas
    les identifiants de fiches ; `Leaf smut` (charbon foliaire) n'a aucune
    fiche et le dit. Un scan que l'app ne nomme pas (aucune observation passée
    par le modèle, ou certitude « incertain », ADR-006/007) n'est pas nommé
    par l'agent non plus.
  - **Garde-fous d'entrée, sans modèle** : urgence de santé humaine (servie
    avant le coupe-circuit, le consentement et le quota), tentative
    d'injection, salutation, demande de produit ou de dose (consigne
    renforcée et orientation technicien), masquage des téléphones et
    courriels avant tout envoi à Google et tout stockage.
  - **Garde-fous de sortie, sans modèle** : produit ou dose → message fixe
    (ADR-005) ; réponse sans aucun outil → « hors fiches » ; maladie nommée
    sans que les outils l'aient renvoyée → réponse de repli construite à
    partir des seules preuves ; diagnostic affirmé (ADR-006) → même repli.
    Seules les fiches effectivement nommées sont citées ; l'avertissement
    « brouillon » porte sur toutes les fiches consultées.
  - **Orientation technicien** avec motifs codés : `piste_a_confirmer`,
    `scan_sans_nom`, `gravite_elevee`, `maladie_a_signaler` (RYMV et
    bactérioses), `hors_fiches`, `demande_traitement`.
  - **Conversation multi-tours à historique signé** : le serveur ne garde
    pas l'état ; il signe (HMAC dérivé de `SECRET_KEY`) chaque échange, lié au
    compte et à la conversation ; l'app renvoie les 6 derniers. Un échange
    modifié, fabriqué ou venu d'un autre compte est refusé (422), un échange
    de plus de 24 h est écarté.
  - **Traces avec les textes**, à la demande de l'équipe : table
    `traces_agent` (question masquée, réponse, outils, garde-fous, jetons,
    durée). En contrepartie : consentement explicite obligatoire (403 sinon,
    écran d'accord dans l'app), conservation 90 jours puis purge
    automatique, droit à l'effacement (`DELETE /api/agent/traces`, menu de
    l'écran).
  - **Coupe-circuit** `AGENT_ACTIF`, quota partagé avec le conseil RAG.
  - **Écran Flutter « Conseiller »** (`lib/features/agent/`) : accord avant
    tout envoi, bandeau permanent, avertissements traduits par l'app à partir
    de leur code, bouton « Demander à un technicien » (partage) quand le
    serveur le demande, synchronisation des scans avant chaque question (le
    serveur ne voit que ce qui est synchronisé).
- **Conséquences :**
  - Chaque question coûte de 1 à 5 appels à Gemini (souvent 2 ou 3) ; le
    quota par compte plafonne le total.
  - Les garde-fous déterministes ont des faux positifs possibles ; ils
    produisent alors une réponse plus pauvre mais sûre. Deux ont été trouvés
    et corrigés pendant les essais réels : « diagnostic **sur** votre
    culture » confondu avec « sûr » une fois les accents retirés, et « **non**
    un diagnostic certain » pris pour une affirmation.
  - La documentation du SDK indique le rôle `tool` pour les réponses
    d'outils ; l'API Gemini le refuse (400) : le rôle `user` est utilisé.
  - Les textes conservés sont des données personnelles potentielles, lues
    aussi par Google sur l'offre gratuite : passer à l'offre payante et
    confirmer la base légale avant un usage réel.
  - Le journal serveur (`GET /api/journal`) lisait encore l'ancienne table
    `diagnostics` et affichait « malade » pour toute piste. Corrigé dans la
    foulée : il lit les sessions, applique la règle de l'app (`malade`
    seulement pour un résultat probable, sinon `a_confirmer`, ADR-006) et ne
    garde les anciens diagnostics qu'en repli pour une parcelle sans session.
  - L'écran n'a été vérifié que par tests widget (aucun émulateur sur le
    poste) ; les chaînes malgaches sont à relire comme les autres.
- **Alternatives écartées :**
  - Orchestrateur à plan fixe (le code choisit les briques) : plus
    prévisible, mais incapable d'enchaîner librement parcelle → scan → fiche.
  - Classer l'intention avec le modèle pour router les demandes dangereuses :
    le modèle s'est trompé sur une demande de fongicide.
  - Conversation stockée côté serveur : aurait lié l'agent à la durée de
    conservation des traces ; l'historique signé garde l'agent sans état.
  - Traces sans texte : proposé, écarté par l'équipe au profit de
    l'amélioration des fiches à partir des vraies questions.

---

## ADR-013 — Architecture à trois étages réduite aux données disponibles (2026-09-17)

**Statut :** adopté comme premier essai (tâche P4.2) ; aucun modèle intégré à l'app

- **Contexte :** le plan (P4.2) prévoit une porte à 8 sorties (6 organes, pas
  du riz, photo inexploitable), un modèle multi-étiquette par organe et une
  fusion. Les jeux publics ne contiennent aucune photo de collet, de racines
  ou de plante entière, et très peu de tige et de panicule ; la collecte
  terrain a été écartée (ADR-008). Le modèle plat `feuille_v2` (13 classes
  dans un softmax, porte comprise) servait de point de comparaison.
- **Décision :**
  - **Étage A** (`ml/scripts/train_porte.py`, `ml/models/porte_v1`) : 2
    sorties seulement, `pas_riz` / `riz_exploitable`. L'organe reste choisi
    par l'agriculteur (P2.1) et la photo inexploitable refusée par les seuils
    de netteté et d'exposition (P2.2) : un classifieur d'organe entraîné sans
    photo de 3 organes sur 6 échouerait sans le dire.
  - **Étage B** (`ml/scripts/train_feuille_multilabel.py`,
    `ml/models/feuille_multilabel_v1`) : feuille seulement, 11 sorties
    sigmoïdes, seuil par classe exporté dans `thresholds.json`, feuille saine
    quand aucune sortie ne dépasse son seuil.
  - **Étage C** : `ml/scripts/eval_chaine.py` mesure la chaîne par une décision
    déterministe ; le branchement dans la fusion de P2.4
    (`lib/core/ai/diagnosis_fusion.dart`) attend P4.5.
  - Les deux modèles réutilisent le cache de features et le découpage de
    `train_feuille.py` : même validation que `feuille_v2`, comparaison directe.
- **Conséquences (mesurées, `ml/reports/architecture_3_etages_2026-09-17.md`) :**
  - Sur la validation, la chaîne fait **moins bien** que le modèle plat
    (78,7 % contre 83,0 % d'exactitude) : presque tout l'écart vient des
    feuilles saines (F1 0,70 contre 0,85), à cause de seuils choisis classe par
    classe pour le meilleur F1. Même défaut que celui qui a motivé ADR-006.
  - Sur les 50 photos hors sujet indépendantes, la chaîne nomme une maladie à
    tort 3 fois contre 8 pour le modèle plat ; les deux en rejettent 41.
  - La porte rejette 98,8 % des négatifs de validation mais seulement 82 %
    des photos hors sujet indépendantes : elle a appris le style de la
    collecte, la cible P4.6 (95 %) n'est pas atteinte.
  - Aucun modèle ne remplace l'embarqué : ni la chaîne ni le modèle plat ne
    remplissent P4.6, et le choix entre les deux dépend d'un arbitrage
    (fausses alertes sur riz sain contre maladies nommées sur du hors sujet)
    qui revient à l'équipe.
  - Chaque `.tflite` embarque son propre backbone : un seul modèle à deux
    sorties sera nécessaire avant toute intégration.
- **Alternatives écartées :**
  - Porte à 8 sorties avec les seules données existantes : 3 organes sans
    aucune image, le modèle les aurait confondus avec les autres sans signal.
  - Remplir les organes manquants avec des images d'autres plantes ou des
    photos de feuilles recadrées : données trompeuses, résultats invérifiables.
  - Garder un seuil unique de 0,5 pour l'étage B : plus simple, mais laisse
    les classes rares sans rappel ; le réglage conjoint des seuils, sous
    contrainte sur les feuilles saines, est la suite proposée.

---

## ADR-014 — feuille_v2 embarqué dans l'app, garde-fous d'ADR-006 rétablis pour les sessions (2026-09-17)

**Statut :** adopté (tâche P4.5, partielle)

- **Contexte :** l'app embarquait encore le modèle de l'audit (3 classes, 120
  images, sans classe saine). Avant de le remplacer, une mesure a reproduit
  ce que voit l'agriculteur pour une photo de feuille
  (`ml/reports/comparaison_integration_2026-09-17.md`). Elle a révélé que
  **l'app nommait une maladie sur 50 photos hors sujet sur 50 et sur 670
  feuilles saines sur 670**. Lors de la refonte en sessions (P2, ADR-007),
  deux garde-fous d'ADR-006 avaient été perdus sans qu'aucun test ne le
  voie :
  - `session_scan_provider.dart` ne transmettait que le classement du modèle :
    la certitude calculée par le service, qui applique le contrôle de
    végétation (10 %), était jetée ;
  - `session_result_screen.dart` affichait le nom de la première classe dès
    qu'une photo était passée par le modèle, même en certitude « incertain »,
    et la session l'enregistrait comme résultat.
- **Décision :**
  - **Modèle :** `ml/models/feuille_v2` (13 classes dans un softmax, dont
    `feuille_saine` et `pas_riz`) remplace l'embarqué ; l'ancien est archivé
    dans `ml/models/embarque_v1`. `model_version.json` passe en 2.0.0. La
    chaîne à trois étages (ADR-013) n'est pas retenue ici : la fusion de P2.4
    attend des probabilités qui somment à 1, pas des sigmoïdes, et le modèle
    plat, garde-fous rétablis, ne nomme plus qu'une photo hors sujet sur 50
    (la chaîne en nommait 3, mesurée sans ces garde-fous : comparaison
    indicative seulement).
  - **Garde-fous rétablis dans la fusion** (`diagnosis_fusion.dart`) : une
    photo que le modèle rejette (moins de 10 % de végétation, ou `pas_riz` en
    tête) n'apporte aucun score ; `pas_riz` n'est jamais un candidat ; un
    résultat « incertain » n'est pas nommable ; si toutes les photos vues par
    le modèle sont rejetées, la certitude enregistrée est « incertain », pour
    que l'agent backend (qui lit certitude et top 3) ne nomme pas une piste
    tirée des seules réponses.
  - **Écran :** trois cas distincts — maladie nommée, photo analysée mais rien
    retenu (« L'application ne reconnaît pas cette photo », consignes de
    reprise), organe non analysé (message existant). Pas de question sur la
    part de parcelle touchée pour une plante saine.
  - **Présentation inchangée** : `probableMinScore` reste à 0,999, les
    résultats restent des pistes à confirmer avec la mention « modèle
    expérimental ». Rien n'est mesuré sur des photos malgaches (P4.6).
  - **Deux vocabulaires cohabitent** : les ids de taxonomie du nouveau modèle,
    et les étiquettes anglaises de l'ancien, gardées dans `DiseaseCatalog` et
    dans `backend/app/agent/correspondances.py` pour les sessions déjà
    enregistrées ou synchronisées. `DiseaseInfo.ficheId` relie chaque classe à
    sa fiche de connaissance (`pyriculariose_feuille` → `pyriculariose`).
  - **Questionnaire** : indices réexprimés dans le vocabulaire du modèle ;
    l'indice du charbon foliaire (sans équivalent) est retiré ; aucun indice
    inventé pour les nouvelles classes. Un test impose désormais que chaque clé
    d'indice soit une étiquette du modèle embarqué.
- **Conséquences (mesurées sur la validation publique, photo seule) :**
  - Hors sujet avec une maladie nommée : 50/50 → 1/50 ; feuilles saines avec
    fausse alerte : 670/670 → 42/670 ; maladies avec le bon nom : 15 % → 67 %,
    avec un mauvais nom : 85 % → 7 %.
  - 26 % des vraies maladies n'affichent rien ou « saine » (pyriculariose
    34 %) : l'app renvoie alors vers le technicien, comme voulu.
  - Le script `ml/scripts/eval_off_topic.py` ne vaut plus que pour son groupe
    hors sujet : ses feuilles de riz viennent des jeux d'entraînement de
    `feuille_v2`. `ml/scripts/comparer_integration.py` le remplace pour le riz.
  - Les nouvelles chaînes malgaches (noms de maladies, message « non
    reconnue ») sont à relire comme les autres
    (`docs/traductions/relecture-malgache.csv`).
  - Rien n'a été vérifié sur téléphone (aucun émulateur sur le poste) : taille
    de l'APK, latence et mémoire du nouveau modèle restent à mesurer.
  - Restent de P4.5 : `DiagnosisEngine`/`model_registry.dart`, inférence en
    isolate, mise à jour à distance vérifiée par SHA-256.
- **Alternatives écartées :**
  - Garder l'ancien modèle et corriger seulement les garde-fous : l'ancien
    modèle, même corrigé, nomme une maladie sur 21 photos hors sujet sur 50 et
    donne un mauvais nom à 55 % des maladies.
  - Intégrer la chaîne à trois étages : nécessite de redéfinir la fusion pour
    des sorties sigmoïdes, pour un moins bon résultat sur les feuilles saines.
  - Relever le seuil « probable » maintenant que le modèle est meilleur :
    aucune mesure sur photos malgaches ne le justifie (P4.6).
  - Traduire les anciennes étiquettes des sessions enregistrées vers le
    nouveau vocabulaire : migration de données sans bénéfice, le catalogue
    sait déjà lire les deux.
