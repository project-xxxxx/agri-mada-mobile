# AgriMada : pitch et déroulé de la démonstration

> Support de présentation orale. Il contient le pitch, l'ordre dans lequel
> montrer les écrans, ce qu'il faut dire à chaque étape, la liste des
> fonctionnalités (importantes et secondaires) et les réponses aux questions
> probables. État de l'application au 17 septembre 2026.

---

## 1. En une phrase

**AgriMada aide le riziculteur malgache à décrire et suivre un problème sur son
riz, directement au champ et sans internet, et l'oriente vers le bon
interlocuteur au lieu de lui donner un faux diagnostic.**

---

## 2. Le pitch

### Version courte (30 secondes)

> À Madagascar, le riz est l'aliment de base. Quand une maladie touche une
> rizière, l'agriculteur est souvent seul : le technicien est loin et le réseau
> est faible. AgriMada est une application mobile qui fonctionne hors ligne.
> Elle guide l'agriculteur pour photographier la bonne partie de la plante,
> contrôle la qualité de la photo, pose quelques questions simples et analyse
> la feuille sur le téléphone. Surtout, elle n'invente rien : quand elle n'est
> pas sûre, elle le dit et prépare un message complet pour le technicien.
> Tout est enregistré dans un journal par parcelle, en français et en malgache.

### Version complète (2 minutes)

**Le problème**
- Le riz est la première culture de Madagascar. Pyriculariose, bactérioses,
  carences et ravageurs peuvent faire perdre une grande partie d'une récolte.
- L'agriculteur n'a pas toujours accès à un technicien agricole, ni à internet
  dans sa rizière.
- Les applications de diagnostic existantes se trompent souvent sur les photos
  prises au champ et affichent pourtant une réponse sûre d'elle. Un mauvais
  diagnostic peut conduire à un traitement inutile, voire dangereux.

**Notre solution**
- Une application Flutter **hors ligne** : l'intelligence artificielle tourne
  sur le téléphone.
- Un **parcours guidé** : choisir la partie de la plante observée, prendre
  jusqu'à 3 photos avec un contrôle de qualité, répondre à 3 ou 4 questions.
- Un résultat **honnête** : l'app nomme une piste seulement quand elle a assez
  d'éléments. Sinon, elle le dit, garde les photos et les réponses, et prépare
  un message pour le technicien.
- Un **journal agricole** par parcelle, avec recherche, filtres et export PDF/CSV.
- Un **guide de 30 fiches** consultable hors ligne, avec recherche en malgache.
- Un **conseiller en ligne** qui répond à partir des fiches et des scans, sans
  jamais recommander de produit ni de dose.

**Ce qui nous distingue**
- **La prudence est conçue dans le produit.** Sur un jeu de validation public,
  l'app ne nomme plus que 1 photo hors sujet sur 50, contre 50 sur 50 avant nos
  garde-fous.
- **Pensée pour le terrain malgache** : interface bilingue, noms locaux des
  maladies, contexte de la parcelle (bas-fond, tanety, altitude, saison
  *vary aloha*…).
- **Le technicien reste au centre** : l'app prépare son travail, elle ne le
  remplace pas.

**Où nous en sommes**
- Application fonctionnelle, APK Android installable, serveur FastAPI.
- Prochaine étape : un pilote avec des agriculteurs et des photos prises à
  Madagascar pour mesurer la fiabilité réelle du modèle.

---

## 3. Préparer la démonstration

À faire **la veille ou une heure avant**. Sans serveur, l'app reste bloquée à
l'écran de connexion.

