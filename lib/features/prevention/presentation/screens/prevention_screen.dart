import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class PreventionScreen extends StatelessWidget {
  const PreventionScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            Text('Prévenir les maladies', style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
            Text('Prévenez vos rizicultures', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bannière "Astuce de prévention" (Orange)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5), // Pale orange
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, color: Colors.orange, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Astuce de prévention', style: AppTypography.bodyMedium.copyWith(color: Colors.orange[800], fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Découvrez les gestes essentiels pour protéger vos cultures.', style: AppTypography.caption.copyWith(color: Colors.orange[900])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Astuce du moment
            Text('Astuce du moment', style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Maintenez une bonne gestion de l\'eau', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Évitez le stress hydrique en irriguant régulièrement et en drainant à temps.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withAlpha(50),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: const Center(child: Icon(Icons.water_drop_outlined, color: AppColors.primary, size: 48)), // Placeholder pour l'image
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Pourquoi c'est efficace ?
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withAlpha(30),
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.primary.withAlpha(50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Pourquoi c\'est efficace ?', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Une humidité contrôlée freine le développement des champignons comme la pyriculariose.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Comment faire ?
            Text('Comment faire ?', style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            _buildStepItem(1, 'Drainez régulièrement', 'Ne laissez pas l\'eau stagner plus de 3 jours consécutifs.', Icons.waves),
            _buildStepItem(2, 'Fertilisation équilibrée', 'Évitez les apports excessifs d\'azote qui fragilisent la plante.', Icons.eco_outlined),
            _buildStepItem(3, 'Désherbage', 'Éliminez les mauvaises herbes qui sont des hôtes pour les maladies.', Icons.grass_outlined),
            _buildStepItem(4, 'Densité de semis', 'Respectez l\'espacement pour favoriser l\'aération entre les plants.', Icons.grid_view_outlined),
            _buildStepItem(5, 'Variétés résistantes', 'Optez pour des semences certifiées résistantes aux maladies locales.', Icons.verified_outlined),
            
            const SizedBox(height: AppSpacing.lg),

            // Bon à savoir
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 24),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bon à savoir', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(
                          'Inspectez vos parcelles au moins 2 fois par semaine en période humide.',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(int number, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
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
            const SizedBox(width: AppSpacing.sm),
            Icon(icon, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
