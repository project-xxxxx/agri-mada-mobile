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
import '../../../../core/local_db/models/diagnostic_local.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../scan/domain/entities/declared_severity.dart';
import '../../../scan/presentation/diagnosis_labels.dart';
import '../providers/journal_provider.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final diagnosticsAsync = ref.watch(diagnosticsHistoryProvider);

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
      // Les puces de filtre factices (« Cette semaine », « Grave »…) ont été
      // retirées : elles ne filtraient rien (tâche P1.10).
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.cardRadius),
            topRight: Radius.circular(AppSpacing.cardRadius),
          ),
        ),
        child: diagnosticsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text(loc.journalError(e.toString()))),
          data: (diagnostics) {
            if (diagnostics.isEmpty) {
              return _EmptyHistory(onScan: () => context.go(AppRoutes.scanning));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: diagnostics.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final diag = diagnostics[index];
                return _DiagnosticCard(diagnostic: diag);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.scanning),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textOnPrimary),
      ),
    );
  }
}

class _DiagnosticCard extends StatelessWidget {
  const _DiagnosticCard({required this.diagnostic});
  final DiagnosticLocal diagnostic;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final info = DiseaseCatalog.of(diagnostic.maladieDetectee);
    final isHealthy = info?.isHealthy ?? false;
    final severity = DeclaredSeverity.fromCode(diagnostic.niveauGravite);

    // La couleur suit la part de parcelle déclarée par l'agriculteur,
    // jamais la confiance du modèle (tâche P1.3).
    final Color statusColor = isHealthy
        ? AppColors.severityLow
        : switch (severity) {
            DeclaredSeverity.quelquesPlants => AppColors.severityLow,
            DeclaredSeverity.moinsDunTiers => AppColors.severityMedium,
            DeclaredSeverity.plusDunTiers => AppColors.severityHigh,
            null => AppColors.textSecondary,
          };
    final String statusText = isHealthy
        ? loc.journalStatusHealthy
        : declaredSeverityLabel(diagnostic.niveauGravite, loc);
    final IconData statusIcon = isHealthy
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
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              clipBehavior: Clip.antiAlias,
              child: diagnostic.imagePath != null && File(diagnostic.imagePath!).existsSync()
                  ? Image.file(File(diagnostic.imagePath!), fit: BoxFit.cover)
                  : const Icon(Icons.image_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DiseaseCatalog.displayName(diagnostic.maladieDetectee, loc),
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (info != null && info.scientificName.isNotEmpty)
                    Text(
                      info.scientificName,
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
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
                            style: AppTypography.caption.copyWith(color: statusColor, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('dd MMM').format(diagnostic.dateDiagnostic),
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                Text(
                  DateFormat('yyyy').format(diagnostic.dateDiagnostic),
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary.withAlpha(150)),
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
