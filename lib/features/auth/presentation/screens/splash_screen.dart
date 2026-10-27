import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../providers/session_provider.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bootstrapAsync = ref.watch(appBootstrapProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _SplashContent(bootstrapAsync: bootstrapAsync),
          ),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({required this.bootstrapAsync});

  final AsyncValue<AppBootstrapSnapshot> bootstrapAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: AppLocalizations.of(context).splashLogoSemantics,
          image: true,
          child: const _RicePlaceholder(),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _AgriMadaLogo(),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppLocalizations.of(context).splashSubtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        _SplashStatus(bootstrapAsync: bootstrapAsync),
      ],
    );
  }
}

class _SplashStatus extends StatelessWidget {
  const _SplashStatus({required this.bootstrapAsync});

  final AsyncValue<AppBootstrapSnapshot> bootstrapAsync;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.bodySmall.copyWith(
      color: AppColors.textSecondary,
    );

    return bootstrapAsync.when(
      loading: () => Text(AppLocalizations.of(context).splashStatusInitializing, style: style),
      error: (_, __) =>
          Text(AppLocalizations.of(context).splashStatusDegraded, style: style),
      data: (snapshot) {
        final loc = AppLocalizations.of(context);
        final mode = snapshot.isAiReady ? loc.splashStatusAiReady : loc.splashStatusAiUnavailable;
        final session =
            snapshot.isLoggedIn ? loc.splashStatusSessionActive : loc.splashStatusSessionGuest;
        return Text('$mode • $session', style: style);
      },
    );
  }
}

class _RicePlaceholder extends StatelessWidget {
  const _RicePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 237,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: const Icon(
        Icons.grass,
        size: 80,
        color: AppColors.primary,
      ),
    );
  }
}

class _AgriMadaLogo extends StatelessWidget {
  const _AgriMadaLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'AgriMada',
          style: AppTypography.brandTitle,
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
