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
import '../../../../core/local_db/models/parcelle_local.dart';
import '../../../../core/local_db/models/diagnostic_local.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../scan/presentation/providers/scan_provider.dart';
import '../providers/journal_provider.dart';
import '../../../../core/ai/diagnosis_certainty.dart';
import '../../../../core/ai/disease_catalog.dart';
import '../../../scan/presentation/diagnosis_labels.dart';

class ParcelleDetailScreen extends ConsumerWidget {
  const ParcelleDetailScreen({super.key, required this.parcelleId});
  final int parcelleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final parcellesAsync = ref.watch(parcellesProvider);
    final diagnosticsAsync = ref.watch(diagnosticsParParcelleProvider(parcelleId));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      drawer: const AppMenuDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(loc.parcelDetailTitle, style: AppTypography.headlineMedium),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, size: 28),
              tooltip: AppLocalizations.of(context).homeMenuSemantics,
              onPressed: () => openAppMenu(context),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () => context.push('${AppRoutes.scanning}?parcelleId=$parcelleId'),
            tooltip: loc.parcelDetailNewAnalysis,
          ),
        ],
      ),
      body: parcellesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text(loc.journalError('$e'))),
        data: (parcelles) {
          final parcelle = parcelles.where((p) => p.id == parcelleId).firstOrNull;
          if (parcelle == null) {
            return Center(child: Text(loc.parcelDetailNotFound));
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _ParcelleHeader(parcelle: parcelle)),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              SliverToBoxAdapter(
                child: diagnosticsAsync.when(
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )),
                  error: (e, _) => Center(child: Text(loc.journalError('$e'))),
                  data: (diagnostics) => _ParcelleHealthCard(
                    parcelle: parcelle,
                    diagnostics: diagnostics,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                  child: Text(loc.journalHistorySubtitle, style: AppTypography.headlineMedium),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
              diagnosticsAsync.when(
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                data: (diagnostics) {
                  if (diagnostics.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.history_outlined, size: 64, color: AppColors.textSecondary),
                              const SizedBox(height: AppSpacing.md),
                              Text(loc.parcelDetailNoAnalysis, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
                              const SizedBox(height: AppSpacing.md),
                              ElevatedButton.icon(
                                onPressed: () => context.push('${AppRoutes.scanning}?parcelleId=$parcelleId'),
                                icon: const Icon(Icons.camera_alt_outlined),
                                label: Text(loc.journalStartDiagnosis),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final diag = diagnostics[index];
                        return _DiagnosticHistoryItem(diagnostic: diag);
                      },
                      childCount: diagnostics.length,
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }
}

class _ParcelleHeader extends StatelessWidget {
  const _ParcelleHeader({required this.parcelle});
  final ParcelleLocal parcelle;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (parcelle.photoPath != null && File(parcelle.photoPath!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              child: Image.file(File(parcelle.photoPath!), height: 160, width: double.infinity, fit: BoxFit.cover),
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(AppSpacing.sm)),
              child: const Icon(Icons.landscape_outlined, size: 64, color: AppColors.primary),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(parcelle.nomParcelle, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700)),
          if (parcelle.description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(parcelle.description!, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (parcelle.surface != null) ...[
                const Icon(Icons.crop_square_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(loc.journalAreaHa('${parcelle.surface}'), style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(width: AppSpacing.md),
              ],
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(DateFormat('dd MMM yyyy').format(parcelle.createdAt), style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParcelleHealthCard extends StatelessWidget {
  const _ParcelleHealthCard({required this.parcelle, required this.diagnostics});
  final ParcelleLocal parcelle;
  final List<DiagnosticLocal> diagnostics;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (diagnostics.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal, vertical: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary, size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(loc.parcelDetailNotAnalyzedYet, style: AppTypography.bodyMedium)),
          ],
        ),
      );
    }

    final latest = diagnostics.first;
    final isHealthy = DiseaseCatalog.isHealthy(latest.maladieDetectee);
    final statusColor = isHealthy ? AppColors.severityLow : AppColors.severityHigh;
    final statusIcon = isHealthy ? Icons.check_circle_outline : Icons.warning_amber_outlined;
    final statusLabel = isHealthy ? loc.journalStatusHealthy : loc.journalStatusSick;
    final certainty = DiagnosisCertainty.fromName(latest.certitude);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal, vertical: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: statusColor.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(loc.parcelDetailHealthStatus, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                child: Text(statusLabel, style: AppTypography.caption.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(DiseaseCatalog.displayName(latest.maladieDetectee, loc), style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(declaredSeverityLabel(latest.niveauGravite, loc), style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          if (certainty != null)
            Text(certainty.label(loc), style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _DiagnosticHistoryItem extends StatelessWidget {
  const _DiagnosticHistoryItem({required this.diagnostic});
  final DiagnosticLocal diagnostic;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isHealthy = DiseaseCatalog.isHealthy(diagnostic.maladieDetectee);
    final statusColor = isHealthy ? AppColors.severityLow : AppColors.severityHigh;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal, vertical: 4),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: statusColor.withAlpha(20), borderRadius: BorderRadius.circular(AppSpacing.sm)),
            child: diagnostic.imagePath != null && File(diagnostic.imagePath!).existsSync()
                ? ClipRRect(borderRadius: BorderRadius.circular(AppSpacing.sm), child: Image.file(File(diagnostic.imagePath!), fit: BoxFit.cover))
                : const Icon(Icons.image_outlined, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DiseaseCatalog.displayName(diagnostic.maladieDetectee, loc), style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(declaredSeverityLabel(diagnostic.niveauGravite, loc), style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(DateFormat('dd/MM/yyyy').format(diagnostic.dateDiagnostic), style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
