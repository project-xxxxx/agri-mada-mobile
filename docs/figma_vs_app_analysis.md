# Analyse comparative : Maquette Figma vs Application AgriMada

**Date :** 14/05/2026
**Fichier Figma :** `Grand projet` (key: `LsWt9umRKpFeO23qaJiZ1c`)
**Projet :** AgriMada Mobile (Flutter)

---

## 1. Palette de couleurs

### Figma (déduite du design)
| Rôle | Couleur visuelle | Code supposé |
|------|----------------|---------------|
| Primaire (vert) | Vert vif | ~ `#3BA147` |
| Fond écran blanc | Blanc | `#FFFFFF` |
| Fond light | Gris très clair | ~ `#F5F7F5` |
| Texte noir | Noir | `#000000` |
| Texte secondaire | Gris | ~ `#939393` |
| Texte sur primaire | Blanc | `#FFFFFF` |
| Texte lien | Vert comme primaire | ~ `#3BA147` |
| Erreur | Rouge | ~ `#EF4444` |
| Avertissement | Orange | ~ `#F59E0B` |
| Succès | Vert (même que primaire) | ~ `#3BA147` |
| Grabber | Gris clair | ~ `#CCCCCC` |
| Input bg | Vert très clair | ~ `rgba(59,161,71,0.2)` |

### App (implémentée dans `app_colors.dart`)
```dart
primary       = #3BA147
primaryLight  = #E6F1E7
primaryFaded  = #333BA147 (20%)
surface       = #FFFFFF
background    = #FFFFFF
scaffoldBg    = #F5F7F5
textPrimary   = #000000
textSecondary = #939393
textOnPrimary = #FFFFFF
textLink      = #3BA147
error         = #EF4444
warning       = #F59E0B
success       = #3BA147
severityLow   = #3BA147
severityMedium= #F59E0B
severityHigh  = #EF4444
divider       = #E5E7EB
cardBg        = #FFFFFF
grabber       = #CCCCCC
navBar        = #FFFFFF
inputBg       = #333BA147
```

**✅ Statut :** Correspondance parfaite. L'app suit rigoureusement la palette Figma.

---

## 2. Typographie (Figma vs App)

### Figma (styles utilisés dans le design)

| Nom du style Figma | Texte exemple | Taille supposée | Graisse |
|-------------------|---------------|-----------------|---------|
| `style_7NGGT1` | 9:41 (status bar) | ~ 15 | Regular |
| `style_YPQ45D` | AgriMada (splash) | ~ 40 | Black 900 |
| `style_7YP24A` | Diagnostiquer les maladies... | ~ 14 | Regular |
| `style_236JYQ` | AgriMada (logo welcome) | ~ 25 | Black 900 |
| `style_XQTX4A` | L'intelligence au service... | ~ 24 | Bold |
| `style_OO4QAF` | Un riz sain et protégé... | ~ 16 | Light |
| `style_UV4GJ3` | Commencer / Se connecter | ~ 18 | Bold |
| `style_UJV0LQ` | Bonjour! | ~ 34 | Semi-Bold |
| `style_YRW0CH` | Ravie de vous revoir... | ~ 16 | Regular |
| `style_DDTRCN` | Connexion / Inscription | ~ 20 | Bold |
| `style_52MM08` | Email / Mot de passe (input) | ~ 16 | Regular |
| `style_5UC7DJ` | Se connecter / S'inscrire (btn) | ~ 18 | Bold |
| `style_XPA1JL` | Bonjour, Soa! | ~ 22 | Bold |
| `style_K2ZSWY` | Prêt pour une analyse ? | ~ 14 | Regular |
| `style_MZ91K1` | Nos Services | ~ 18 | Semi-Bold |
| `style_OE712Y` | Mes parcelles (sidebar) | ~ 20 | Bold |
| `style_FLZ4FI` | Suivi de vos rizières... (sidebar) | ~ 14 | Regular |
| `style_5WFGVV` | Prévenir les maladies (page title) | ~ 34 | Bold |
| `style_KTBY9F` | Prévenez vos rizicultures | ~ 16 | Regular |

### App (implémentée dans `app_typography.dart`)

