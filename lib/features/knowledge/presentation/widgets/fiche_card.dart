// Carte d'une fiche de connaissance dans le guide complet (tâche P5.3).
//
// Affiche toujours le bandeau brouillon (ADR-010) : aucune fiche n'est
// aujourd'hui validée par un agronome.

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../scan/presentation/organ_labels.dart';
import '../../domain/entities/fiche.dart';

class FicheCard extends StatelessWidget {
  const FicheCard({super.key, required this.fiche});

  final Fiche fiche;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: const BorderSide(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: const Icon(Icons.menu_book_outlined, color: AppColors.primary),
        title: Text(
          fiche.noms.mg == null ? fiche.noms.fr : '${fiche.noms.fr} · ${fiche.noms.mg}',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: fiche.noms.sci == null
            ? null
            : Text(
                fiche.noms.sci!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
        childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fiche.estBrouillon) _BandeauBrouillon(loc: loc),
          for (final entree in fiche.organes.entries)
            _Section(
              title: entree.key.label(loc),
              bullets: entree.value,
            ),
          if (fiche.prevention.isNotEmpty)
            _Section(title: loc.guidesPreventionTitle, bullets: fiche.prevention),
          if (fiche.conditions.facteurs.isNotEmpty)
            _Section(title: loc.guidesConditionsTitle, bullets: fiche.conditions.facteurs),
          if (fiche.confusions.isNotEmpty)
            _Section(
              title: loc.guidesConfusionTitle,
              bullets: [
                for (final confusion in fiche.confusions)
                  confusion.question(enMalgache: loc.localeName.startsWith('mg')),
              ],
            ),
          if (fiche.sources.isNotEmpty)
            _Section(
              title: loc.guidesSourcesTitle,
              bullets: [for (final source in fiche.sources) source.titre],
              titleColor: AppColors.textSecondary,
              bulletStyle: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }
}

class _BandeauBrouillon extends StatelessWidget {
  const _BandeauBrouillon({required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.severityMedium.withAlpha(40),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit_note, size: 16, color: AppColors.severityMedium),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              loc.guidesDraftBadge,
              style: AppTypography.caption.copyWith(
                color: AppColors.severityMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.bullets,
    this.titleColor = AppColors.primary,
    this.bulletStyle,
  });

  final String title;
  final List<String> bullets;
  final Color titleColor;
  final TextStyle? bulletStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(color: titleColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final bullet in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text('• $bullet', style: bulletStyle ?? AppTypography.bodySmall),
            ),
        ],
      ),
    );
  }
}
