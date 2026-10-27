# Audit de design — AgriMada

Date: 2026-05-14
Auteur: GitHub Copilot (assistant)

## Résumé
Ce rapport recense l'état actuel des écrans Flutter du projet, identifie les écarts majeurs par rapport au design Figma fourni et propose priorités + estimations d'effort pour aligner l'app sur les designs.

**Figma source utilisée:** https://www.figma.com/design/LsWt9umRKpFeO23qaJiZ1c/Grand-projet (node 1:12)

## Inventaire des écrans (présents dans le code)
- `lib/features/auth/presentation/screens/splash_screen.dart` — MAPPED to Figma (splash)
- `lib/features/auth/presentation/screens/welcome_screen.dart` — NOT MAPPED
- `lib/features/auth/presentation/screens/login_screen.dart` — NOT MAPPED
- `lib/features/auth/presentation/screens/register_screen.dart` — NOT MAPPED
- `lib/features/auth/presentation/screens/reset_password_screen.dart` — NOT MAPPED
- `lib/features/home/presentation/screens/home_screen.dart` — NOT MAPPED
- `lib/features/home/presentation/screens/settings_screen.dart` — NOT MAPPED
- `lib/features/home/presentation/screens/home_drawer.dart` — NOT MAPPED
- `lib/features/scan/presentation/screens/scanning_screen.dart` — NOT MAPPED
- `lib/features/scan/presentation/screens/scan_result_screen.dart` — NOT MAPPED
- `lib/features/journal/presentation/screens/journal_screen.dart` — NOT MAPPED
- `lib/features/onboarding/presentation/screens/onboarding_screen.dart` — NOT MAPPED

> Observations: seul l'écran `Splash` était présent dans le Figma que j'ai chargé (node `1:12`). Pour les autres pages, il faudra soit pointer vers d'autres frames Figma, soit définir les designs manquants.

## Audit détaillé — `Splash` (priorité haute)
Chemin: `lib/features/auth/presentation/screens/splash_screen.dart`

Écarts identifiés:
- Couleur de fond:
  - Figma: fond vert (`#3BA147`) sur tout l'écran.
  - Code: `Scaffold(backgroundColor: AppColors.background)` où `AppColors.background == 0xFFFFFFFF` (blanc). Divergence majeure.
- Typographie:
  - Figma: `AgriMada` utilise font `Inter` (Black, ~40px) en blanc.
  - Code: `AppTypography` global utilise `Poppins` (displayMedium etc.). Il y a une incohérence de famille et poids.
- Couleurs & tokens:
  - `AppColors.primary` == `0xFF3BA147` — OK (correspond au vert Figma).
  - `AppSpacing` existe et est global — bon point.
- Images / assets:
  - Figma fournit des images assets (4 URLs), le code utilise `assets/images/splash_rice.png` local. Vérifier que l'asset local est la version exacte du design. Les assets Figma fournis expirent au bout de 7 jours si vous souhaitez les télécharger via leurs URLs.
- Accessibilité / Semantics:
  - Le `Splash` n'expose pas de `Semantics` sur le logo/texte (ajouter `Semantics(label: ..., image: true)` si nécessaire).

Remédiation recommandée (actions concrètes):
1. Changer `Scaffold.backgroundColor` en `AppColors.primary` ou ajouter `AppColors.scaffoldBackgroundOnPrimary` si vous voulez conserver une distinction.
2. Ajouter/fixer la famille de polices: importer `Inter` (ou mapper Inter → Poppins si contrainte) et ajouter un token `AppTypography.displayBrand` correspondant au style `Inter Black 40px` en blanc.
3. Vérifier l'asset `assets/images/splash_rice.png` — remplacer par l'asset exporté de Figma si nécessaire.
4. Ajouter `Semantics` autour du logo et du titre.
5. Ajouter test widget co-localisé `lib/features/auth/presentation/screens/splash_screen_test.dart` validant rendu et textes.

Estimation effort: 1.5–3 heures (incluant export d'assets, mise à jour thème et test widget).

## Audit rapide — autres écrans (priorité & estimation)
- `Welcome`, `Login`, `Register`, `ResetPassword` — Priorité: Moyenne. Effort estimé: 3–6h pour chaque écran (vérifier grilles, champs, états, erreurs, focus, contrastes). Nécessite frames Figma.
- `Home` (incl. `home_drawer`) — Priorité: Haute (UX principal). Effort estimé: 6–12h (réconcilier layout, barres, navigation, responsive).
- `Scanning`, `Scan Result` — Priorité: Haute (fonctionnalité clé). Effort estimé: 4–8h par écran (assurer état loading, erreurs, résultats, correspondance visuelle).
- `Journal` — Priorité: Moyenne. Effort estimé: 3–6h.
- `Onboarding` — Priorité: Moyenne-Haute. Effort estimé: 4–8h (incl. animations et états consultatifs).

> Ces estimations sont approximatives et supposent que les designs Figma détaillés existent pour chaque écran. Si les designs manquent, ajouter 2–6h par écran pour la phase de design ou clarifications.

## Recommandations / Plan d'action proposé
1. Extraire tokens depuis Figma (variables couleurs, typographie, espacements, radius). (Action immédiate)
2. Mettre à jour `lib/app/theme/*` (`AppColors`, `AppSpacing`, `AppTypography`) pour refléter les tokens. (Critique)
3. Corriger d'abord `Splash` + `Home` + `Scanning` (ordre de priorité). Valider par tests widget.
4. Propager corrections aux autres écrans; ajouter `Semantics` accessibles partout.
5. Normaliser les assets: stocker `assets/images/` version design exportée, ajouter le pipeline d'optimisation (png/webp) si souhaité.
6. Mettre en place une petite suite de tests (widget tests + provider tests) pour chaque écran modifié.

## Pièces jointes utiles
- Figma node utilisé: `LsWt9umRKpFeO23qaJiZ1c` (node `1:12`).
- Assets temporaires fournis par MCP (valables 7 jours):
  - `https://www.figma.com/api/mcp/asset/c5120c8a-a37a-426f-9e3c-5759c740a049`
  - `https://www.figma.com/api/mcp/asset/01822ec7-ce47-497b-bd22-0c82e5c576bd`
  - `https://www.figma.com/api/mcp/asset/408a6b1f-0899-4d82-b705-508f3664132f`
  - `https://www.figma.com/api/mcp/asset/3d4f07aa-6c0e-4802-a1de-3721a889f367`

## Prochaine étape recommandée immédiate
Confirmez si je dois :
- (1) Extraire maintenant les tokens Figma et générer un patch `lib/app/theme/*` (je peux appliquer automatiquement)
- (2) Commencer par corriger `Splash` seulement et ouvrir une PR (itération rapide)
- (3) Produire un rapport plus détaillé écran-par-écran (si vous fournissez les frames Figma manquantes)

---

Si vous voulez, je peux appliquer maintenant la correction du `Splash` (Option: BATCH change), ou commencer par récupérer tous les tokens depuis Figma et préparer un patch centralisé.