| Élément | À vérifier |
|---|---|
| Serveur | L'API tourne sur le PC (`uvicorn --host 0.0.0.0 --port 8000` dans `backend/`). Le serveur cloud Railway est hors service. |
| Réseau | Le téléphone et le PC sont sur le même Wi-Fi. L'adresse IP du PC n'a pas changé : l'APK vise `http://192.168.0.199:8000/api`. Si elle a changé, reconstruire l'APK avec la nouvelle adresse. |
| Mise en veille | Désactiver la mise en veille du PC pendant la présentation. |
| Compte | Un compte de démonstration est créé et connecté (prénom affiché sur l'accueil). |
| Données | 2 ou 3 parcelles déjà créées, avec leur contexte, et 4 ou 5 scans variés dans le journal, pour que les filtres et l'export aient du contenu. |
| Photos | Quelques photos dans la galerie : une feuille de riz malade prise **au téléphone** (pas en gros plan « appareil photo », souvent rejeté), une feuille saine, une photo hors sujet. **Tester chacune avant.** |
| Conseiller | Accord déjà donné ou à donner en direct. Quota de 20 questions par jour : ne pas l'épuiser pendant les répétitions. Clé Gemini présente dans `backend/.env`. |
| Plan B | Captures d'écran (dossier `design file/`) ou vidéo enregistrée du parcours, au cas où le Wi-Fi tombe. |
| Écran | Téléphone projeté ou filmé, luminosité au maximum, notifications coupées. |

---

## 4. Déroulé de la démonstration (8 à 10 minutes)

Principe : suivre **une histoire**. Rakoto remarque des taches sur les feuilles
de sa rizière de bas-fond ; on le suit du premier lancement jusqu'au conseil.

### Acte 1 : Premier contact (1 min)

| # | Écran | Ce qu'on montre | Ce qu'on dit |
|---|---|---|---|
| 1 | **Écran de démarrage** | Logo, état « IA prête ». | « Le modèle est dans le téléphone, il se charge au démarrage. » |
| 2 | **Présentation (4 diapositives)** | Photographier, analyse hors ligne, diagnostic, suivi des parcelles. | « Quatre écrans pour comprendre l'app avant de commencer. On peut les revoir à tout moment. » |
| 3 | **Bienvenue, puis Connexion** | Connexion par numéro de téléphone. | « Le compte sert à sauvegarder les données sur le serveur. Le téléphone est plus courant qu'une adresse e-mail chez nos utilisateurs. » |

> Astuce : si la présentation a déjà été vue, l'ouvrir depuis le bouton **Aide**
> de l'accueil plutôt que réinstaller l'app.

### Acte 2 : L'accueil (1 min)

| # | Écran | Ce qu'on montre | Ce qu'on dit |
|---|---|---|---|
| 4 | **Accueil** | « Bonjour, Rakoto ! », indicateur de synchronisation, résumé de l'exploitation (analyse photo prête, nombre de parcelles). | « L'agriculteur voit tout de suite si l'analyse est disponible et combien de parcelles il suit. » |
| 5 | **Accueil, suite** | Carte « Une question sur votre riz ? », les 4 services (Mes parcelles, État des cultures, Maladies du riz, Prévenir les maladies). | « Tout part d'ici. » |
| 6 | **Barre du bas** | Accueil, Journal, et le **gros bouton de scan** au centre. Ouvrir aussi le **menu latéral**. | « L'action principale, le scan, est toujours à portée de pouce. » |

### Acte 3 : Le scan, cœur de l'application (3 à 4 min)

> Moment fort : **passer le téléphone en mode avion** juste avant, et le dire.

| # | Écran | Ce qu'on montre | Ce qu'on dit |
|---|---|---|---|
| 7 | **« Qu'observez-vous ? »** | Six parties de la plante (feuilles, tige et gaine, collet, racines, panicule, plante entière) et « Je ne sais pas ». Choisir **Feuilles**. | « Une maladie ne se voit pas toujours sur la feuille. L'agriculteur choisit ce qu'il observe. S'il ne sait pas, l'app le guide : la parcelle, puis une feuille, puis le collet. Seules les feuilles sont analysées par le modèle, et l'écran le dit. » |
| 8 | **Capture** | Conseil de cadrage propre à la partie choisie, compteur « 1 photo sur 3 », bouton **Importer depuis la galerie**. | « Jusqu'à trois photos par partie de la plante, prises ou importées. » |
| 9 | **Contrôle de qualité** | Montrer (ou raconter) un message : « Photo floue… », « Le soleil est derrière la plante… ». | « Avant toute analyse, l'app vérifie la photo et explique comment la reprendre. Une mauvaise photo donne un mauvais résultat. » |
| 10 | **Quelques questions** | Depuis quand ? Forme des taches ? Gouttes jaunes le matin ? Vitesse de propagation ? | « L'app combine ce que voit le modèle et ce que dit l'agriculteur. Ces réponses partent aussi au technicien. » |
| 11 | **Résultat du scan** | Niveau de certitude, bandeau « modèle expérimental », autres possibilités, question « Quelle part de la parcelle est touchée ? », « Que faire ? » **sans aucun produit ni dose**. | « Voilà ce qui compte : l'app parle de **piste à confirmer**, pas de diagnostic. Elle ne recommande jamais de produit chimique. » |
| 12 | **Demander à un technicien** | Le partage s'ouvre avec les photos, les réponses et les pistes (WhatsApp, SMS…). | « En un geste, le technicien reçoit tout ce qu'il faut pour se prononcer à distance. » |
| 13 | **Rattacher à une parcelle** | Le scan a été fait sans parcelle : le rattacher maintenant. | « On peut scanner d'abord et ranger ensuite : au champ, on n'a pas le temps de remplir un formulaire. » |

**Montrer les autres issues du résultat** (avec les photos préparées, ou en
captures) :
- **Photo hors sujet** : « L'application ne reconnaît pas cette photo. » Aucune
  maladie inventée, conseils pour reprendre la photo.
- **Racines ou tige** : « L'application ne nomme aucune maladie. Cette partie
  n'est pas analysée par le modèle. » Photos et réponses gardées pour le
  technicien.

> Phrase à placer : « Une app qui répond toujours quelque chose est dangereuse.
> La nôtre sait dire *je ne sais pas*. »

### Acte 4 : Le suivi (2 min)

| # | Écran | Ce qu'on montre | Ce qu'on dit |
|---|---|---|---|
| 14 | **Journal (historique des analyses)** | Recherche d'une maladie, filtres (7 derniers jours, plus d'un tiers touché, sains), tri (récents, anciens, plus graves), filtres par parcelle et par partie de la plante. | « Tous les scans restent sur le téléphone, même sans réseau. » |
| 15 | **Détail d'un scan** | Photos agrandissables, réponses, part touchée, « Voir la fiche du guide », « Refaire un scan de suivi », « Poser une question au conseiller », changer de parcelle, supprimer. | « Chaque scan devient un dossier complet qu'on peut rouvrir, suivre dans le temps et partager. » |
| 16 | **Mes parcelles** | Liste avec statut (Saine, Malade, **À confirmer**, Non analysée), surface, dernier diagnostic. | « Le statut “À confirmer” évite de déclarer une parcelle malade sur une simple piste. » |
| 17 | **Nouvelle parcelle** | Nom, photo, surface (hectares ou ares), emplacement, puis contexte : écosystème (irrigué, bas-fond, tanety), région, altitude, variété, saison (vary aloha, saison des pluies, contre-saison), date de repiquage. | « Le contexte aide l'analyse : certaines maladies dépendent de l'altitude ou de la saison. La date de repiquage situe le stade de la culture. » |
| 18 | **Détail de la parcelle** | État de santé, liste des analyses, « Faire une nouvelle analyse ». | |
| 19 | **Export** | Exporter en PDF ou CSV, puis partager. | « Utile pour une coopérative, un technicien ou un projet de suivi. » |

