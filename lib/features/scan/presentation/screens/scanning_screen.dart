import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/providers/tflite_provider.dart';
import '../../../journal/presentation/providers/journal_provider.dart';
import '../../../../core/local_db/models/parcelle_local.dart';
import '../providers/scan_provider.dart';

class ScanningScreen extends ConsumerStatefulWidget {
  const ScanningScreen({super.key});

  @override
  ConsumerState<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends ConsumerState<ScanningScreen> {
  final _picker = ImagePicker();
  ParcelleLocal? _selectedParcelle;
  bool _isPickerActive = false;

  @override
  void initState() {
    super.initState();
    // Auto-lancer le sélecteur de parcelle puis la caméra pour une UX fluide si on a la db prête
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStart();
    });
  }

  Future<void> _checkAndStart() async {
    final parcelles = await ref.read(parcelleRepositoryProvider).getAllParcelles();
    if (!mounted) return;
    
    if (parcelles.isEmpty) {
      _showNoParcelleDailog();
      return;
    }
    
    if (_selectedParcelle == null) {
      final selected = await _showParcelleSelector(parcelles);
      if (selected == null) {
        if (mounted) context.go(AppRoutes.home);
        return;
      }
      setState(() => _selectedParcelle = selected);
      _pickAndAnalyze(ImageSource.camera);
    }
  }

  Future<bool> _ensureAiReady() async {
    final bootReady = ref.read(isTFLiteReadyProvider);
    final tflite = ref.read(tfliteServiceProvider);

    if (bootReady || tflite.isReady) return true;

    try {
      await tflite.init();
    } catch (e, st) {
      AppLogger.error('Echec re-initialisation TFLite depuis Scan', error: e, stackTrace: st);
    }

    return tflite.isReady;
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    if (_isPickerActive) return;
    
    final loc = AppLocalizations.of(context);
    final isAiReady = await _ensureAiReady();
    if (!isAiReady) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.scanIaUnavailable)));
      return;
    }

    if (_selectedParcelle == null) return;

    setState(() => _isPickerActive = true);
    
    try {
      final xFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      
      if (xFile == null) {
        setState(() => _isPickerActive = false);
        return;
      }
      
      final imageFile = File(xFile.path);

      if (!mounted) return;
      final result = await ref.read(scanNotifierProvider.notifier).analyzeImage(imageFile);
      
      if (result == null) {
        setState(() => _isPickerActive = false);
        return;
      }

      await ref.read(scanNotifierProvider.notifier).saveDiagnostic(
            parcelleLocalId: _selectedParcelle!.id,
            result: result,
            imagePath: xFile.path,
          );

      if (!mounted) return;
      context.go(AppRoutes.scanResult);
    } finally {
      if (mounted) setState(() => _isPickerActive = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanNotifierProvider);
    final isLoading = scanState is ScanLoading;

    return Scaffold(
      backgroundColor: Colors.black, // Simule l'arrière-plan de la caméra
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background cliquable pour relancer la caméra si l'utilisateur a annulé le picker natif
          GestureDetector(
            onTap: () {
              if (!isLoading) _pickAndAnalyze(ImageSource.camera);
            },
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: _CameraViewfinder(isLoading: isLoading),
              ),
            ),
          ),
          
          // Bouton Annuler en bas
          if (!isLoading)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.home),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(200),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'ANNULER',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showNoParcelleDailog() {
    final loc = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(loc.scanNoPlotTitle),
        content: Text(loc.scanNoPlotDescription),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.home);
            },
            child: Text(loc.commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.myParcelles); // Redirige vers Mes Parcelles pour en créer une
            },
            child: const Text('Créer une parcelle'),
          ),
        ],
      ),
    );
  }

  Future<ParcelleLocal?> _showParcelleSelector(List<ParcelleLocal> parcelles) {
    return showModalBottomSheet<ParcelleLocal>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              const Text('Sélectionnez la parcelle', style: AppTypography.headlineMedium),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: parcelles.length,
                  itemBuilder: (context, index) {
                    final p = parcelles[index];
                    return ListTile(
                      leading: const Icon(Icons.map_outlined, color: AppColors.primary),
                      title: Text(p.nomParcelle, style: AppTypography.bodyMedium),
                      subtitle: p.description != null ? Text(p.description!) : null,
                      onTap: () => Navigator.of(context).pop(p),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CameraViewfinder extends StatelessWidget {
  const _CameraViewfinder({required this.isLoading});
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(200), width: 3),
      ),
      child: isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Analyse en cours...', style: TextStyle(color: Colors.white)),
                ],
              ),
            )
          : const Center(
              child: Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 48),
            ),
    );
  }
}
