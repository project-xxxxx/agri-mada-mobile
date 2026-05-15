import 'package:agri_mada/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_button/app_button.dart';
import '../providers/session_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final bootstrapAsync = ref.watch(appBootstrapProvider);
    final snapshot = bootstrapAsync.valueOrNull;
    final prenom = snapshot?.profile['prenom'];
    final modelVersion = snapshot?.modelVersion?.version;
    final iaStatus = snapshot?.isAiReady == true
        ? loc.welcomeAiReady
        : loc.welcomeAiUnavailable;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      const _WelcomeLogo(),
                      const SizedBox(height: AppSpacing.xl),
                      const _WelcomeHero(),
                      const SizedBox(height: AppSpacing.xl),
                      _WelcomeTexts(),
                      if (prenom != null && prenom.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Text(
                            loc.welcomeGreeting(prenom),
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          modelVersion == null
                              ? iaStatus
                              : loc.welcomeAiModelStatus(
                                  iaStatus, modelVersion),
                          style: AppTypography.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _WelcomeActions(
                        onStart: () => context.go(
                          snapshot?.isLoggedIn == true
                              ? AppRoutes.home
                              : AppRoutes.login,
                        ),
                        onLogin: () => context.go(AppRoutes.login),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WelcomeLogo extends StatelessWidget {
  const _WelcomeLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'AgriMada',
          style: AppTypography.displayMedium,
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 269,
      width: 269,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 269,
            height: 269,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/welcome_hero.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primaryLight,
                  child: const Icon(
                    Icons.person,
                    size: 120,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            top: -10,
            right: -10,
            child: _DecorativeCircle(
              size: 38,
              imagePath: 'assets/images/deco_rice_1.png',
            ),
          ),
          const Positioned(
            bottom: -20,
            left: -20,
            child: _DecorativeCircle(
              size: 46,
              imagePath: 'assets/images/deco_rice_2.png',
            ),
          ),
          const Positioned(
            bottom: 10,
            right: -10,
            child: _DecorativeCircle(
              size: 28,
              imagePath: 'assets/images/deco_rice_3.png',
            ),
          ),
          const Positioned(
            top: 30,
            left: -15,
            child: _DecorativeCircle(
              size: 32,
              imagePath: 'assets/images/deco_rice_4.png',
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({
    required this.size,
    required this.imagePath,
  });

  final double size;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryLight,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.primaryLight,
          ),
        ),
      ),
    );
  }
}

class _WelcomeTexts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          loc.welcomeHeadline,
          style: AppTypography.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          loc.welcomeBody,
          style: AppTypography.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions({
    required this.onStart,
    required this.onLogin,
  });

  final VoidCallback onStart;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(
      children: [
        AppButton(
          label: loc.welcomeStart,
          onPressed: onStart,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: loc.loginSubmit,
          onPressed: onLogin,
          variant: AppButtonVariant.secondary,
        ),
      ],
    );
  }
}
