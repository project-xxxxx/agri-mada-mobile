import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/ai/model_version_service.dart';
import '../../../../core/local_db/session_service.dart';
import '../../../../core/widgets/app_button/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/session_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.consultationMode = false});

  final bool consultationMode;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _slidesCount = 4;
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
    final bootstrapAsync = ref.watch(appBootstrapProvider);
    final bootstrap = bootstrapAsync.valueOrNull;
    final slides = _buildSlides(context);
    final isLastSlide = _currentIndex == slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              _OnboardingTopBar(
                consultationMode: widget.consultationMode,
                onSkip: _skip,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  itemCount: slides.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    final slide = slides[index];
                    return _OnboardingSlide(slide: slide);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _OnboardingIndicator(
                total: slides.length,
                total: slides.length,
                currentIndex: _currentIndex,
              ),
              const SizedBox(height: AppSpacing.md),
              _ModelVersionCard(),
              const SizedBox(height: AppSpacing.sm),
              _RuntimeStatusCard(bootstrap: bootstrap),
              const SizedBox(height: AppSpacing.lg),
              if (!widget.consultationMode)
                AppButton(
                  label: isLastSlide
                      ? loc.onboardingStart
                      : loc.onboardingNext,
                  onPressed: () => _next(slides.length),
                )
              else
                AppButton(
                  label: loc.onboardingClose,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.pop(),
                ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
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
        Text(
          consultationMode
              ? loc.onboardingHelpTitle
              : loc.onboardingWelcomeTitle,
          style: AppTypography.headlineMedium,
        ),
        const Spacer(),
        TextButton(
          onPressed: onSkip,
          child: Text(
            consultationMode ? loc.onboardingClose : loc.onboardingSkip,
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
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border:
                  Border.all(color: AppColors.primary.withAlpha(60), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(slide.icon, size: 90, color: AppColors.primary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  slide.title,
                  style: AppTypography.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    slide.description,
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

class _ModelVersionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return FutureBuilder<ModelVersionInfo>(
      future: ModelVersionService.instance.load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final info = snapshot.data!;
        final maladies = info.maladiesSupportees.join(', ');

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
              const Text('Version du modèle IA', style: AppTypography.bodyMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'v${info.version} - ${info.date}',
                style:
                    AppTypography.bodySmall.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                loc.onboardingSupportedDiseases(maladies),
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RuntimeStatusCard extends StatelessWidget {
  const _RuntimeStatusCard({required this.bootstrap});

  final AppBootstrapSnapshot? bootstrap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAiReady = bootstrap?.isAiReady ?? false;
    final modelVersion = bootstrap?.modelVersion?.version;

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
          const Text('Statut de l\'application', style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isAiReady ? loc.onboardingAiAvailable : loc.onboardingAiUnavailable,
            style: AppTypography.bodySmall,
          ),
          if (modelVersion != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              loc.onboardingActiveVersion(modelVersion),
              style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
            ),
          ],
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
