import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:agri_mada/l10n/app_localizations.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/ai/disease_catalog.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../scan/domain/entities/declared_severity.dart';
import '../../../scan/presentation/diagnosis_labels.dart';
import '../../../scan/presentation/organ_labels.dart';
import '../../domain/entities/resultat_scan.dart';
import '../diagnostic_filter.dart';
import '../providers/journal_provider.dart';
import '../resultat_labels.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  DiagnosticFilter _filter = DiagnosticFilter.all;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final resultatsAsync = ref.watch(resultatsHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, size: 28),
            tooltip: loc.homeMenuSemantics,
            onPressed: () => openAppMenu(context),
          ),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.homeServiceCropsTitle, style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
            Text(loc.journalHistorySubtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.cardRadius),
            topRight: Radius.circular(AppSpacing.cardRadius),
          ),
        ),
        child: resultatsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text(loc.journalError(e.toString()))),
          data: (resultats) {
            if (resultats.isEmpty) {
              return _EmptyHistory(onScan: () => context.go(AppRoutes.scanOrgane));
            }

            final visible = applyDiagnosticFilter(resultats, _filter);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FilterBar(
                  selected: _filter,
                  onSelected: (filter) => setState(() => _filter = filter),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Text(
                              loc.journalFilterEmpty,
                              style: AppTypography.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: visible.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) =>
                              _ResultatCard(resultat: visible[index]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.scanOrgane),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textOnPrimary),
      ),
    );
  }
}

/// Filtres réellement appliqués à l'historique (tâche P1.10).
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final DiagnosticFilter selected;
  final ValueChanged<DiagnosticFilter> onSelected;

  String _label(DiagnosticFilter filter, AppLocalizations loc) => switch (filter) {
        DiagnosticFilter.all => loc.journalFilterAll,
        DiagnosticFilter.lastSevenDays => loc.journalFilterLastSevenDays,
        DiagnosticFilter.severe => loc.journalFilterSevere,
        DiagnosticFilter.healthy => loc.journalFilterHealthy,
      };

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    // Wrap plutôt qu'un défilement horizontal : aucun filtre n'est caché hors écran.
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          for (final filter in DiagnosticFilter.values)
            ChoiceChip(
              label: Text(_label(filter, loc)),
              selected: filter == selected,
              onSelected: (_) => onSelected(filter),
            ),
        ],
      ),
    );
  }
}

class _ResultatCard extends StatelessWidget {
  const _ResultatCard({required this.resultat});

  final ResultatScan resultat;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final info = resultat.ficheId == null ? null : DiseaseCatalog.of(resultat.ficheId!);
    final severity = DeclaredSeverity.fromCode(resultat.graviteDeclaree);

    // La couleur suit la part de parcelle déclarée par l'agriculteur,
    // jamais la confiance du modèle (tâche P1.3).
    final Color statusColor = resultat.estSain
        ? AppColors.severityLow
        : switch (severity) {
            DeclaredSeverity.quelquesPlants => AppColors.severityLow,
            DeclaredSeverity.moinsDunTiers => AppColors.severityMedium,
            DeclaredSeverity.plusDunTiers => AppColors.severityHigh,
            null => AppColors.textSecondary,
          };
    final String statusText = resultat.estSain
        ? loc.journalStatusHealthy
        : declaredSeverityLabel(resultat.graviteDeclaree, loc);
    final IconData statusIcon = resultat.estSain
        ? Icons.check_circle_outline
        : (severity == null ? Icons.help_outline : Icons.warning_amber_outlined);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              clipBehavior: Clip.antiAlias,
              child: resultat.imagePath != null && File(resultat.imagePath!).existsSync()
                  ? Image.file(File(resultat.imagePath!), fit: BoxFit.cover)
                  : const Icon(Icons.image_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomResultat(resultat, loc),
                    style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (info != null && info.scientificName.isNotEmpty)
                    Text(
                      info.scientificName,
                      style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                    ),
                  if (resultat.organes.isNotEmpty)
                    Text(
                      resultat.organes.map((organe) => organe.label(loc)).join(' · '),
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  // Une piste du modèle n'est pas un diagnostic (P1.2).
                  if (!resultat.estSain && !resultat.estConfirme)
                    Text(
                      loc.journalStatusToConfirm,
                      style: AppTypography.caption.copyWith(
                          color: AppColors.severityMedium, fontWeight: FontWeight.w600),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 12),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            statusText,
                            style: AppTypography.caption
                                .copyWith(color: statusColor, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('dd MMM').format(resultat.date),
                  style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                Text(
                  DateFormat('yyyy').format(resultat.date),
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary.withAlpha(150)),
                ),
                if (resultat.nbPhotos > 1)
                  Text(
                    loc.journalPhotoCount(resultat.nbPhotos),
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 80, color: AppColors.primaryLight),
          const SizedBox(height: AppSpacing.md),
          Text(loc.journalHistoryEmptyTitle, style: AppTypography.headlineMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text(loc.journalHistoryEmptyDescription, style: AppTypography.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(loc.journalStartDiagnosis),
          ),
        ],
      ),
    );
  }
}