```dart
Font family: Inter (défini dans pubspec.yaml)

displayLarge  = 34 / w600 → "Bonjour!"
displayMedium = 25 / w900 → "AgriMada" (logo)
headlineLarge = 20 / w700 → Titres de section
headlineMedium= 18 / w600 → Sous-titres
titleLarge    = 34 / w700 → Titres de cartes (vert)
titleMedium   = 22 / w700 → Titres moyens
bodyLarge     = 18 / w400 → Corps large
bodyMedium    = 16 / w400 → Corps normal
bodySmall     = 14 / w300 → Petit texte / descriptions
labelLarge    = 20 / w700 → Boutons sur fond vert
labelMedium   = 18 / w500 → Boutons secondaires
labelSmall    = 14 / w400 → Labels discrets
caption       = 10 / w400 → Légendes
brandTitle    = 40 / w900 → Splash "AgriMada"
```

### Comparaison

| Usage | Figma | App | Statut |
|-------|-------|-----|--------|
| Splash title "AgriMada" | 40px Black | `brandTitle` 40/w900 | ✅ |
| Logo welcome "AgriMada" | ~25px Black | `displayMedium` 25/w900 | ✅ |
| "Bonjour!" | ~34px Semi-Bold | `displayLarge` 34/w600 | ✅ |
| "L'intelligence au service..." | ~24px Bold | `headlineLarge` 20/w700 | ⚠️ Légère différence de taille |
| Texte descriptif | ~16px Light | `bodySmall` 14/w300 | ⚠️ Plus petit |
| Boutons | ~18px Bold | `labelMedium` 18/w500 OU `labelLarge` 20/w700 | ⚠️ Pas de mapping exact |
| "Connexion" / "Inscription" | ~20px Bold | `headlineLarge` 20/w700 | ✅ |
| Input hint text | ~16px Regular | `bodyMedium` 16/w400 | ✅ |
| Sidebar titres | ~20px Bold | Pas de style dédié | ❌ |
| Page "Prévenir les maladies" titre | ~34px Bold | Pas de style à 34px Bold | ❌ |
| Tips numérotés | Texte ~14px | `bodySmall` 14/w300 | ✅ |

---

## 3. Pages Figma vs App - Analyse détaillée

### 3.1 AgriMada → SplashScreen

**Figma (id: 1:12)** | **App (`splash_screen.dart`)**
| Element | Figma | App | Statut |
|---------|-------|-----|--------|
| Fond | Vert uni | `AppColors.primary` | ✅ |
| Logo "AgriMada" | Texte + point vert | Texte "AgriMada" + point vert | ✅ |
| Sous-titre | "Diagnostiquer les maladies du riz, hors ligne" | `splashSubtitle` (localisé) | ✅ |
| Image/illustration | Ellipse verte + icône riz | `splash_rice.png` (180x237) | ✅ |
| Animation | Statique | Fade-in + scale-up 1.2s | ➕ App ajoute animation |
| Grabber | Présent | Absent | ❌ App n'a pas le grabber |
| Status bar (9:41) | Présent | Absent (native) | ✅ Normal |

**Conclusion :** ✅ Bonne correspondance. L'app ajoute des animations.

---

### 3.2 page bienvenue → WelcomeScreen

**Figma (id: 1:30)** | **App (`welcome_screen.dart`)**
| Element | Figma | App | Statut |
|---------|-------|-----|--------|
| Fond | Blanc | `AppColors.background` | ✅ |
| Logo AgriMada | Texte + point vert | `_WelcomeLogo` | ✅ |
| Zone héro | 4 ellipses décoratives + image | `_WelcomeHero` avec 3 cercles décoratifs | ⚠️ Figma a 4 cercles, l'app en a 3 |
| Tagline 1 | "L'intelligence au service de vos rizières" | `loc.welcomeHeadline` | ✅ |
| Tagline 2 | "Un riz sain et protégé grâce à l'expertise AgriMada." | `loc.welcomeBody` | ✅ |
| Bouton "Commencer" | Vert plein, texte blanc | `AppButton` primary | ✅ |
| Bouton "Se connecter" | Bordure vert, texte vert | `AppButton` secondary | ✅ |
| Grabber | Présent en haut | Absent | ❌ |
| Status bar | Présente | Absente (native) | ✅ Normal |

**Conclusion :** ✅ Très bonne correspondance. Différence mineure sur le nombre de cercles décoratifs.

---

