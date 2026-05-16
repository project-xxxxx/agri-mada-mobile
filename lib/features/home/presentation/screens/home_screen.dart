import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/sync/presentation/sync_status_indicator.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../auth/presentation/providers/session_provider.dart';
import '../../../journal/presentation/providers/journal_provider.dart';
import '../../../../core/sync/providers/sync_provider.dart';
import 'home_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem(Widget child, int index) {
    final animation =
        Tween<Offset>(begin: const Offset(0, 30), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          (index * 0.1).clamp(0.0, 1.0),
          (index * 0.1 + 0.6).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          (index * 0.1).clamp(0.0, 1.0),
          (index * 0.1 + 0.6).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: animation.value,
        child: Opacity(opacity: fadeAnimation.value, child: child),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const HomeDrawer(),
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnimatedItem(
                        _HomeHeader(
                          onMenuTap: () =>
                              _scaffoldKey.currentState?.openDrawer(),
                        ),
                        0),
                    const SizedBox(height: AppSpacing.md),
                    _buildAnimatedItem(const _SearchBar(), 1),
                    const SizedBox(height: AppSpacing.lg),
                    _buildAnimatedItem(const _SummaryCard(), 2),
                    const SizedBox(height: AppSpacing.lg),
                    _buildAnimatedItem(
                        Text(
                          loc.homeServicesTitle,
                          style: AppTypography.headlineMedium,
                        ),
                        3),
                    const SizedBox(height: AppSpacing.md),
                    _buildAnimatedItem(const _ServicesGrid(), 4),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final syncState = ref.watch(syncNotifierProvider);
    final locale = ref.watch(localeProvider);

    final menuButton = Semantics(
      button: true,
      label: loc.homeMenuSemantics,
      child: GestureDetector(
        onTap: onMenuTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.menu, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );

    final greeting = Consumer(
      builder: (context, ref, _) {
        final sessionAsync = ref.watch(sessionProvider);
        final prenom =
            sessionAsync.valueOrNull?['prenom'] ?? loc.homeFarmerDefault;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.homeHelloUser(prenom),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              loc.homeReadyForAnalysis,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        );
      },
    );

    final actions = _HomeHeaderActions(
      syncState: syncState,
      locale: locale,
      offlineLabel: loc.homeOfflineMode,
      onLocaleSelected: (value) {
        ref.read(localeProvider.notifier).setLocale(Locale(value));
      },
      onHelpTap: () => context.go('${AppRoutes.onboarding}?mode=help'),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 390;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  menuButton,
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: greeting),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerRight,
                child: actions,
              ),
            ],
          );
        }

        return Row(
          children: [
            menuButton,
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: greeting),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: actions,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HomeHeaderActions extends StatelessWidget {
  const _HomeHeaderActions({
    required this.syncState,
    required this.locale,
    required this.offlineLabel,
    required this.onLocaleSelected,
    required this.onHelpTap,
  });

  final SyncState syncState;
  final Locale locale;
  final String offlineLabel;
  final ValueChanged<String> onLocaleSelected;
  final VoidCallback onHelpTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SyncStatusIndicator(),
            if (syncState is! SyncIdle) const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.wifi_off, color: AppColors.primary, size: 18),
            const SizedBox(width: 4),
            Text(
              offlineLabel,
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        PopupMenuButton<String>(
          initialValue: locale.languageCode,
          onSelected: onLocaleSelected,
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'fr', child: Text('FR')),
            PopupMenuItem(value: 'mg', child: Text('MG')),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Text(
              locale.languageCode.toUpperCase(),
              style: AppTypography.caption.copyWith(color: AppColors.primary),
            ),
          ),
        ),
        Semantics(
          button: true,
          label: 'Aide',
          child: GestureDetector(
            onTap: onHelpTap,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              alignment: Alignment.center,
              child: Text(
                '?',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 49,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.md),
                const Icon(Icons.search,
                    color: AppColors.textSecondary, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    loc.homeSearchPlaceholder,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          height: 49,
          width: 49,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(50),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.tune, color: AppColors.textOnPrimary),
            onPressed: () {
              // Action pour le filtre (Nom, Culture, Date)
            },
            tooltip: 'Filtre',
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      height: 171,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.homeSummaryTitle,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        loc.homeSystemReady,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Consumer(
                    builder: (context, ref, _) {
                      final journalAsync = ref.watch(journalAgricoleProvider);
                      final nb = journalAsync.valueOrNull?.length ?? 0;
                      return Text(
                        loc.homeRegisteredPlots(nb),
                        style: AppTypography.bodySmall,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(AppSpacing.cardRadius),
              bottomRight: Radius.circular(AppSpacing.cardRadius),
            ),
            child: Image.asset(
              'assets/images/rice_summary.png',
              width: 128,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 128,
                height: 140,
                color: AppColors.primaryLight,
                child:
                    const Icon(Icons.grass, color: AppColors.primary, size: 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio:
          AppSpacing.serviceCardWidth / AppSpacing.serviceCardHeight,
      children: [
        _ServiceCard(
          title: loc.homeServicePlotsTitle,
          description: loc.homeServicePlotsDescription,
          iconPath: 'assets/images/service_parcelles.png',
          iconFallback: Icons.map_outlined,
          onTap: () => context.go(AppRoutes.journal),
        ),
        _ServiceCard(
          title: loc.homeServiceCropsTitle,
          description: loc.homeServiceCropsDescription,
          iconPath: 'assets/images/service_cultures.png',
          iconFallback: Icons.bar_chart_outlined,
          onTap: () => context.go(AppRoutes.scanning),
        ),
        _ServiceCard(
          title: loc.homeServiceSolutionsTitle,
          description: loc.homeServiceSolutionsDescription,
          iconPath: 'assets/images/service_solutions.png',
          iconFallback: Icons.science_outlined,
          onTap: () => context.go(AppRoutes.guides),
        ),
        _ServiceCard(
          title: loc.homeServicePreventionTitle,
          description: loc.homeServicePreventionDescription,
          iconPath: 'assets/images/service_prevention.png',
          iconFallback: Icons.health_and_safety_outlined,
          onTap: () => context.go(AppRoutes.prevention),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.title,
    required this.description,
    required this.iconPath,
    required this.iconFallback,
    this.onTap,
  });

  final String title;
  final String description;
  final String iconPath;
  final IconData iconFallback;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              iconPath,
              width: 64,
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                iconFallback,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: Text(
                description,
                style: AppTypography.caption,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
