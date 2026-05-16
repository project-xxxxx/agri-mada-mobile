import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class GuidesScreen extends StatelessWidget {
  const GuidesScreen({super.key});

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
            Text('Solutions agricoles', style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
            Text('Un riziculture durable', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bannière Solutions agricoles (Vert clair)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withAlpha(50),
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
                    child: const Icon(Icons.science_outlined, color: AppColors.primary, size: 24), // Fiole/Plante
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Solutions agricoles', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Explorez les traitements et engrais recommandés.', style: AppTypography.caption.copyWith(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Notre approche
            Text('Notre approche', style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
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
                  Text('Pourquoi utiliser des solutions agricoles ?', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Une approche combinant méthodes biologiques et traitements raisonnés garantit des rendements durables.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withAlpha(30),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: const Center(child: Icon(Icons.grass_outlined, color: AppColors.primary, size: 48)), // Placeholder
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Nos catégories de solutions
            Text('Nos catégories de solutions', style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            _buildCategoryItem(1, 'Solutions biologiques', 'Traitements naturels et bio-contrôle.', Icons.eco_outlined),
            _buildCategoryItem(2, 'Fertilisation optimale', 'Apports NPK et micro-éléments.', Icons.science_outlined),
            _buildCategoryItem(3, 'Protection préventive', 'Fongicides et insecticides raisonnés.', Icons.shield_outlined),
            _buildCategoryItem(4, 'Amendements de sol', 'Amélioration de la structure et pH.', Icons.layers_outlined),
            
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
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 24),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Conseil expert', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(
                          'Testez toujours un nouveau traitement sur une petite parcelle avant de le généraliser.',
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

  Widget _buildCategoryItem(int number, String title, String description, IconData icon) {
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: AppColors.primary, size: 20),
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
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 24),
          ],
        ),
      ),
    );
  }
}