> Rétablir le réseau ici et montrer l'indicateur **Synchronisation…** : les
> données créées hors ligne partent vers le serveur.

### Acte 5 : Le savoir (1 min)

| # | Écran | Ce qu'on montre | Ce qu'on dit |
|---|---|---|---|
| 20 | **Guides des maladies** | Fiches d'identification, puis section **Guide complet** : 30 fiches, recherche en malgache (taper *menalavitra* ou *mativondrana*), symptômes, conditions favorables, « Peut se confondre avec », prévention, sources. Bandeau « Brouillon, non validé par un agronome ». | « Même les problèmes que l'app ne détecte pas encore ont une fiche. Tout est hors ligne. » |
| 21 | **Prévenir les maladies** | Astuce du moment, gestion de l'eau, pourquoi c'est efficace, gestes concrets. | « Mieux vaut prévenir : la gestion de l'eau et l'azote pèsent beaucoup. » |

### Acte 6 : Le conseiller (1 à 2 min, en ligne)

| # | Écran | Ce qu'on montre | Ce qu'on dit |
|---|---|---|---|
| 22 | **Accord préalable** | Durée de conservation (90 jours), traitement par Google Gemini, ne pas écrire de nom ni de numéro. | « L'agriculteur donne son accord en connaissance de cause et peut effacer ses échanges à tout moment. » |
| 23 | **Question suggérée** | « Que dit mon dernier scan ? » ou « Comment prévenir la pyriculariose ? ». Montrer les **fiches citées** et les avertissements. | « Le conseiller ne répond qu'à partir de nos fiches et des scans de l'agriculteur. » |
| 24 | **Question piège** | « Quel fongicide pour ma rizière ? » | « Il refuse de recommander un produit et renvoie vers un technicien. Sur 35 questions pièges testées, aucune réponse n'a donné de produit ni de certitude. » |

