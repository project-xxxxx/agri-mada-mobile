import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/ai/disease_catalog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../knowledge/domain/fiche_search.dart';
import '../../../knowledge/presentation/providers/fiches_provider.dart';
import '../../../knowledge/presentation/widgets/fiche_card.dart';

/// Guide des maladies reconnues par le modèle (tâches P1.1 et P1.5), suivi du
/// guide complet tiré des fiches de connaissance (tâche P5.3, ADR-010).
///
/// Remplace l'ancienne page « Solutions agricoles », qui recommandait
/// fongicides, insecticides et engrais sans source. Les fiches viennent du
/// catalogue des maladies : aucun produit ni dosage.
class GuidesScreen extends ConsumerWidget {
  const GuidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.go(AppRoutes.home),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.guidesTitle,
              style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              loc.guidesSubtitle,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withAlpha(60),
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    loc.guidesDisclaimer,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final info in DiseaseCatalog.guides) ...[
            _GuideCard(info: info),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(
            loc.guidesKnowledgeSectionTitle,
            style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
          ),
          Text(
            loc.guidesKnowledgeSectionSubtitle,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _GuideComplet(),
        ],
      ),
    );
  }
}

class _GuideComplet extends ConsumerStatefulWidget {
  const _GuideComplet();

  @override
  ConsumerState<_GuideComplet> createState() => _GuideCompletState();
}

class _GuideCompletState extends ConsumerState<_GuideComplet> {
  final _controleur = TextEditingController();

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final fichesAsync = ref.watch(fichesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controleur,
          decoration: InputDecoration(
            hintText: loc.guidesSearchHint,
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.sm),
        fichesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              loc.guidesLoadError,
              style: AppTypography.bodySmall.copyWith(color: AppColors.severityHigh),
            ),
          ),
          data: (fiches) {
            final resultats = rechercherFiches(fiches, _controleur.text);
            if (resultats.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(loc.guidesNoResults, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
              );
            }
            return Column(
              children: [
                for (final fiche in resultats) ...[
                  FicheCard(fiche: fiche),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.info});

  final DiseaseInfo info;

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
        leading: Icon(
          info.isHealthy ? Icons.check_circle_outline : Icons.warning_amber_outlined,
          color: info.isHealthy ? AppColors.severityLow : AppColors.primary,
        ),
        title: Text(
          info.name(loc),
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: info.scientificName.isEmpty
            ? null
            : Text(
                info.scientificName,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (info.description case final description?)
            Text(description(loc), style: AppTypography.bodySmall),
          if (info.symptoms case final symptoms?)
            _GuideSection(
              title: info.isHealthy ? loc.guidesHealthySigns : loc.guidesSymptoms,
              body: symptoms(loc),
            ),
          if (info.causes case final causes?)
            _GuideSection(title: loc.guidesCauses, body: causes(loc)),
          _GuideSection(
            title: loc.guidesAdvice,
            body: info.advice.map((advice) => '• ${advice(loc)}').join('\n'),
          ),
        ],
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
