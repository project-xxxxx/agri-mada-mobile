import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/ai/disease_catalog.dart';
import '../../../../core/local_db/session_service.dart';
import '../../../../core/widgets/app_button/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/session_provider.dart';

/// Hauteur disponible sous laquelle la carte d'état du modèle est omise :
/// elle reste consultable dans l'en-tête du menu et sur l'écran de démarrage.
const double _minHeightForStatusCard = 680;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.consultationMode = false});

  final bool consultationMode;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  List<_OnboardingSlideData> _buildSlides(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return [
      _OnboardingSlideData(
        title: loc.onboardingSlide1Title,
        description: loc.onboardingSlide1Desc,
        icon: Icons.photo_camera_outlined,
      ),
      _OnboardingSlideData(
        title: loc.onboardingSlide2Title,
        description: loc.onboardingSlide2Desc,
        icon: Icons.psychology_outlined,
      ),
      _OnboardingSlideData(
        title: loc.onboardingSlide3Title,
        description: loc.onboardingSlide3Desc,
        icon: Icons.fact_check_outlined,
      ),
      _OnboardingSlideData(
        title: loc.onboardingSlide4Title,
        description: loc.onboardingSlide4Desc,
        icon: Icons.map_outlined,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _skip() async {
    if (!widget.consultationMode) {
      await SessionService.instance.setOnboardingDone(true);
      if (!mounted) return;
      final isLoggedIn = await SessionService.instance.isLoggedIn();
      if (!mounted) return;
      context.go(isLoggedIn ? AppRoutes.home : AppRoutes.welcome);
      return;
    }
    if (!mounted) return;
    context.pop();
  }

  Future<void> _next(int totalSlides) async {
    if (_currentIndex >= totalSlides - 1) {
      await _skip();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final bootstrap = ref.watch(appBootstrapProvider).valueOrNull;
    final slides = _buildSlides(context);
    final isLastSlide = _currentIndex == slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showStatus =
                constraints.maxHeight >= _minHeightForStatusCard;
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  _OnboardingTopBar(
                    consultationMode: widget.consultationMode,
                    onSkip: _skip,
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: slides.length,
                      onPageChanged: (index) =>
                          setState(() => _currentIndex = index),
                      itemBuilder: (context, index) =>
                          _OnboardingSlide(slide: slides[index]),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _OnboardingIndicator(
                    total: slides.length,
                    currentIndex: _currentIndex,
                  ),
                  if (showStatus) ...[
                    const SizedBox(height: AppSpacing.md),
                    _ModelStatusCard(bootstrap: bootstrap),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  if (!widget.consultationMode)
                    AppButton(
                      label: isLastSlide
                          ? loc.onboardingStart
                          : loc.onboardingNext,
                      onPressed: () => _next(slides.length),
                    )
                  else
                    AppButton(
                      label: loc.commonClose,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.pop(),
                    ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({
    required this.consultationMode,
    required this.onSkip,
  });

  final bool consultationMode;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            consultationMode ? loc.onboardingHelpTitle : loc.onboardingWelcome,
            style: AppTypography.headlineMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: onSkip,
          child: Text(
            consultationMode ? loc.commonClose : loc.onboardingSkip,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.slide});

  final _OnboardingSlideData slide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.primary.withAlpha(60), width: 1),
      ),
      // Le contenu défile au lieu de déborder sur les petits écrans (P1.10).
      child: LayoutBuilder(
        builder: (context, constraints) {
          final iconSize = constraints.maxHeight < 280 ? 56.0 : 90.0;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: math.max(0, constraints.maxHeight - 2 * AppSpacing.md),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(slide.icon, size: iconSize, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    slide.title,
                    style: AppTypography.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    slide.description,
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingIndicator extends StatelessWidget {
  const _OnboardingIndicator({
    required this.total,
    required this.currentIndex,
  });

  final int total;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

/// Version du modèle, maladies reconnues et disponibilité réelle de l'IA,
/// réunies dans une seule carte pour libérer de la hauteur.
class _ModelStatusCard extends StatelessWidget {
  const _ModelStatusCard({required this.bootstrap});

  final AppBootstrapSnapshot? bootstrap;

  @override
  Widget build(BuildContext context) {
    final snapshot = bootstrap;
    if (snapshot == null) return const SizedBox.shrink();

    final loc = AppLocalizations.of(context);
    final info = snapshot.modelVersion;
    final isAiReady = snapshot.isAiReady;
    final statusColor = isAiReady ? AppColors.primary : AppColors.warning;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.modelVersionTitle, style: AppTypography.bodyMedium),
          if (info != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'v${info.version} - ${info.date}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              loc.modelSupportedDiseases(
                info.maladiesSupportees
                    .map((label) => DiseaseCatalog.displayName(label, loc))
                    .join(', '),
              ),
              style: AppTypography.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                isAiReady ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                size: 16,
                color: statusColor,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  isAiReady ? loc.onboardingAiAvailable : loc.onboardingAiUnavailable,
                  style: AppTypography.bodySmall.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}