### Acte 7 : Pour finir (30 s)

| # | Écran | Ce qu'on montre | Ce qu'on dit |
|---|---|---|---|
| 25 | **Paramètres** | Passer la langue en **malgache** et revenir à l'accueil. | « Toute l'application existe en malgache. » |

**Phrase de conclusion**

> « AgriMada ne remplace pas le technicien agricole. Elle permet à
> l'agriculteur de réagir plus vite, avec les bonnes informations, et au
> technicien de travailler à distance sur un dossier complet. Notre prochaine
> étape est un pilote avec des agriculteurs, pour mesurer la fiabilité sur des
> photos prises à Madagascar. »

---

## 5. Les fonctionnalités

### Fonctionnalités importantes

| Fonctionnalité | Ce qu'elle apporte |
|---|---|
| **Scan guidé par partie de la plante** | Six parties (feuilles, tige et gaine, collet, racines, panicule, plante entière) et un parcours « Je ne sais pas ». |
| **Analyse IA hors ligne** | Modèle embarqué sur le téléphone, 11 problèmes des feuilles reconnus (dont pyriculariose, bactérioses, helminthosporiose, hispa, carences en azote, phosphore et potassium), plus « feuille saine » et « ce n'est pas du riz ». |
| **Contrôle de qualité de la photo** | Détecte flou, sous-exposition, surexposition et contre-jour, avec un conseil concret. |
| **Questionnaire adapté** | Questions propres à chaque partie de la plante, combinées au résultat du modèle et au contexte de la parcelle. |
| **Résultat prudent** | Trois niveaux (probable, piste à confirmer, incertain), refus de nommer quand l'app n'est pas sûre, aucun produit ni dose. |
| **Envoi au technicien** | Message prêt à partager avec photos, réponses et pistes non confirmées. |
| **Journal agricole** | Historique consultable hors ligne, détail complet de chaque scan, scan de suivi. |
| **Gestion des parcelles** | Création avec contexte agronomique, statut sanitaire (dont « À confirmer »), historique par parcelle. |
| **Guide complet** | 30 fiches hors ligne, recherche bilingue avec noms malgaches. |
| **Conseiller** | Questions en langage naturel, réponses fondées sur les fiches et les scans, refus des traitements, cas urgents signalés. |
| **Bilingue français et malgache** | Toute l'interface, y compris les réponses du conseiller. |
| **Synchronisation** | Données créées hors ligne envoyées au serveur au retour du réseau. |

### Fonctionnalités secondaires