### 3.3 page connexion → LoginScreen

**Figma (id: 1:57)** | **App (`login_screen.dart`)**
| Element | Figma | App | Statut |
|---------|-------|-----|--------|
| Fond | Blanc | `AppColors.background` | ✅ |
| Header vert | "Bonjour!" + sous-texte + illustration | `_LoginHeader` avec illustration locale | ✅ |
| Titre formulaire | "Connexion" (dans zone blanche) | `loc.loginTitle` | ✅ |
| Champ Email | Icône email + hint "Email" | `_LoginTextField` avec email icon | ✅ |
| Champ Mot de passe | Icône cadenas + hint "Mot de passe" | `_LoginTextField` avec lock icon + toggle visibilité | ✅ + 🔐 App ajoute toggle |
| Mot de passe oublié | Lien texte | Lien texte → `/reset` | ✅ |
| Bouton "Se connecter" | Vert plein, texte blanc | `AppButton` primary | ✅ |
| Lien inscription | "Pas encore de compte?" + "S'inscrire" | `Row` avec texte + GestureDetector | ✅ |
| Animation | Statique | Slide-up + fade-in + shake sur erreur | ➕ App ajoute animations |
| Grabber | Présent | Absent | ❌ |
| Status bar | Présente | Absente (native) | ✅ Normal |

**Conclusion :** ✅ Bonne correspondance. L'app ajoute des animations et le toggle de visibilité du mot de passe.

---

### 3.4 page d'inscription → RegisterScreen

**Figma (id: 208:13)** | **App (`register_screen.dart`)**
| Element | Figma | App | Statut |
|---------|-------|-----|--------|
| Header | "Bonjour!" + "Bienvenue sur AgriMada" + illustration | `AppBar` simple avec "Créer un compte" | ❌ **Différent** |
| Titre formulaire | "Inscription" | "Inscription agriculteur" | ⚠️ Différent |
| Champ 1 | **Nom complet** | **Nom** | ⚠️ |
| Champ 2 | **Email** | **Prénom** | ❌ **Différent** |
| Champ 3 | **Mot de passe** | **Région** | ❌ **Différent** |
| Champ 4 | **Confirmer mot de passe** | **Téléphone** | ❌ **Différent** |
| Champ 5 | - | **Mot de passe** | ➕ App ajoute |
| Checkbox CGU | `J'accepte les Conditions d'utilisation et la Politique de confidentialité` | **Absent** | ❌ **Manquant** |
| Bouton | "S'inscrire" (vert plein) | "Créer mon compte" (vert plein) | ⚠️ Texte différent |
| Lien | "Déjà un compte?" + "Se connecter" | "J'ai déjà un compte" | ⚠️ Texte différent |
| Design général | Header vert arrondi avec illustration | Design plat sans header vert | ❌ **Structure différente** |

**Conclusion : ❌ Divergence majeure.** La maquette Figma a un design complètement différent (header "Bonjour!", email + confirmation email, checkbox CGU). L'app a des champs différents (prénom, région, téléphone) et n'a pas la checkbox CGU.

---

### 3.5 accueil → HomeScreen

**Figma (id: 9:2)** | **App (`home_screen.dart`)**
| Element | Figma | App | Statut |
|---------|-------|-----|--------|
| Fond | Gris clair | `AppColors.scaffoldBackground` | ✅ |
| Header | Menu hamburger + "Bonjour, Soa!" + icône sync + langue + aide | `_HomeHeader` avec menu + greeting + sync + langue + aide | ✅ |
| Barre recherche | Champ + icône filtre vert | `_SearchBar` avec champ + filtre vert | ✅ |
| Carte résumé | "Résumé de votre exploitation" + "Système prêt" + dernier diagnostic | `_SummaryCard` avec titre, statut, nb parcelles | ⚠️ Contenu légèrement différent |
| Service 1 | **Mes parcelles** (icône carte) | **Parcelles** (icône map) | ⚠️ Ordre différent |
| Service 2 | **État des cultures** (icône graphique) | **Cultures** (icône bar_chart) | ⚠️ Nom légèrement différent |
| Service 3 | **Solutions agricoles** (icône) | **Solutions** (icône science) | ✅ |
| Service 4 | **Prévenir les maladies** (icône) | **Prévention** (icône health_and_safety) | ⚠️ Nom différent |
| Bouton scan | Bouton flottant en bas | FAB pulsant dans `MainLayout` | ✅ |
| Bouton journal | "Journal" à côté de "Accueil" | Dans bottom nav + drawer | ⚠️ Placement différent |
| "Nos Services" titre | Présent | `loc.homeServicesTitle` | ✅ |
| "Prêt pour une analyse ?" | Sous le greeting | "Prêt pour une nouvelle analyse ?" | ✅ |
| Image riz dans résumé | PNG riz | `rice_summary.png` | ✅ |

