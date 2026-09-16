// Journal Agricole - Écran dynamique connecté à Isar (hors-ligne)
// Affiche les vraies parcelles avec leur statut de santé calculé dynamiquement

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:agri_mada/l10n/app_localizations.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/usecases/export_journal_usecase.dart';
import '../../data/services/export_service.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../providers/journal_provider.dart';
import '../widgets/add_parcelle_sheet.dart';
import '../../../../core/ai/disease_catalog.dart';
import '../../../scan/presentation/diagnosis_labels.dart';

class MyParcellesScreen extends ConsumerWidget {
  const MyParcellesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final journalAsync = ref.watch(journalAgricoleProvider);
    final journalData = journalAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      drawer: const AppMenuDrawer(),
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
            Text(loc.homeServicePlotsTitle, style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
            Text(loc.journalSubtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: journalData == null
                ? null
                : () {
                    if (journalData.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.exportNothing),
                        ),
                      );
                      return;
                    }
                    _showExportSheet(context, ref, parcelleId: null);
                  },
            icon: const Icon(Icons.download_outlined),
            tooltip: loc.exportAction,
          ),
        ],
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
        child: journalAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text(loc.journalError(e.toString()))),
          data: (journal) {
            if (journal.isEmpty) {
              return _EmptyJournal(
                  onAdd: () => _showAddParcelleSheet(context, ref));
            }
            // Tri : malades, puis parcelles à confirmer, puis les autres
            int rank(JournalEntry entry) =>
                switch (entry.statut) { 'malade' => 0, 'a_confirmer' => 1, _ => 2 };
            final sorted = [...journal]..sort((a, b) => rank(a).compareTo(rank(b)));

            return Column(
              children: [
                // Résumé rapide
                _QuickStats(journal: journal),
                // Liste des parcelles
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) => TweenAnimationBuilder<double>(
                      key: ValueKey(sorted[index].parcelle.id),
                      duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 500)),
                      curve: Curves.easeOutCubic,
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, _) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: _ParcelleCard(
                              entry: sorted[index],
                              onScan: () => context.go(AppRoutes.scanning),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddParcelleSheet(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.textOnPrimary),
        label: Text(loc.journalNewPlot,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textOnPrimary)),
      ),
    );
  }

  void _showAddParcelleSheet(BuildContext context, WidgetRef ref) {
    final container = ProviderScope.containerOf(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => UncontrolledProviderScope(
        container: container,
        child: AddParcelleSheet(
          onSaved: () => ref.invalidate(journalAgricoleProvider),
        ),
      ),
    );
  }

  Future<void> _showExportSheet(
    BuildContext context,
    WidgetRef ref, {
    int? parcelleId,
  }) async {
    final choice = await showModalBottomSheet<ExportFormat>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.table_view_outlined),
                title: Text(AppLocalizations.of(sheetContext).exportAsCsv),
                onTap: () => Navigator.of(sheetContext).pop(ExportFormat.csv),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: Text(AppLocalizations.of(sheetContext).exportAsPdf),
                onTap: () => Navigator.of(sheetContext).pop(ExportFormat.pdf),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (choice == null || !context.mounted) return;
    final loc = AppLocalizations.of(context);
    final strings = ExportStrings(
      csvDate: loc.exportCsvDate,
      csvPlot: loc.exportCsvPlot,
      csvDisease: loc.exportCsvDisease,
      csvSeverity: loc.exportCsvSeverity,
      csvConfidence: loc.exportCsvConfidence,
      csvRecommendations: loc.exportCsvRecommendations,
      csvTreatment: loc.exportCsvTreatment,
      pdfGeneratedBy: loc.exportPdfGeneratedBy,
      pdfTitle: loc.exportPdfTitle,
      pdfAllPlots: loc.exportPdfAllPlots,
      pdfPlotLabel: loc.exportPdfPlotLabel,
      pdfDateLabel: loc.exportPdfDateLabel,
      diseaseName: (label) => DiseaseCatalog.displayName(label, loc),
      severityLabel: (code) => declaredSeverityLabel(code, loc),
    );

    final result = await ref
        .read(exportJournalUseCaseProvider)
        .call(parcelleId: parcelleId, format: choice, strings: strings);

    if (!context.mounted) return;

    await result.fold(
      (failure) async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (path) async {
        // Partage le fichier lui-même, et non plus son seul chemin (P1.10).
        await Share.shareXFiles([XFile(path)], text: loc.exportShareText);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.exportDone)),
        );
      },
    );
  }
}

