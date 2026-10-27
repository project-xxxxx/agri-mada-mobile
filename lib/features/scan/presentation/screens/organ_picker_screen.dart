// Étape « Qu'observez-vous ? » (tâche P2.1).
//
// Sept choix : les six organes, plus « Je ne sais pas » qui lance la séquence
// guidée parcelle → feuille → collet.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../journal/domain/entities/contexte_parcelle.dart';
import '../../../journal/presentation/providers/journal_provider.dart';
import '../../domain/entities/organe.dart';
import '../organ_labels.dart';
import '../providers/session_scan_provider.dart';

class OrganPickerScreen extends ConsumerWidget {
  const OrganPickerScreen({super.key, this.parcelleLocalId});

  final int? parcelleLocalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);

    Future<void> demarrer({Organe? organe, bool guidee = false}) async {
      // Le contexte de la parcelle suit la session : il aide le technicien et,
      // plus tard, l'a priori de la fusion (tâches P2.4 et P2.5).
      final parcelle = parcelleLocalId == null
          ? null
          : await ref.read(parcelleRepositoryProvider).getParcelleById(parcelleLocalId!);

      await ref.read(scanSessionProvider.notifier).demarrer(
            organe: organe,
            guidee: guidee,
            parcelleLocalId: parcelleLocalId,
            ecosysteme: parcelle?.ecosysteme,
            stade: stadeDepuisRepiquage(parcelle?.dateRepiquage)?.code,
          );
      if (context.mounted) context.go(AppRoutes.scanCapture);
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(loc.scanOrganTitle, style: AppTypography.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: loc.commonCancel,
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(loc.scanOrganHelp, style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          _Notice(texte: loc.scanOrganModelNotice, icone: Icons.science_outlined),
          if (parcelleLocalId == null) ...[
            const SizedBox(height: AppSpacing.xs),
            _Notice(texte: loc.scanOrganNoPlotNotice, icone: Icons.map_outlined),
          ],
          const SizedBox(height: AppSpacing.md),
          for (final organe in Organe.values) ...[
            _OrganeTile(
              titre: organeLabelBilingue(organe, loc),
              icone: organe.icone,
              onTap: () => demarrer(organe: organe),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          _OrganeTile(
            titre: loc.organUnknown,
            sousTitre: loc.organUnknownHint,
            icone: Icons.help_outline,
            onTap: () => demarrer(guidee: true),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _OrganeTile extends StatelessWidget {
  const _OrganeTile({
    required this.titre,
    required this.icone,
    required this.onTap,
    this.sousTitre,
  });

  final String titre;
  final String? sousTitre;
  final IconData icone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Icon(icone, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (sousTitre != null)
                      Text(
                        sousTitre!,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.texte, required this.icone});

  final String texte;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.severityMedium.withAlpha(25),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 18, color: AppColors.severityMedium),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              texte,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
