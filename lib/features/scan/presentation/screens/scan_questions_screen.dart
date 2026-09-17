// Questions posées après les photos d'un organe (tâche P2).
//
// Deux à quatre questions, toujours avec « Je ne sais pas » : personne n'est
// obligé d'inventer une réponse.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/questionnaire.dart';
import '../organ_labels.dart';
import '../providers/session_scan_provider.dart';

class ScanQuestionsScreen extends ConsumerWidget {
  const ScanQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final etat = ref.watch(scanSessionProvider);
    final organe = etat.organe;

    if (organe == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppRoutes.scanOrgane);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final questions = ScanQuestionnaire.pour(organe);
    final reponses = etat.reponsesDe(organe);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.scanQuestionsTitle, style: AppTypography.headlineMedium),
            Text(
              organeLabelBilingue(organe, loc),
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: loc.scanRetakePhoto,
          onPressed: () => context.go(AppRoutes.scanCapture),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            loc.scanQuestionsHelp,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final question in questions) ...[
            Text(
              question.prompt(loc),
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            RadioGroup<String>(
              groupValue: reponses[question.id],
              onChanged: (valeur) {
                if (valeur != null) {
                  ref.read(scanSessionProvider.notifier).repondre(question.id, valeur);
                }
              },
              child: Column(
                children: [
                  for (final option in question.options)
                    RadioListTile<String>(
                      value: option.id,
                      title: Text(option.label(loc), style: AppTypography.bodySmall),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      activeColor: AppColors.primary,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          ElevatedButton.icon(
            onPressed: etat.enCours
                ? null
                : () async {
                    await ref.read(scanSessionProvider.notifier).validerQuestions();
                    if (!context.mounted) return;
                    final suite = ref.read(scanSessionProvider).etape;
                    context.go(
                      suite == EtapeScan.resultat
                          ? AppRoutes.scanSessionResult
                          : AppRoutes.scanCapture,
                    );
                  },
            icon: const Icon(Icons.arrow_forward),
            label: Text(loc.scanCaptureContinue),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
