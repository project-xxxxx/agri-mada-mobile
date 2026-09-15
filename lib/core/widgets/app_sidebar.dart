import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../ai/model_version_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Ouvre le menu de l'application.
///
/// Les écrans du shell (accueil, journal) ont leur propre Scaffold imbriqué
/// dans celui de MainLayout : on ouvre le tiroir du Scaffold le plus externe
/// qui en déclare un, pour qu'il recouvre aussi la barre de navigation.
void openAppMenu(BuildContext context) {
  ScaffoldState? target;
  context.visitAncestorElements((element) {
    if (element is StatefulElement) {
      final state = element.state;
      if (state is ScaffoldState && state.hasDrawer) target = state;
    }
    return true;
  });
  target?.openDrawer();
}

/// Menu latéral unique de l'application (remplace HomeDrawer et
/// AppSidebarOverlay, tâche P1.10). C'est un [Drawer] Material : les
/// ListTile disposent de l'ancêtre Material qui leur manquait.
class AppMenuDrawer extends ConsumerWidget {
  const AppMenuDrawer({super.key});

  void _navigate(BuildContext context, String route) {
    Scaffold.of(context).closeDrawer();
    context.go(route);
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    // Le tiroir est démonté une fois refermé : on garde le routeur avant l'attente.
    final router = GoRouter.of(context);
    Scaffold.of(context).closeDrawer();
    await ref.read(authNotifierProvider.notifier).logout();
    router.go(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            const _MenuHeader(),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _MenuItem(
                    icon: Icons.home_outlined,
                    title: loc.drawerHomeTitle,
                    subtitle: loc.drawerHomeSubtitle,
                    onTap: () => _navigate(context, AppRoutes.home),
                  ),
                  const _MenuDivider(),
                  _MenuItem(
                    icon: Icons.map_outlined,
                    title: loc.drawerPlotsTitle,
                    subtitle: loc.drawerPlotsSubtitle,
                    onTap: () => _navigate(context, AppRoutes.myParcelles),
                  ),
                  const _MenuDivider(),
                  _MenuItem(
                    icon: Icons.history,
                    title: loc.drawerHistoryTitle,
                    subtitle: loc.drawerHistorySubtitle,
                    onTap: () => _navigate(context, AppRoutes.journal),
                  ),
                  const _MenuDivider(),
                  _MenuItem(
                    icon: Icons.menu_book_outlined,
                    title: loc.drawerGuidesTitle,
                    subtitle: loc.drawerGuidesSubtitle,
                    onTap: () => _navigate(context, AppRoutes.guides),
                  ),
                  const _MenuDivider(),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    title: loc.drawerSettingsTitle,
                    subtitle: loc.drawerSettingsSubtitle,
                    onTap: () => _navigate(context, AppRoutes.settings),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout, color: AppColors.error, size: 20),
                ),
                title: Text(
                  loc.drawerLogout,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => _logout(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'AgriMada',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.textOnPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FutureBuilder<ModelVersionInfo>(
                  future: ModelVersionService.instance.load(),
                  builder: (context, snapshot) {
                    final date = snapshot.hasData ? snapshot.data!.date : '...';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.drawerLastUpdate(date),
                          style: const TextStyle(fontSize: 13, color: AppColors.textOnPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.drawerEmbeddedModel,
                          style: const TextStyle(fontSize: 13, color: AppColors.textOnPrimary),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.memory_outlined, color: AppColors.textOnPrimary, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, thickness: 1),
    );
  }
}
