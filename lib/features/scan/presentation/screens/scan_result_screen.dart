import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/ai/diagnosis_certainty.dart';
import '../../../../core/ai/disease_catalog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/declared_severity.dart';
import '../../domain/entities/diagnostic_result.dart';
import '../diagnosis_labels.dart';
import '../providers/scan_provider.dart';

/// Résultat d'un scan (tâches P1.1, P1.2, P1.3 et P1.7) :
/// - aucun produit ni dosage, seulement des gestes de prévention sourcés ;
/// - certitude affichée en mots, résultat incertain jamais présenté comme une maladie ;
/// - gravité déclarée par l'agriculteur ;
/// - enregistrement uniquement sur action explicite.
class ScanResultScreen extends ConsumerStatefulWidget {
  const ScanResultScreen({super.key});

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  DeclaredSeverity? _severity;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final scanState = ref.watch(scanNotifierProvider);
    final result = switch (scanState) {
      ScanSuccess(:final result) => result,
      _ => null,
    };

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: loc.scanResultBackSemantics,
          icon: const Icon(Icons.arrow_back),
          onPressed: _leaveToHome,
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.scanResultTitle,
              style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
            ),
            Text(
              loc.scanResultSubtitle,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      body: result == null
          ? _NoResult(onScan: () => context.go(AppRoutes.scanning))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: result.certitude == DiagnosisCertainty.incertain
                  ? _UncertainResult(
                      result: result,
                      onRetake: _retake,
                      onBack: _leaveToHome,
                    )
                  : _buildResult(loc, result),
            ),
    );
  }

  Widget _buildResult(AppLocalizations loc, DiagnosticResult result) {
    final info = DiseaseCatalog.of(result.maladieDetectee);
    final diseaseName = DiseaseCatalog.displayName(result.maladieDetectee, loc);
    final isProbable = result.certitude == DiagnosisCertainty.probable;
    final otherNames = result.classement
        .skip(1)
        .map((candidate) => DiseaseCatalog.displayName(candidate.label, loc))
        .toList();
    final advice = info?.advice ?? const <LocalizedText>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResultPhoto(imagePath: result.imagePath),
        const SizedBox(height: AppSpacing.md),
        Text(
          diseaseName,
          style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
        ),
        if (info != null && info.scientificName.isNotEmpty)
          Text(
            info.scientificName,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        _CertaintyBanner(
          label: result.certitude.label(loc),
          explanation: isProbable
              ? loc.scanCertaintyExplainProbable
              : loc.scanCertaintyExplainPossible,
          color: isProbable ? AppColors.primary : AppColors.severityMedium,
          icon: isProbable ? Icons.check_circle_outline : Icons.help_outline,
        ),
        if (otherNames.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            loc.scanOtherCandidates(otherNames.join(', ')),
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _SectionTitle(loc.scanSeverityQuestion),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final severity in DeclaredSeverity.values)
              ChoiceChip(
                label: Text(severity.label(loc)),
                selected: _severity == severity,
                onSelected: (selected) =>
                    setState(() => _severity = selected ? severity : null),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionTitle(loc.scanAdviceTitle),
        const SizedBox(height: AppSpacing.sm),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final text in advice) _AdviceRow(text: text(loc)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                loc.scanAdviceNoChemical,
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton.icon(
          onPressed: _saving ? null : () => _save(loc),
          icon: const Icon(Icons.bookmark_add_outlined),
          label: Text(loc.commonSave),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: _retake,
          icon: const Icon(Icons.camera_alt_outlined),
          label: Text(loc.scanRetakePhoto),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton.icon(
          onPressed: () => _discard(loc),
          icon: const Icon(Icons.thumb_down_alt_outlined),
          label: Text(loc.scanDiscard),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        TextButton.icon(
          onPressed: () => _share(loc, result, diseaseName),
          icon: const Icon(Icons.share_outlined),
          label: Text(loc.scanShare),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Future<void> _save(AppLocalizations loc) async {
    setState(() => _saving = true);
    final outcome = await ref
        .read(scanNotifierProvider.notifier)
        .saveCurrent(severity: _severity);
    if (!mounted) return;
    setState(() => _saving = false);

    final messenger = ScaffoldMessenger.of(context);
    if (outcome == SaveOutcome.saved) {
      messenger.showSnackBar(SnackBar(content: Text(loc.scanResultSaved)));
      context.go(AppRoutes.journal);
      ref.read(scanNotifierProvider.notifier).reset();
    } else {
      messenger.showSnackBar(SnackBar(content: Text(loc.scanResultSaveFailed)));
    }
  }

  void _retake() {
    context.go(AppRoutes.scanning);
    ref.read(scanNotifierProvider.notifier).reset();
  }

  void _leaveToHome() {
    context.go(AppRoutes.home);
    ref.read(scanNotifierProvider.notifier).reset();
  }

  void _discard(AppLocalizations loc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.scanDiscarded)),
    );
    _retake();
  }

  Future<void> _share(
    AppLocalizations loc,
    DiagnosticResult result,
    String diseaseName,
  ) async {
    final text = [
      loc.scanShareTitle,
      loc.scanShareCulture,
      loc.scanShareDisease(diseaseName),
      loc.scanShareCertainty(result.certitude.label(loc)),
      loc.scanShareDate(DateFormat('dd/MM/yyyy').format(result.createdAt)),
    ].join('\n');
    await Share.share(text);
  }
}

class _NoResult extends StatelessWidget {
  const _NoResult({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_search_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(loc.scanNoResult, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(loc.scanHeaderTitle),
            ),
          ],
        ),
      ),
    );
  }
}

class _UncertainResult extends StatelessWidget {
  const _UncertainResult({
    required this.result,
    required this.onRetake,
    required this.onBack,
  });

  final DiagnosticResult result;
  final VoidCallback onRetake;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResultPhoto(imagePath: result.imagePath),
        const SizedBox(height: AppSpacing.md),
        _CertaintyBanner(
          label: loc.scanUncertainTitle,
          explanation: loc.scanUncertainBody,
          color: AppColors.severityHigh,
          icon: Icons.error_outline,
        ),
        const SizedBox(height: AppSpacing.md),
        _Card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(loc.scanRetakeTips, style: AppTypography.bodySmall)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton.icon(
          onPressed: onRetake,
          icon: const Icon(Icons.camera_alt_outlined),
          label: Text(loc.scanRetakePhoto),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: onBack,
          style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: Text(loc.scanResultBackSemantics),
        ),
      ],
    );
  }
}

class _ResultPhoto extends StatelessWidget {
  const _ResultPhoto({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: path != null && File(path).existsSync()
          ? Image.file(File(path), height: 200, width: double.infinity, fit: BoxFit.cover)
          : Container(
              height: 200,
              color: AppColors.primaryLight,
              child: const Center(
                child: Icon(Icons.image_outlined, size: 64, color: AppColors.primary),
              ),
            ),
    );
  }
}

class _CertaintyBanner extends StatelessWidget {
  const _CertaintyBanner({
    required this.label,
    required this.explanation,
    required this.color,
    required this.icon,
  });

  final String label;
  final String explanation;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(color: color, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  explanation,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: child,
    );
  }
}

class _AdviceRow extends StatelessWidget {
  const _AdviceRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
