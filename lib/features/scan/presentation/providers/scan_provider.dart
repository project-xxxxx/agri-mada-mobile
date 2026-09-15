// Providers Riverpod pour le scan IA et la gestion des diagnostics

import 'dart:io';

import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ai/diagnosis_certainty.dart';
import '../../../../core/ai/tflite_service.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/local_db/models/diagnostic_local.dart';
import '../../data/repositories/diagnostic_local_repository.dart';
import '../../domain/entities/declared_severity.dart';
import '../../domain/entities/diagnostic_result.dart' as domain;
import '../../domain/repositories/scan_repository.dart';
import '../../../../core/providers/tflite_provider.dart';
import '../../domain/usecases/analyze_image_usecase.dart';

// Le résultat du dernier diagnostic
final lastDiagnosticResultProvider =
    StateProvider<domain.DiagnosticResult?>((ref) => null);

/// Accès au repository des diagnostics
final diagnosticRepositoryProvider = Provider<DiagnosticLocalRepository>(
  (_) => DiagnosticLocalRepository(),
);

/// Contrat domain du scan
final scanRepositoryProvider = Provider<ScanRepository>(
  (ref) => _ScanRepositoryAdapter(
    ref.watch(tfliteServiceProvider),
    ref.watch(diagnosticRepositoryProvider),
  ),
);

/// Use case d'analyse d'image
final analyzeImageUseCaseProvider = Provider<AnalyzeImageUseCase>(
  (ref) => AnalyzeImageUseCase(ref.watch(scanRepositoryProvider)),
);

/// Diagnostics d'une parcelle donnée
final diagnosticsParParcelleProvider =
    FutureProvider.family<List<DiagnosticLocal>, int>((ref, parcelleId) async {
  return ref
      .read(diagnosticRepositoryProvider)
      .getDiagnosticsByParcelle(parcelleId);
});

sealed class ScanState {
  const ScanState();

  const factory ScanState.initial() = ScanInitial;
  const factory ScanState.loading() = ScanLoading;
  const factory ScanState.success(domain.DiagnosticResult result) = ScanSuccess;
  const factory ScanState.engineUnavailable(String message) =
      ScanEngineUnavailable;
  const factory ScanState.error(String message) = ScanError;
}

class ScanInitial extends ScanState {
  const ScanInitial();
}

class ScanLoading extends ScanState {
  const ScanLoading();
}

class ScanSuccess extends ScanState {
  const ScanSuccess(this.result);

  final domain.DiagnosticResult result;
}

class ScanEngineUnavailable extends ScanState {
  const ScanEngineUnavailable(this.message);

  final String message;
}

class ScanError extends ScanState {
  const ScanError(this.message);

  final String message;
}

/// Issue d'une demande d'enregistrement du diagnostic affiché.
enum SaveOutcome { saved, notAllowed, failed }

/// Notifier principal du flux de scan
class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier(this._analyzeImage, this._scanRepository)
      : super(const ScanState.initial());

  final AnalyzeImageUseCase _analyzeImage;
  final ScanRepository _scanRepository;

  /// Analyse une image. Le résultat est affiché mais pas enregistré :
  /// l'enregistrement se fait uniquement à la demande de l'agriculteur (P1.7).
  Future<domain.DiagnosticResult?> analyzeImage(
    File imageFile, {
    int? parcelleLocalId,
  }) async {
    state = const ScanState.loading();
    final result = await _analyzeImage(imageFile.path);

    return result.fold((failure) {
      state = switch (failure) {
        ValidationFailure() => ScanState.error(failure.message),
        NetworkFailure() =>
          const ScanState.engineUnavailable('Moteur IA non disponible'),
        _ => const ScanState.error('Erreur pendant le diagnostic IA'),
      };
      return null;
    }, (diagnostic) {
      final withPlot =
          diagnostic.copyWith(parcelleId: parcelleLocalId?.toString());
      state = ScanState.success(withPlot);
      return withPlot;
    });
  }

  /// Enregistre le diagnostic affiché, avec la part de parcelle touchée
  /// déclarée par l'agriculteur. Un résultat incertain n'est jamais enregistré.
  Future<SaveOutcome> saveCurrent({DeclaredSeverity? severity}) async {
    final current = state;
    if (current is! ScanSuccess) return SaveOutcome.notAllowed;

    final result = current.result;
    if (result.certitude == DiagnosisCertainty.incertain ||
        result.parcelleId == null) {
      return SaveOutcome.notAllowed;
    }

    final saved = await _scanRepository.save(
      result.copyWith(niveauGravite: severity?.code),
    );
    return saved.isRight() ? SaveOutcome.saved : SaveOutcome.failed;
  }

  /// Écarte le résultat affiché sans rien enregistrer.
  void reset() {
    state = const ScanState.initial();
  }
}

class _ScanRepositoryAdapter implements ScanRepository {
  _ScanRepositoryAdapter(this._tfliteService, this._repository);

  final TFLiteService _tfliteService;
  final DiagnosticLocalRepository _repository;

  @override
  Future<fpdart.Either<Failure, domain.DiagnosticResult>> analyze(
    String imagePath,
  ) async {
    if (!_tfliteService.isReady) {
      return const fpdart.Left(NetworkFailure('Moteur IA non disponible'));
    }

    try {
      final result = await _tfliteService.analyzeImage(File(imagePath));
      return fpdart.Right(diagnosticFromInference(result, imagePath));
    } catch (e) {
      return fpdart.Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, List<domain.DiagnosticResult>>> getAll() {
    return _repository.getAll();
  }

  @override
  Future<fpdart.Either<Failure, fpdart.Unit>> save(
    domain.DiagnosticResult result,
  ) {
    return _repository.save(result);
  }
}

final scanNotifierProvider = StateNotifierProvider<ScanNotifier, ScanState>(
  (ref) => ScanNotifier(
    ref.watch(analyzeImageUseCaseProvider),
    ref.watch(scanRepositoryProvider),
  ),
);
