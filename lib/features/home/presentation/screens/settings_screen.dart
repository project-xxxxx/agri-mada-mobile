import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_button/app_button.dart';
import '../../../auth/presentation/providers/session_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(sessionServiceProvider).clearSession();
    if (!context.mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(sessionProvider);
    final locale = ref.watch(localeProvider);

    final profile = profileAsync.valueOrNull ?? const <String, String?>{};
    final prenom = profile['prenom'] ?? 'Utilisateur';
    final nom = profile['nom'] ?? '';
    final tel = profile['tel'] ?? '';
    final region = profile['region'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        title: Text(AppLocalizations.of(context).settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$prenom $nom'.trim(), style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                      tel.isEmpty
                          ? AppLocalizations.of(context).settingsPhoneUnavailable
                          : tel,
                      style: AppTypography.bodyMedium),
                  Text(
                      region.isEmpty
                          ? AppLocalizations.of(context).settingsRegionUnavailable
                          : region,
                      style: AppTypography.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(AppLocalizations.of(context).settingsLanguage),
              subtitle: Text(locale.languageCode.toUpperCase()),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'fr', child: Text('FR')),
                  PopupMenuItem(value: 'mg', child: Text('MG')),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: AppLocalizations.of(context).settingsLogout,
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }
}
