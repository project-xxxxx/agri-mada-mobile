import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:agri_mada/l10n/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/number_parsing.dart';
import '../../domain/entities/contexte_parcelle.dart';
import '../../domain/entities/regions_madagascar.dart';
import '../../domain/entities/varietes_riz.dart';
import '../contexte_labels.dart';
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

  // Contexte de culture (tâche P2.5) : tout est facultatif.
  bool _surfaceEnAres = false;
  Ecosysteme? _ecosysteme;
  String? _region;
  TrancheAltitude? _altitude;
  String? _variete;
  SaisonRiz? _saison;
  DateTime? _dateRepiquage;

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
      builder: (context) {
        final loc = AppLocalizations.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(loc.plotPhotoTake),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(loc.plotPhotoGallery),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
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
    final loc = AppLocalizations.of(context);

    final photoPath = await _savePhotoLocally();
    final location = _emplacementController.text.trim();
    final culture = _cultureController.text.trim();

    // La surface accepte « 0,55 » comme « 0.55 » (tâche P1.6).
    final parcelle = await ref.read(parcelleNotifierProvider.notifier).createParcelle(
          nom: _nomController.text.trim(),
          description: location.isEmpty ? null : location,
          culture: culture.isEmpty ? null : culture,
          surface: parseSurfaceEnHectares(
            _surfaceController.text,
            enAres: _surfaceEnAres,
          ),
          photoPath: photoPath,
          ecosysteme: _ecosysteme?.code,
          region: _region,
          altitudeTranche: _altitude?.code,
          variete: _variete,
          saison: _saison?.code,
          dateRepiquage: _dateRepiquage,
        );

    if (!mounted) return;
    if (parcelle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.plotSaveFailed)),
      );
      return;
    }
    widget.onSaved();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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

              Text(loc.journalAddPlot, style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
              Text(loc.journalNewPlot, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.lg),

              Text(loc.plotPhotoLabel, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
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
                              Text(loc.plotPhotoAdd, style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(loc.plotPhotoHint, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
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
                    label: Text(loc.plotPhotoRemove),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),

              _buildLabel(loc.plotNameLabel),
              TextFormField(
                controller: _nomController,
                decoration: _inputDecoration(loc.plotNameHint),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? loc.journalNameRequired : null,
              ),
              const SizedBox(height: AppSpacing.md),

              _buildLabel(loc.plotCropLabel),
              TextFormField(
                controller: _cultureController,
                decoration: _inputDecoration(loc.plotCropHint),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildLabel(loc.plotSurfaceLabel),
              TextFormField(
                controller: _surfaceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(loc.plotSurfaceHint),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return null;
                  return parseLocalizedDecimal(text) == null ? loc.plotSurfaceInvalid : null;
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              // Beaucoup de parcelles font quelques ares : on évite « 0,05 ha ».
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: false, label: Text(loc.plotSurfaceUnitHectare)),
                  ButtonSegment(value: true, label: Text(loc.plotSurfaceUnitAre)),
                ],
                selected: {_surfaceEnAres},
                onSelectionChanged: (choix) =>
                    setState(() => _surfaceEnAres = choix.first),
                showSelectedIcon: false,
              ),
              const SizedBox(height: AppSpacing.md),

              _buildLabel(loc.plotLocationLabel),
              TextFormField(
                controller: _emplacementController,
                decoration: _inputDecoration(loc.plotLocationHint),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(loc.plotContextTitle,
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              Text(loc.plotContextOptional,
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.md),

              _buildLabel(loc.plotEcosystemLabel),
              DropdownButtonFormField<Ecosysteme>(
                initialValue: _ecosysteme,
                decoration: _inputDecoration(loc.plotEcosystemLabel),
                items: [
                  for (final ecosysteme in Ecosysteme.values)
                    DropdownMenuItem(
                      value: ecosysteme,
                      child: Text(ecosystemeLabel(ecosysteme, loc)),
                    ),
                ],
                onChanged: (valeur) => setState(() => _ecosysteme = valeur),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildLabel(loc.plotRegionLabel),
              DropdownButtonFormField<String>(
                initialValue: _region,
                isExpanded: true,
                decoration: _inputDecoration(loc.plotRegionLabel),
                items: [
                  for (final region in regionsMadagascar)
                    DropdownMenuItem(value: region, child: Text(region)),
                ],
                onChanged: (valeur) => setState(() => _region = valeur),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildLabel(loc.plotAltitudeLabel),
              DropdownButtonFormField<TrancheAltitude>(
                initialValue: _altitude,
                decoration: _inputDecoration(loc.plotAltitudeLabel),
                items: [
                  for (final tranche in TrancheAltitude.values)
                    DropdownMenuItem(
                      value: tranche,
                      child: Text(altitudeLabel(tranche, loc)),
                    ),
                ],
                onChanged: (valeur) => setState(() => _altitude = valeur),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildLabel(loc.plotVarietyLabel),
              DropdownButtonFormField<String>(
                initialValue: _variete ?? varieteLocaleOuInconnue,
                isExpanded: true,
                decoration: _inputDecoration(loc.plotVarietyLabel),
                items: [
                  DropdownMenuItem(
                    value: varieteLocaleOuInconnue,
                    child: Text(loc.varietyLocalUnknown),
                  ),
                  for (final variete in varietesRiz)
                    DropdownMenuItem(value: variete, child: Text(variete)),
                ],
                onChanged: (valeur) => setState(() => _variete = valeur),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildLabel(loc.plotSeasonLabel),
              DropdownButtonFormField<SaisonRiz>(
                initialValue: _saison,
                decoration: _inputDecoration(loc.plotSeasonLabel),
                items: [
                  for (final saison in SaisonRiz.values)
                    DropdownMenuItem(
                      value: saison,
                      child: Text(saisonLabel(saison, loc)),
                    ),
                ],
                onChanged: (valeur) => setState(() => _saison = valeur),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildLabel(loc.plotTransplantDateLabel),
              OutlinedButton.icon(
                onPressed: _choisirDateRepiquage,
                icon: const Icon(Icons.event_outlined),
                label: Text(
                  _dateRepiquage == null
                      ? loc.plotTransplantDateChoose
                      : _formatDate(_dateRepiquage!),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(color: AppColors.textSecondary.withAlpha(50)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm)),
                ),
              ),
              Text(loc.plotTransplantDateHint,
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
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
                      child: Text(loc.commonCancel, style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
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
                          : Text(loc.commonSave, style: AppTypography.bodyMedium.copyWith(color: AppColors.textOnPrimary, fontWeight: FontWeight.w600)),
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

  Future<void> _choisirDateRepiquage() async {
    final aujourdhui = DateTime.now();
    final choisie = await showDatePicker(
      context: context,
      initialDate: _dateRepiquage ?? aujourdhui,
      firstDate: DateTime(aujourdhui.year - 2),
      lastDate: aujourdhui,
    );
    if (choisie != null && mounted) setState(() => _dateRepiquage = choisie);
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
