import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../providers/journal_provider.dart';

class AddParcelleSheet extends ConsumerStatefulWidget {
  const AddParcelleSheet({super.key, required this.onSaved});
  final VoidCallback onSaved;

  @override
  ConsumerState<AddParcelleSheet> createState() => _AddParcelleSheetState();
}

class _AddParcelleSheetState extends ConsumerState<AddParcelleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _cultureController = TextEditingController();
  final _surfaceController = TextEditingController();
  final _emplacementController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _selectedPhoto;

  @override
  void dispose() {
    _nomController.dispose();
    _cultureController.dispose();
    _surfaceController.dispose();
    _emplacementController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final xFile = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 800);
    if (xFile != null && mounted) {
      setState(() => _selectedPhoto = xFile);
    }
  }

  Future<String?> _savePhotoLocally() async {
    if (_selectedPhoto == null) return null;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${dir.path}/parcelle_photos');
      if (!await photosDir.exists()) await photosDir.create(recursive: true);

      final fileName = 'parcelle_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = File('${photosDir.path}/$fileName');
      await File(_selectedPhoto!.path).copy(savedFile.path);
      return savedFile.path;
    } catch (e) {
      return null;
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final photoPath = await _savePhotoLocally();

    await ref.read(parcelleNotifierProvider.notifier).createParcelle(
          nom: _nomController.text.trim(),
          description: _emplacementController.text.trim().isEmpty
              ? null
              : _emplacementController.text.trim(),
          surface: double.tryParse(_surfaceController.text.trim()),
          photoPath: photoPath,
        );
    widget.onSaved();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parcelleNotifierProvider);
    final isLoading = state is AsyncLoading;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md,
          AppSpacing.md + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.textSecondary.withAlpha(100),
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: AppSpacing.md),

              Text('Ajouter une parcelle', style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
              Text('Nouvelle parcelle', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.lg),

              Text('Photo de la parcelle', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.xs),
              GestureDetector(
                onTap: _pickPhoto,
                child: CustomPaint(
                  painter: _DashedBorderPainter(color: AppColors.primary, strokeWidth: 1.5, dashWidth: 6, dashSpace: 4),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withAlpha(30),
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                    child: _selectedPhoto != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                            child: Image.file(
                              File(_selectedPhoto!.path),
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text('Ajouter une photo', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('Uploadez une photo de votre parcelle', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                  ),
                ),
              ),
              if (_selectedPhoto != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(() => _selectedPhoto = null),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Retirer la photo'),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),

              _buildLabel('Nom de la parcelle'),
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  hintText: 'Nom de la parcelle (ex: Parcelle Sud)',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary.withAlpha(150)),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    borderSide: BorderSide(color: AppColors.textSecondary.withAlpha(50)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    borderSide: BorderSide(color: AppColors.textSecondary.withAlpha(50)),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              _buildLabel('Culture'),
              TextFormField(
                controller: _cultureController,
                decoration: InputDecoration(
                  hintText: 'Riz',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary.withAlpha(150)),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    borderSide: BorderSide(color: AppColors.textSecondary.withAlpha(50)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    borderSide: BorderSide(color: AppColors.textSecondary.withAlpha(50)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildLabel('Surface cultivée'),
              TextFormField(
                controller: _surfaceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Hectares (0,55)',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary.withAlpha(150)),
                  suffixText: 'Hectares',
                  suffixStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    borderSide: BorderSide(color: AppColors.textSecondary.withAlpha(50)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    borderSide: BorderSide(color: AppColors.textSecondary.withAlpha(50)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildLabel('Emplacement'),
              TextFormField(
                controller: _emplacementController,
                decoration: InputDecoration(
                  hintText: 'Zone, détails, etc.',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary.withAlpha(150)),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    borderSide: BorderSide(color: AppColors.textSecondary.withAlpha(50)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    borderSide: BorderSide(color: AppColors.textSecondary.withAlpha(50)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text('Annuler', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Enregistrer', style: AppTypography.bodyMedium.copyWith(color: AppColors.textOnPrimary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final RRect rrect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(AppSpacing.cardRadius));
    path.addRRect(rrect);

    final dashPath = Path();
    var distance = 0.0;
    for (var pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
      distance = 0.0;
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
