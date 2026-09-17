import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/tflite_provider.dart';
import '../../../../core/sync/presentation/sync_status_indicator.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../auth/presentation/providers/session_provider.dart';
import '../../../journal/presentation/providers/journal_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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
                    _buildAnimatedItem(const _HomeHeader(), 0),
                    const SizedBox(height: AppSpacing.lg),
                    _buildAnimatedItem(const _SummaryCard(), 1),
                    const SizedBox(height: AppSpacing.md),
                    _buildAnimatedItem(const _ConseillerCard(), 2),
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
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);

    final menuButton = Semantics(
      button: true,
      label: loc.homeMenuSemantics,
      child: GestureDetector(
        onTap: () => openAppMenu(context),
        child: Container(
          width: 48,
          height: 48,
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
          child: const Icon(Icons.menu, color: AppColors.textPrimary, size: 22),
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

    const actions = _HomeHeaderActions();

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
              const Align(
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
            const Flexible(
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

class _HomeHeaderActions extends ConsumerWidget {
  const _HomeHeaderActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    // null tant que l'état du réseau est inconnu : pas de badge plutôt qu'un faux.
    final isOnline = ref.watch(isOnlineProvider).valueOrNull;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.end,
      children: [
        const SyncStatusIndicator(),
        if (isOnline == false)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 4),
              Text(
                loc.homeOfflineMode,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        PopupMenuButton<String>(
          initialValue: locale.languageCode,
          onSelected: (value) {
            ref.read(localeProvider.notifier).setLocale(Locale(value));
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'fr', child: Text('FR')),
            PopupMenuItem(value: 'mg', child: Text('MG')),
          ],
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
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
          ),
        ),
        Semantics(
          button: true,
          label: loc.homeHelpSemantics,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push('${AppRoutes.onboarding}?mode=help'),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
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
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Reflète l'état réel du modèle embarqué (tâche P1.10).
                  Consumer(
                    builder: (context, ref, _) {
                      final isAiReady = ref.watch(isTFLiteReadyProvider);
                      final color =
                          isAiReady ? AppColors.primary : AppColors.warning;
                      return Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              isAiReady
                                  ? loc.homeSystemReady
                                  : loc.homeSystemAiUnavailable,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall.copyWith(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Consumer(
                    builder: (context, ref, _) {
                      final journalAsync = ref.watch(journalAgricoleProvider);
                      final nb = journalAsync.valueOrNull?.length ?? 0;
                      return Text(
                        loc.homeRegisteredPlots(nb),
                        style: AppTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
            child: Container(
              width: 128,
              height: double.infinity,
              color: AppColors.primaryLight,
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Semantics(
                image: true,
                label: loc.homeIspmLogoSemantics,
                child: Image.asset(
                  'assets/images/logo_ispm.png',
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Accès au conseiller (ADR-012) : pleine largeur, pour ne pas déséquilibrer la grille.
class _ConseillerCard extends StatelessWidget {
  const _ConseillerCard();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        onTap: () => context.go(AppRoutes.conseiller),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              const Icon(Icons.forum_outlined, color: AppColors.primary, size: 36),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.agentHomeCardTitle,
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(loc.agentHomeCardDescription, style: AppTypography.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
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
          icon: Icons.map_outlined,
          onTap: () => context.go(AppRoutes.myParcelles),
        ),
        _ServiceCard(
          title: loc.homeServiceCropsTitle,
          description: loc.homeServiceCropsDescription,
          icon: Icons.bar_chart_outlined,
          onTap: () => context.go(AppRoutes.journal),
        ),
        _ServiceCard(
          title: loc.homeServiceSolutionsTitle,
          description: loc.homeServiceSolutionsDescription,
          icon: Icons.science_outlined,
          onTap: () => context.go(AppRoutes.guides),
        ),
        _ServiceCard(
          title: loc.homeServicePreventionTitle,
          description: loc.homeServicePreventionDescription,
          icon: Icons.health_and_safety_outlined,
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
    required this.icon,
    this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
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
            Icon(icon, color: AppColors.primary, size: 40),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
