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
import '../../../../core/local_db/models/diagnostic_local.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../providers/journal_provider.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final diagnosticsAsync = ref.watch(diagnosticsHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Consumer(
          builder: (context, ref, _) => IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: () => ref.read(sidebarControllerProvider.notifier).state = true,
          ),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('État des cultures', style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
            Text('Historique des analyses', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                _buildFilterChip('Tous', true),
                const SizedBox(width: AppSpacing.sm),
                _buildFilterChip('Cette semaine', false),
                const SizedBox(width: AppSpacing.sm),
                _buildFilterChip('Grave', false),
                const SizedBox(width: AppSpacing.sm),
                _buildFilterChip('Stable', false),
              ],
            ),
          ),
          
          Expanded(
            child: Container(
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
                  
                  // TODO: Apply filters based on _activeFilter when backend is ready
                  
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.scanning),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textOnPrimary),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: AppColors.textSecondary.withAlpha(50)),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isActive ? AppColors.textOnPrimary : AppColors.textPrimary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _DiagnosticCard extends StatelessWidget {
  const _DiagnosticCard({required this.diagnostic});
  final DiagnosticLocal diagnostic;

  @override
  Widget build(BuildContext context) {
    final bool isSevere = diagnostic.niveauGravite?.toLowerCase() == 'sévère' || diagnostic.niveauGravite?.toLowerCase() == 'élevé';
    final bool isHealthy = diagnostic.maladieDetectee.toLowerCase().contains('sain') || diagnostic.maladieDetectee.toLowerCase() == 'healthy';
    
    final Color statusColor = isHealthy ? AppColors.severityLow : (isSevere ? AppColors.severityHigh : AppColors.severityMedium);
    final String statusText = isHealthy ? 'Gravité faible' : (isSevere ? 'Évolution : aggravation' : 'Évolution : stable');
    final IconData statusIcon = isHealthy ? Icons.check_circle_outline : (isSevere ? Icons.error_outline : Icons.warning_amber_outlined);

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
                    diagnostic.maladieDetectee,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getScientificName(diagnostic.maladieDetectee),
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
                        Text(
                          statusText,
                          style: AppTypography.caption.copyWith(color: statusColor, fontWeight: FontWeight.w600),
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

  String _getScientificName(String commonName) {
    // Mapping basique pour l'UI, idéalement cela viendrait d'une base de données locale des maladies
    if (commonName.toLowerCase().contains('pyriculariose') || commonName.toLowerCase().contains('blast')) return 'Magnaporthe oryzae';
    if (commonName.toLowerCase().contains('helminthosporiose') || commonName.toLowerCase().contains('brown spot')) return 'Cochliobolus miyabeanus';
    if (commonName.toLowerCase().contains('bacterial') || commonName.toLowerCase().contains('blight')) return 'Xanthomonas oryzae';
    return '';
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 80, color: AppColors.primaryLight),
          const SizedBox(height: AppSpacing.md),
          Text('Aucune analyse', style: AppTypography.headlineMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          const Text('Vos diagnostics récents apparaîtront ici', style: AppTypography.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Faire un diagnostic'),
          ),
        ],
      ),
    );
  }
}