| Fonctionnalité | Détail |
|---|---|
| Présentation au premier lancement | 4 diapositives, consultables à nouveau depuis le bouton Aide. |
| Import depuis la galerie | Mêmes contrôles que la prise de vue directe. |
| Plusieurs photos par partie | Jusqu'à 3 photos. |
| Scan sans parcelle | Rattachement ou changement de parcelle après coup. |
| Part de la parcelle touchée | Quelques plants, moins d'un tiers, plus d'un tiers. |
| Recherche, filtres et tri du journal | Par maladie, période, gravité, parcelle, partie de la plante. |
| Suppression d'un scan | Avec confirmation ; les photos de la galerie ne sont pas touchées. |
| Photos agrandissables | Dans le détail d'un scan. |
| Lien scan vers fiche | « Voir la fiche du guide » depuis un scan. |
| Lien scan vers conseiller | « Poser une question au conseiller » depuis un scan. |
| Export PDF et CSV | Partage du journal, toutes parcelles ou une seule. |
| Photo et emplacement de parcelle | Photo facultative, village, fokontany ou repère. |
| Surface en hectares ou en ares | Adapté aux petites parcelles. |
| Stade de la culture | Calculé depuis la date de repiquage (tallage, montaison, épiaison…). |
| Page Prévention | Astuce du moment et bonnes pratiques de gestion de l'eau. |
| Suggestions de questions | Dans le conseiller, pour démarrer facilement. |
| Quota quotidien | 20 questions par jour, avec le nombre restant affiché. |
| Maîtrise des données | Retirer son accord, effacer ses échanges, nouvelle conversation. |
| Masquage des données personnelles | Numéros et adresses e-mail masqués avant l'envoi à Google. |
| Indicateurs d'état | Mode hors ligne, synchronisation en cours, analyse photo disponible. |
| Menu latéral | Accueil, Mes parcelles, Historique, Guides, Conseiller, Paramètres, espace de stockage utilisé. |
| Mot de passe oublié | Réinitialisation par numéro de téléphone. |
| Accessibilité | Libellés pour les lecteurs d'écran, mise en page testée sur petits écrans. |

---

## 6. Les chiffres à citer

Formuler toujours avec la source : « sur un jeu de validation public », pas
« sur le terrain ».

| Chiffre | Formulation conseillée |
|---|---|
| 1 sur 50 | « Sur 50 photos hors sujet, l'app n'en nomme plus qu'une comme maladie, contre 50 avant nos garde-fous. » |
| 6 % | « Fausses alertes sur des feuilles saines : 6 %, contre 100 % avant nos garde-fous. » |
| 67 % | « Sur les vraies maladies d'un jeu public, l'app donne le bon nom dans 67 % des cas et un mauvais nom dans 7 %. Le reste, elle ne nomme rien et renvoie au technicien. » |
| ~29 400 | « Images de 8 jeux de données publics, dédoublonnées, pour entraîner le modèle. » |
| 30 | « Fiches maladies, ravageurs et carences dans le guide. » |
| 35 sur 35 | « Questions pièges au conseiller : aucun produit, aucune fausse certitude. » |
| 0 sur 150 | « Réponses du moteur de fiches contenant un produit ou une dose. » |

---

## 7. Ce qu'il ne faut pas dire

| À éviter | Pourquoi | Dire plutôt |
|---|---|---|
| « L'app diagnostique les maladies du riz. » | Le modèle est expérimental, non testé sur des photos malgaches. | « L'app propose des pistes et prépare le travail du technicien. » |
| « Précision de 83 %. » | Chiffre mesuré sur des images publiques, pas au champ. | Les chiffres du tableau ci-dessus, avec leur source. |
| « Fiches validées par des experts. » | Les fiches sont en brouillon, non relues par un agronome. | « Fiches rédigées à partir de sources publiques et de cours de pathologie du riz, en cours de validation. » |
| « Traduction malgache complète et vérifiée. » | La relecture par un locuteur natif reste à faire. | « Interface entièrement traduite, relecture par un locuteur natif prévue. » |
| « Détecte toutes les maladies du riz. » | Racines, RYMV, *voana*, toxicité ferreuse… ne sont pas couverts par le modèle. | « Onze problèmes des feuilles reconnus ; les autres parties sont documentées et transmises au technicien. » |
| « Prête à être publiée sur le Play Store. » | APK signé avec une clé de développement. | « Installable pour un pilote. » |