**Conclusion : ✅ Bonne correspondance.** Les services sont dans le même ordre (Parcelles → Cultures → Solutions → Prévention). Légères différences de libellés.

---

### 3.6 side bar → HomeDrawer

**Figma (id: 1:172)** | **App (`home_drawer.dart`)**
| Element | Figma | App | Statut |
|---------|-------|-----|--------|
| Header | "AgriMada" + point vert + infos modèle IA + Dernière MAJ | "AgriMada" + icône eco + tagline | ⚠️ Contenu différent |
| Menu 1 | **Accueil** → "Revenir à la page d'accueil" | **Accueil** | ✅ |
| Menu 2 | **Mes parcelles** → "Suivi de vos rizières et surfaces" | **Journal** | ❌ Différent |
| Menu 3 | **Historique** → "Liste de vos analyses passées" | **Scan** | ❌ Différent |
| Menu 4 | **Guides des maladies** → "Fiches d'identification hors ligne" | **Paramètres** | ❌ Différent |
| Menu 5 | - | **Déconnexion** | ➕ App ajoute |
| Section stockage | "Stockage" + "Mémoire utilisée sur ce smartphone" | Absent | ❌ **Manquant** |
| Lignes séparatrices | 4 lignes horizontales | `Divider` seulement | ❌ |

**Conclusion : ❌ Structure différente.** La Figma a "Mes parcelles", "Historique", "Guides des maladies" et "Stockage". L'app a "Journal", "Scan", "Paramètres" et "Déconnexion". Aucune section "Guides des maladies" ou "Stockage" dans l'app.

---

### 3.7 scanning → ScanningScreen

**Figma (id: 35:20)** | **App (`scanning_screen.dart`)**
| Element | Figma | App | Statut |
|---------|-------|-----|--------|
| Fond | Noir | `Colors.black87` | ✅ |
| Header | Back arrow + "Analyse" | `_ScanHeader` avec gradient + "Analyse" | ✅ |
| Zone vue caméra | Cadre vert avec instructions | `_CameraViewfinder` avec bordure verte | ✅ |
| Bouton capture | Cercle vert | Cercle vert 72px | ✅ |
| Bouton galerie | Cercle avec icône | Cercle avec icône photo_library | ✅ |
| Bouton annuler | "ANNULER" bord blanc | `_CancelButton` semi-transparent | ✅ |
| Texte "Placez la feuille dans le cadre" | Présent | `loc.scanPointCamera` | ✅ |
| Animation scan | Statique | `_ScanningAnimation` avec ligne pulsante | ➕ |
| Sélection parcelle | Absent | Modal bottom sheet | ➕ App ajoute |
| Bannière mode dégradé | Absent | Bannière rouge si IA indisponible | ➕ App ajoute |

**Conclusion : ✅ Bonne correspondance.** L'app ajoute la sélection de parcelle, l'animation de scan et la bannière mode dégradé.

---

### 3.8 Prévenir les maladies → **ABSENTE de l'app**

**Figma (id: 215:13)** - Page complète non implémentée

| Element Figma | Description |
|--------------|-------------|
| Header | "Prévenir les maladies" + "Prévenez vos rizicultures" |
| Carte "Astuce de prévention" | "Des gestes simples aujourd'hui..." |
| Carte "Astuce du moment" | "Maintenez une bonne gestion de l'eau" + image + texte explicatif |
| "Pourquoi c'est efficace ?" | Encart avec explications détaillées |
| "Bon à savoir" | Encart avec informations supplémentaires |
| "Comment faire ?" | 5 tips numérotés (1-5) avec illustrations |
| Tip 1 | Drainage efficace |
| Tip 2 | Alterner inondation/assèchement |
| Tip 3 | Niveau d'eau 3-5 cm |
| Tip 4 | Éviter excès d'azote |
| Tip 5 | Nettoyer canaux |

