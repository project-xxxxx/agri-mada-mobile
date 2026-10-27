// Prise de vue guidée et contrôle de qualité (tâche P2.2).
//
// Aperçu en direct avec un cadre adapté à l'organe quand l'appareil a une
// caméra ; sinon l'appareil photo du système prend le relais, ce qui permet
// aussi de dérouler le parcours en test.
//
// Une photo floue ou à contre-jour est refusée avec une consigne précise : elle
// n'est ni analysée ni enregistrée.

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/logger.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/organe.dart';
import '../organ_labels.dart';
import '../photo_quality_labels.dart';
import '../providers/session_scan_provider.dart';

/// Caméras de l'appareil ; liste vide sur un poste sans caméra ou en test.
final camerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  try {
    return await availableCameras();
  } catch (e, st) {
    AppLogger.error('Caméra indisponible', error: e, stackTrace: st);
    return const [];
  }
});

/// Prise de vue de secours, par l'appareil photo du système.
final fallbackPhotoProvider = Provider<Future<XFile?> Function()>(
  (ref) => () => ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1600,
      ),
);

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  CameraController? _controleur;
  bool _preparationCamera = false;

  @override
  void dispose() {
    _controleur?.dispose();
    super.dispose();
  }

  Future<void> _preparerCamera(List<CameraDescription> cameras) async {
    if (_preparationCamera || _controleur != null || cameras.isEmpty) return;
    _preparationCamera = true;

    final controleur = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await controleur.initialize();
      if (!mounted) {
        await controleur.dispose();
        return;
      }
      setState(() => _controleur = controleur);
    } catch (e, st) {
      AppLogger.error('Aperçu caméra impossible', error: e, stackTrace: st);
      await controleur.dispose();
    } finally {
      _preparationCamera = false;
    }
  }

  Future<void> _capturer() async {
    final notifier = ref.read(scanSessionProvider.notifier);
    final controleur = _controleur;

    XFile? photo;
    try {
      photo = controleur != null && controleur.value.isInitialized
          ? await controleur.takePicture()
          : await ref.read(fallbackPhotoProvider)();
    } catch (e, st) {
      AppLogger.error('Prise de vue impossible', error: e, stackTrace: st);
    }
    if (photo == null) return;

    await notifier.ajouterPhoto(File(photo.path));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final etat = ref.watch(scanSessionProvider);
    final organe = etat.organe;

    if (organe == null) {
      // Session perdue (redémarrage de l'app) : on repart du choix de l'organe.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.scanOrgane);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final cameras = ref.watch(camerasProvider);
    cameras.whenData(_preparerCamera);
    final photos = etat.photosDe(organe);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          organeLabelBilingue(organe, loc),
          style: AppTypography.headlineMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: loc.commonCancel,
          onPressed: () => context.go(AppRoutes.scanOrgane),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(captureHint(organe, loc), style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          _Cadre(organe: organe, controleur: _controleur, loc: loc),
          const SizedBox(height: AppSpacing.md),
          if (etat.dernierRefus != null)
            _Refus(message: photoQualityMessage(etat.dernierRefus!, loc)),
          if (photos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                loc.scanCapturePhotos(photos.length, photosMaxParOrgane),
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ),
          if (etat.peutAjouterPhoto)
            ElevatedButton.icon(
              onPressed: etat.enCours ? null : _capturer,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(photos.isEmpty ? loc.scanCaptureTake : loc.scanCaptureAnother),
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
            onPressed: photos.isEmpty || etat.enCours
                ? null
                : () {
                    ref.read(scanSessionProvider.notifier).passerAuxQuestions();
                    context.go(AppRoutes.scanQuestions);
                  },
            icon: const Icon(Icons.arrow_forward),
            label: Text(loc.scanCaptureContinue),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _Cadre extends StatelessWidget {
  const _Cadre({required this.organe, required this.controleur, required this.loc});

  final Organe organe;
  final CameraController? controleur;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final pret = controleur != null && controleur!.value.isInitialized;

    // L'aperçu ne prend jamais plus de la moitié de l'écran : sur un petit
    // téléphone, le bouton de prise de vue doit rester visible (P1.10).
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.45,
      ),
      child: AspectRatio(
        aspectRatio: organe.ratioCadre,
        child: _cadre(pret),
      ),
    );
  }

  Widget _cadre(bool pret) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.primary, width: 3),
        ),
        clipBehavior: Clip.antiAlias,
        child: pret
            ? CameraPreview(controleur!)
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_camera_outlined,
                          size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        loc.scanCameraUnavailable,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

class _Refus extends StatelessWidget {
  const _Refus({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.severityHigh.withAlpha(25),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.severityHigh.withAlpha(90)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.severityHigh),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