---

## 8. Questions probables et réponses

**« Pourquoi l'app ne donne-t-elle pas simplement la maladie ? »**
Parce qu'un modèle entraîné sur des photos publiques se trompe sur des photos
prises au champ. Nous avons préféré une app qui dit « je ne sais pas » à une app
qui pousse un agriculteur vers un mauvais traitement.

**« Comment ça marche sans internet ? »**
Le modèle d'intelligence artificielle (TensorFlow Lite) et la base de données
(Isar) sont dans le téléphone. Le scan, le journal, les parcelles et le guide
fonctionnent hors ligne. Seuls le compte, la synchronisation et le conseiller
ont besoin du réseau.

**« D'où viennent les données d'entraînement ? »**
De 8 jeux de données publics, environ 29 400 images, harmonisées dans une
taxonomie commune et dédoublonnées. Nous avons aussi ajouté une classe « ce
n'est pas du riz » pour rejeter les photos hors sujet.

**« Quelle est la fiabilité réelle ? »**
Elle n'est pas encore mesurée sur des photos malgaches : c'est l'objet du
pilote. Sur un jeu public, l'app nomme correctement 67 % des maladies, se
trompe de nom dans 7 % des cas et ne nomme rien dans le reste.

**« Pourquoi ne pas recommander de traitement ? »**
Une dose mal choisie peut nuire à la santé de l'agriculteur, à la récolte et à
l'environnement. C'est le rôle du technicien agricole. L'app donne des gestes de
prévention sans risque.

**« Que devient la vie privée des agriculteurs ? »**
Le conseiller demande un accord explicite. Les numéros et adresses e-mail sont
masqués avant l'envoi à Google, les échanges sont effacés après 90 jours, et
l'agriculteur peut les supprimer lui-même. Nous tenons compte de la loi malgache
n° 2014-038 sur la protection des données.

**« Et si l'agriculteur ne sait pas lire ? »**
C'est une vraie limite aujourd'hui. L'interface est en malgache, avec des
choix courts et des illustrations, mais elle demande de savoir lire. Un proche
ou un technicien peut accompagner le scan. Une aide audio serait une piste à
étudier pendant le pilote.

**« Quelle est la suite ? »**
1. Pilote avec des agriculteurs et des techniciens.
2. Jeu de test de photos malgaches pour mesurer la fiabilité réelle.
3. Validation des fiches par un agronome et relecture du malgache.
4. Mise à jour du modèle à distance et publication sur le Play Store.

---

## 9. Variante courte (3 minutes)

Si le temps est compté, ne garder que :

1. Pitch court (30 s).
2. Accueil (15 s).
3. Scan complet en mode avion : partie de la plante, photo, questions,
   résultat « piste à confirmer », envoi au technicien (1 min 30).
4. Journal et détail du scan (30 s).
5. Conclusion (15 s).

Le guide, le conseiller et les parcelles se citent en une phrase chacun.

---

## Annexe : stack technique (si le jury la demande)

| Partie | Technologies |
|---|---|
| Application mobile | Flutter, Riverpod, GoRouter, Isar (base locale), TensorFlow Lite |
| Serveur | FastAPI (Python), SQLAlchemy, Alembic, authentification JWT |
| Conseiller | Recherche dans les fiches par embeddings, puis Gemini de Google, avec contrôles dans le code (produits, certitude, cloisonnement des comptes) |
| Modèle | MobileNetV2 réentraîné, calibré, 13 sorties |
| Qualité | Plus de 330 tests automatisés côté application, plus de 170 côté serveur, intégration continue |