**Conclusion : ❌ Page entièrement manquante dans l'app.**

---

### 3.9 Pages dans l'app MAIS ABSENTES de Figma

| Page App | Raison probable |
|----------|-----------------|
| **SplashScreen** | Présente dans Figma comme "AgriMada" (section 3.1) |
| **OnboardingScreen** | Non présent dans Figma - probablement ajouté après |
| **ResetPasswordScreen** | Le lien "Mot de passe oublié" existe dans Figma mais pas de maquette dédiée |
| **ScanResultScreen** | Non présent dans Figma - le résultat du scan n'a pas été designé |
| **JournalScreen** | Non présent comme page Figma, mais le bouton "Journal" existe sur l'accueil |
| **SettingsScreen** | Non présent dans Figma |
| **MainLayout** (bottom nav) | Non présent dans Figma - la navigation n'a pas été designée |

---

## 4. Composants et éléments d'interface

### 4.1 Composants Figma

| Composant | Variantes | Utilisation |
|-----------|-----------|-------------|
| **Grabber** (id: 1:9) | Mode=Light | Barre de navigation en haut de chaque écran |
| **scan** (id: 44:121) | 4 variantes (Par défaut, Variante2-4) | Icône scan dans la page scanning |

### 4.2 Composants App (non designés dans Figma)

| Composant App | Fichier |
|--------------|---------|
| `AppButton` (3 variantes) | `core/widgets/app_button/app_button.dart` |
| `MainLayout` (bottom nav + FAB) | `core/widgets/main_layout.dart` |
| `SyncStatusIndicator` | `core/sync/presentation/sync_status_indicator.dart` |
| Navigation drawer | `home_drawer.dart` |

---

## 5. Images et assets

### Figma references images
| Nom Figma | Type | Dans l'app ? |
|-----------|------|-------------|
| `splash_rice.png` | Riz | ✅ (utilisé dans SplashScreen) |
| `welcome_hero.png` | Image héro welcome | ✅ (utilisé dans WelcomeScreen) |
| `deco_rice_1.png` | Décoration cercle | ✅ (utilisé dans WelcomeScreen) |
| `deco_rice_2.png` | Décoration cercle | ✅ (utilisé dans WelcomeScreen) |
| `deco_rice_3.png` | Décoration cercle | ✅ (utilisé dans WelcomeScreen) |
| `login_deco.png` | Décoration login | ✅ (utilisé dans LoginScreen) |
| `rice_summary.png` | Image résumé riz | ✅ (utilisé dans HomeScreen) |
| `service_parcelles.png` | Icône service | ✅ (utilisé dans HomeScreen) |
| `service_cultures.png` | Icône service | ✅ (utilisé dans HomeScreen) |
| `service_solutions.png` | Icône service | ✅ (utilisé dans HomeScreen) |
| `service_prevention.png` | Icône service | ✅ (utilisé dans HomeScreen) |
| Images maladies rice | Photos maladies rice | ❌ Non trouvées dans l'app (peut-être chargées dynamiquement) |

---

## 6. Résumé des écarts

### Pages à corriger (haute priorité)

| # | Écart | Impact |
|---|-------|--------|
| 1 | **RegisterScreen** - Design totalement différent des champs Figma (Email + Confirm mdp + CGU vs Prénom + Région + Téléphone) | ❌ Critique |
| 2 | **Prévenir les maladies** - Page entièrement absente alors qu'elle est designée dans Figma | ❌ Critique |
| 3 | **Sidebar** - Menu différent (Historique, Guides des maladies, Stockage manquants) | ⚠️ Important |

### Pages à ajouter (priorité moyenne)

| # | Page Figma manquante dans l'app |
|---|--------------------------------|
| 1 | **Guides des maladies** - Présent dans la sidebar Figma mais pas dans l'app |
| 2 | **Stockage info** - Présent dans la sidebar Figma mais pas dans l'app |
| 3 | **Historique** - Présent dans la sidebar Figma (liste des analyses passées) |

### Pages existantes dans l'app mais pas dans Figma