// ─── En-tête ────────────────────────────────────────────────────────────────

// ─── Résumé rapide ──────────────────────────────────────────────────────────

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.journal});
  final List<JournalEntry> journal;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final saines = journal.where((e) => e.statut == 'sain').length;
    final malades = journal.where((e) => e.statut == 'malade').length;
    final aConfirmer = journal.where((e) => e.statut == 'a_confirmer').length;
    final total = journal.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _StatItem(
              label: loc.journalTotal,
              value: '$total',
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: _StatItem(
              label: loc.journalHealthyPlural,
              value: '$saines',
              color: AppColors.severityLow,
            ),
          ),
          Expanded(
            child: _StatItem(
              label: loc.journalSickPlural,
              value: '$malades',
              color: AppColors.severityHigh,
            ),
          ),
          Expanded(
            child: _StatItem(
              label: loc.journalStatusToConfirm,
              value: '$aConfirmer',
              color: AppColors.severityMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTypography.displayMedium
                .copyWith(color: color, fontWeight: FontWeight.bold)),
        Text(label,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

// ─── Carte parcelle ─────────────────────────────────────────────────────────

class _ParcelleCard extends StatelessWidget {
  const _ParcelleCard({required this.entry, required this.onScan});
  final JournalEntry entry;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final parcelle = entry.parcelle;
    final statut = entry.statut;
    final dernierDiag = entry.dernierDiagnostic;
    final nbDiag = entry.nbDiagnostics;

    final isMalade = statut == 'malade';
    final (statusColor, statusLabel, statusIcon) = switch (statut) {
      'malade' => (AppColors.severityHigh, loc.journalStatusSick, Icons.warning_amber_outlined),
      'sain' => (AppColors.severityLow, loc.journalStatusHealthy, Icons.check_circle_outline),
      'a_confirmer' => (AppColors.severityMedium, loc.journalStatusToConfirm, Icons.help_outline),
      _ => (AppColors.textSecondary, loc.journalStatusNotAnalyzed, Icons.help_outline),
    };

    return GestureDetector(
      onTap: () => context.push('${AppRoutes.parcelleDetail}/${parcelle.id}'),
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
        border: isMalade
            ? Border.all(color: AppColors.severityHigh.withAlpha(80), width: 1)
            : null,
      ),
      child: Column(
        children: [
          // Ligne principale
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Icon(Icons.map_outlined, color: statusColor, size: 28),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(parcelle.nomParcelle,
                          style: AppTypography.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600)),
                      if (parcelle.description != null)
                        Text(parcelle.description!,
                            style: AppTypography.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(children: [
                        if (parcelle.surface != null) ...[
                          const Icon(Icons.crop_square_outlined,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 2),
                          Text(loc.journalAreaHa(parcelle.surface.toString()),
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.textSecondary)),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Text(loc.journalAnalysesCount(nbDiag),
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textSecondary)),
                      ]),
                    ],
                  ),
                ),
                // Badge statut
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(statusIcon, color: statusColor, size: 12),
                    const SizedBox(width: 3),
                    Text(statusLabel,
                        style: AppTypography.caption.copyWith(
                            color: statusColor, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ),
          ),
          // Dernier diagnostic
          if (dernierDiag != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.history,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      loc.journalLastDiagnostic(
                        DiseaseCatalog.displayName(dernierDiag.maladieDetectee, loc),
                        DateFormat('dd/MM/yyyy')
                            .format(dernierDiag.dateDiagnostic),
                      ),
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: onScan,
                    child: Text(loc.journalScan,
                        style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(loc.journalNoDiagnosticYet,
                        style: AppTypography.caption,
                        overflow: TextOverflow.ellipsis),
                  ),
                  TextButton(
                    onPressed: onScan,
                    child: Text(loc.journalScanNow,
                        style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
    );
  }
}

// ─── Journal vide ───────────────────────────────────────────────────────────

class _EmptyJournal extends StatelessWidget {
  const _EmptyJournal({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.map_outlined,
              size: 80, color: AppColors.primaryLight),
          const SizedBox(height: AppSpacing.md),
          Text(loc.journalEmptyTitle,
              style: AppTypography.headlineMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text(loc.journalEmptyDescription,
              style: AppTypography.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(loc.journalAddPlot),
          ),
        ],
      ),
    );
  }
}

