import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ai/model_version_service.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

final sidebarControllerProvider = StateProvider<bool>((ref) => false);

class AppSidebarOverlay extends ConsumerWidget {
  const AppSidebarOverlay({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(sidebarControllerProvider);

    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: isOpen
              ? BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: AbsorbPointer(absorbing: true, child: child),
                )
              : child,
        ),
        if (isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => ref.read(sidebarControllerProvider.notifier).state = false,
              child: Container(color: Colors.black.withAlpha(100)),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          left: isOpen ? 0 : -300,
          top: 0,
          bottom: 0,
          width: 300,
          child: const _SidebarContent(),
        ),
      ],
    );
  }
}

class _SidebarContent extends ConsumerWidget {
  const _SidebarContent();

  void _navigate(BuildContext context, String route, WidgetRef ref) {
    ref.read(sidebarControllerProvider.notifier).state = false;
    context.go(route);
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    ref.read(sidebarControllerProvider.notifier).state = false;
    await ref.read(authNotifierProvider.notifier).logout();
    if (context.mounted) context.go(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            _SidebarHeader(),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _SidebarMenuItem(
                    icon: Icons.home_outlined,
                    title: AppLocalizations.of(context).drawerHomeTitle,
                    subtitle: AppLocalizations.of(context).drawerHomeSubtitle,
                    onTap: () => _navigate(context, AppRoutes.home, ref),
                  ),
                  const _SidebarMenuDivider(),
                  _SidebarMenuItem(
                    icon: Icons.map_outlined,
                    title: AppLocalizations.of(context).drawerPlotsTitle,
                    subtitle: AppLocalizations.of(context).drawerPlotsSubtitle,
                    onTap: () => _navigate(context, AppRoutes.myParcelles, ref),
                  ),
                  const _SidebarMenuDivider(),
                  _SidebarMenuItem(
                    icon: Icons.search_outlined,
                    title: AppLocalizations.of(context).drawerHistoryTitle,
                    subtitle: AppLocalizations.of(context).drawerHistorySubtitle,
                    onTap: () => _navigate(context, AppRoutes.journal, ref),
                  ),
                  const _SidebarMenuDivider(),
                  _SidebarMenuItem(
                    icon: Icons.menu_book_outlined,
                    title: 'Guides des maladies',
                    subtitle: 'Fiches d\'identification hors ligne',
                    onTap: () => _navigate(context, AppRoutes.guides, ref),
                  ),
                  const _SidebarMenuDivider(),
                  _SidebarMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Paramètres',
                    subtitle: 'Langue et préférences',
                    onTap: () => _navigate(context, AppRoutes.settings, ref),
                  ),
                  const _SidebarMenuDivider(),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context).drawerStorage,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(AppLocalizations.of(context).drawerMemoryUsed,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
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
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.logout, color: AppColors.error, size: 20),
                ),
                title: Text(AppLocalizations.of(context).drawerLogout,
                    style: const TextStyle(fontSize: 16, color: AppColors.error, fontWeight: FontWeight.w500)),
                onTap: () => _logout(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('AgriMada', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textOnPrimary)),
              const SizedBox(width: 6),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.textOnPrimary, shape: BoxShape.circle)),
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
                        Text(AppLocalizations.of(context).drawerLastUpdate(date),
                            style: const TextStyle(fontSize: 13, color: AppColors.textOnPrimary)),
                        const SizedBox(height: 2),
                        Text(AppLocalizations.of(context).drawerEmbeddedModel,
                            style: const TextStyle(fontSize: 13, color: AppColors.textOnPrimary)),
                      ],
                    );
                  },
                ),
              ),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.textOnPrimary.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.memory_outlined, color: AppColors.textOnPrimary, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SidebarMenuItem extends StatelessWidget {
  const _SidebarMenuItem({required this.icon, required this.title, required this.subtitle, required this.onTap});
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
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}

class _SidebarMenuDivider extends StatelessWidget {
  const _SidebarMenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(height: 1, thickness: 1));
  }
}