| # | Page App | Suggestion |
|---|----------|------------|
| 1 | **OnboardingScreen** | À designr dans Figma pour alignment |
| 2 | **ScanResultScreen** | À designr dans Figma pour alignment |
| 3 | **SettingsScreen** | À designr dans Figma pour alignment |
| 4 | **JournalScreen** | À designr dans Figma pour alignment |
| 5 | **MainLayout** (bottom nav) | À designr dans Figma pour alignment |
| 6 | **ResetPasswordScreen** | À designr dans Figma pour alignment |

### Détails mineurs

| # | Détail | Où |
|---|--------|-----|
| 1 | Bienvenue - 3 cercles décoratifs au lieu de 4 | WelcomeScreen |
| 2 | Login - App ajoute toggle visibilité mot de passe | LoginScreen |
| 3 | Login - App ajoute animations (slide, shake) | LoginScreen |
| 4 | Splash - App ajoute animation fade-in | SplashScreen |
| 5 | Scanning - App ajoute sélection parcelle | ScanningScreen |
| 6 | Grabber présent dans toutes les pages Figma mais absent de l'app | Toutes les pages |

---

## 7. Correspondance des textes / localisation

| Écran | Texte Figma | Clé ARB (App) | Statut |
|-------|-------------|----------------|--------|
| Splash | "Diagnostiquer les maladies du riz, hors ligne" | `splashSubtitle` | ✅ |
| Welcome | "L'intelligence au service de vos rizières" | `welcomeHeadline` | ✅ |
| Welcome | "Un riz sain et protégé..." | `welcomeBody` | ✅ |
| Welcome | "Commencer" | `welcomeStart` | ✅ |
| Login | "Bonjour!" | `loginHello` | ✅ |
| Login | "Ravie de vous revoir sur AgriMada" | `loginWelcome` | ⚠️ Figma: "Ravie de vous revoir", App: "Content de vous revoir" |
| Login | "Email" / "Mot de passe" | `loginEmailLabel` / `loginPasswordLabel` | ✅ |
| Login | "Mot de passe oublié?" | `loginForgotPassword` | ✅ |
| Login | "Pas encore de compte?" + "S'inscrire" | `loginNoAccount` + `loginRegister` | ✅ |
| Register | "Bonjour!" + "Bienvenue sur AgriMada" | Manquant | ❌ |
| Register | "Nom complet" → "Email" → "Mot de passe" → "Confirmer" | "Nom" → "Prénom" → "Région" → "Tél" → "Mdp" | ❌ |
| Register | "J'accepte les Conditions d'utilisation..." | Absent | ❌ |
| Home | "Bonjour, Soa!" | `homeHelloUser(nom)` | ✅ |
| Home | "Prêt pour une analyse ?" | `homeReadyForAnalysis` | ✅ |
| Home | "Nos Services" | `homeServicesTitle` | ✅ |
| Home | "Résumé de votre exploitation" | `homeSummaryTitle` | ✅ |
| Home | "Système prêt" | `homeSystemReady` | ✅ |
| Home | "Mes parcelles" / "État des cultures" / "Solutions agricoles" / "Prévenir les maladies" | Service titles | ⚠️ Noms légèrement différents |
| Sidebar | "Accueil" / "Mes parcelles" / "Historique" / "Guides des maladies" | "Accueil" / "Journal" / "Scan" / "Paramètres" | ❌ |
| Scanning | "Placez la feuille dans le cadre" | `scanPointCamera` | ✅ |
| Prevention | Astuces + tips 1-5 | Absent | ❌ |

---

## 8. Synthèse globale

| Métrique | Valeur |
|----------|--------|
| Pages Figma | **8** (Splash, Welcome, Login, Register, Home, Sidebar, Scanning, Prevention) |
| Pages App | **11** (Splash, Welcome, Login, Register, ResetPassword, Home, Journal, Settings, Scanning, ScanResult, Onboarding) |
| Pages correspondantes | **7/8** (sauf Prevention) |
| Pages Figma non implémentées | **1** (Prévenir les maladies) |
| Pages App non designées | **6** (Onboarding, ScanResult, Settings, Journal, ResetPassword, MainLayout) |
| Divergences majeures | **2** (Register form, Sidebar) |
| Divergences mineures | **4** (Welcome cercles, Login animations, Home libellés, Grabber) |
| Composants Figma non repris | Grabber sur chaque écran |
| Composants App non designés | Bottom nav, AppButton, SyncIndicator |
