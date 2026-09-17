import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agri_mada/app/router.dart';
import 'package:agri_mada/l10n/app_localizations.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import 'app_sidebar.dart';

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const AppMenuDrawer(),
      body: child,
      floatingActionButton: _PulsatingScanFab(onTap: () => context.go(AppRoutes.scanOrgane)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const _AppBottomNav(),
    );
  }
}

class _PulsatingScanFab extends StatefulWidget {
  const _PulsatingScanFab({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_PulsatingScanFab> createState() => _PulsatingScanFabState();
}

class _PulsatingScanFabState extends State<_PulsatingScanFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Quelques pulsations pour attirer l'œil, puis arrêt : une animation
    // infinie use la batterie des téléphones d'entrée de gamme.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true, count: 3);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: loc.homeScanPlantSemantics,
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(100),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              color: AppColors.textOnPrimary,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBottomNav extends StatelessWidget {
  const _AppBottomNav();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final isHome = location == AppRoutes.home;
    final isJournal = location == AppRoutes.journal;

    return BottomAppBar(
      height: 75,
      color: AppColors.navBar,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: loc.homeTabHome,
            isSelected: isHome,
            onTap: () => context.go(AppRoutes.home),
          ),
          const SizedBox(width: 48),
          _NavItem(
            icon: Icons.book_outlined,
            activeIcon: Icons.book,
            label: loc.homeTabJournal,
            isSelected: isJournal,
            onTap: () => context.go(AppRoutes.journal),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 64, minHeight: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelected ? activeIcon : icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
