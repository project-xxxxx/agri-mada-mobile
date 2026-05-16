import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../providers/scan_provider.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  const ScanResultScreen({super.key});

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanNotifierProvider);
    final result = switch (scanState) {
      ScanSuccess(:final result) => result,
      _ => null,
    };

    if (result == null) {
      ref.listen<ScanState>(scanNotifierProvider, (_, next) {
        if (next is! ScanSuccess && context.mounted) {
          context.go(AppRoutes.scanning);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    final bool isSevere = result.niveauGravite?.toLowerCase() == 'sévère' || result.niveauGravite?.toLowerCase() == 'élevé';
    final bool isHealthy = result.maladieDetectee.toLowerCase().contains('sain') || result.maladieDetectee.toLowerCase() == 'healthy';
    final double severityPercent = isHealthy ? 0.1 : (isSevere ? 0.9 : 0.5);
    final String severityLabel = isHealthy ? 'Niveau faible' : (isSevere ? 'Niveau élevé - intervention recommandée' : 'Niveau moyen - à surveiller');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.go(AppRoutes.home),
          child: const Icon(Icons.arrow_back_ios, size: 22),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Résultat de l\'analyse', style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
            Text('Analyse hors ligne terminé', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    if (result.imagePath != null && File(result.imagePath!).existsSync())
                      Image.file(File(result.imagePath!), height: 200, width: double.infinity, fit: BoxFit.cover)
                    else
                      Container(height: 200, color: AppColors.primaryLight, child: const Icon(Icons.image_outlined, size: 64, color: AppColors.primary)),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result.maladieDetectee,
                                  style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getScientificName(result.maladieDetectee),
                                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.severityLow.withAlpha(20),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified, color: AppColors.severityLow, size: 14),
                                const SizedBox(width: 4),
                                Text('Diagnostic IA fiable', style: AppTypography.caption.copyWith(color: AppColors.severityLow, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Niveau de gravité
              Text('Niveau de gravité', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: const LinearGradient(
                              colors: [AppColors.severityLow, AppColors.severityMedium, AppColors.severityHigh],
                            ),
                          ),
                        ),
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.8 * severityPercent - 10, // Approximation
                          top: -2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.textPrimary, width: 2),
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 4)],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Faible', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                        Text('Moyen', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                        Text('Élevé', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isSevere ? Icons.warning_amber_rounded : Icons.info_outline, color: isSevere ? AppColors.severityHigh : AppColors.primary, size: 18),
                        const SizedBox(width: AppSpacing.xs),
                        Text(severityLabel, style: AppTypography.bodySmall.copyWith(color: isSevere ? AppColors.severityHigh : AppColors.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Recommandations
              Text('Recommandations adaptées', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Column(
                  children: [
                    _buildRecommendationRow(Icons.sanitizer_outlined, 'Traitement conseillé', _getTreatment(result.maladieDetectee)),
                    const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.sm), child: Divider(height: 1)),
                    _buildRecommendationRow(Icons.eco_outlined, 'Dosage recommandé', _getDosage(result.maladieDetectee)),
                    const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.sm), child: Divider(height: 1)),
                    _buildRecommendationRow(Icons.shield_outlined, 'Prévention', 'Éviter les excès d\'azote et maintenir un bon niveau d\'eau.'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Astuce
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(50),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Astuce', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            'Traitez de préférence tôt le matin ou en fin de journée pour éviter l\'évaporation des produits.',
                            style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.scanning),
                      icon: const Icon(Icons.refresh, color: AppColors.primary, size: 18),
                      label: Text('Refaire', style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enregistré dans le journal')));
                        context.go(AppRoutes.journal);
                      },
                      icon: const Icon(Icons.bookmark_add_outlined, color: AppColors.textOnPrimary, size: 18),
                      label: Text('Enregistrer', style: AppTypography.bodySmall.copyWith(color: AppColors.textOnPrimary, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    final text = 'Diagnostic AgriMada : ${result.maladieDetectee} détecté.';
                    Share.share(text);
                  },
                  icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary, size: 18),
                  label: Text('Partager le résultat', style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textSecondary.withAlpha(30)),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(description, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  String _getScientificName(String commonName) {
    if (commonName.toLowerCase().contains('pyriculariose') || commonName.toLowerCase().contains('blast')) return 'Magnaporthe oryzae';
    if (commonName.toLowerCase().contains('helminthosporiose') || commonName.toLowerCase().contains('brown spot')) return 'Cochliobolus miyabeanus';
    if (commonName.toLowerCase().contains('bacterial') || commonName.toLowerCase().contains('blight')) return 'Xanthomonas oryzae';
    return '';
  }

  String _getTreatment(String commonName) {
    if (commonName.toLowerCase().contains('pyriculariose') || commonName.toLowerCase().contains('blast')) return 'Fongicide systémique (Tricyclazole)';
    return 'Application de fongicide adapté';
  }

  String _getDosage(String commonName) {
    return '1 L par hectare dilué dans 200 L d\'eau';
  }
}
