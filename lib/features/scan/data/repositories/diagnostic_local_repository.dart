// Repository local - Gestion des diagnostics dans Isar (hors-ligne)

import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';

import '../../../../core/ai/diagnosis_certainty.dart';
import '../../../../core/ai/tflite_service.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/local_db/isar_service.dart';
import '../../../../core/local_db/models/diagnostic_local.dart';
import '../../../../core/utils/client_uuid.dart';
import '../../domain/entities/diagnostic_result.dart' as domain;
import '../../domain/repositories/scan_repository.dart';

/// Convertit un résultat d'inférence en entité domain, sans gravité ni conseil :
/// la gravité est déclarée par l'agriculteur et les conseils viennent du
/// catalogue des maladies.
domain.DiagnosticResult diagnosticFromInference(
  TFLiteInferenceResult result,
  String imagePath,
) {
  return domain.DiagnosticResult(
    culture: 'Riz',
    maladieDetectee: result.maladieDetectee,
    confiance: result.confiance,
    imagePath: imagePath,
    createdAt: DateTime.now(),
    certitude: result.certitude,
    classement: result.classement,
  );
}

class DiagnosticLocalRepository implements ScanRepository {
  DiagnosticLocalRepository({TFLiteService? tfliteService})
      : _tfliteService = tfliteService ?? TFLiteService.instance;

  final TFLiteService _tfliteService;

  Isar get _db => IsarService.instance.db;

  // --- Lecture ---

  Future<List<DiagnosticLocal>> getDiagnosticsByParcelle(int parcelleLocalId) {
    return _db.diagnosticLocals
        .filter()
        .parcelleLocalIdEqualTo(parcelleLocalId)
        .sortByDateDiagnosticDesc()
        .findAll();
  }

  Future<List<DiagnosticLocal>> getAllDiagnostics() {
    return _db.diagnosticLocals.where().sortByDateDiagnosticDesc().findAll();
  }

  @override
  Future<Either<Failure, List<domain.DiagnosticResult>>> getAll() async {
    try {
      final diagnostics = await getAllDiagnostics();
      return Right(diagnostics.map(_toDomainEntity).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<DiagnosticLocal?> getLatestDiagnostic() {
    return _db.diagnosticLocals.where().sortByDateDiagnosticDesc().findFirst();
  }

  /// Récupère les diagnostics non encore synchronisés avec le serveur
  Future<List<DiagnosticLocal>> getUnsyncedDiagnostics() {
    return _db.diagnosticLocals.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<Either<Failure, domain.DiagnosticResult>> analyze(
    String imagePath,
  ) async {
    try {
      final result = await _tfliteService.analyzeImage(File(imagePath));
      return Right(diagnosticFromInference(result, imagePath));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // --- Écriture ---

  Future<DiagnosticLocal> saveDiagnostic({
    required int parcelleLocalId,
    required String maladieDetectee,
    double? confiance,
    String? niveauGravite,
    String? certitude,
    String? recommandations,
    String? imagePath,
    int? inferenceTimeMs,
  }) async {
    final diagnostic = DiagnosticLocal()
      ..clientUuid = generateClientUuid()
      ..parcelleLocalId = parcelleLocalId
      ..maladieDetectee = maladieDetectee
      ..confiance = confiance
      ..niveauGravite = niveauGravite
      ..certitude = certitude
      ..recommandations = recommandations
      ..imagePath = imagePath
      ..inferenceTimeMs = inferenceTimeMs
      ..dateDiagnostic = DateTime.now()
      ..isSynced = false;

    await _db.writeTxn(() => _db.diagnosticLocals.put(diagnostic));
    return diagnostic;
  }

  @override
  Future<Either<Failure, Unit>> save(domain.DiagnosticResult result) async {
    final parcelleId = int.tryParse(result.parcelleId ?? '');
    if (parcelleId == null) {
      return const Left(ValidationFailure('Parcelle requise'));
    }
    if (result.certitude == DiagnosisCertainty.incertain) {
      return const Left(
        ValidationFailure('Un résultat incertain n\'est pas enregistré'),
      );
    }

    try {
      await saveDiagnostic(
        parcelleLocalId: parcelleId,
        maladieDetectee: result.maladieDetectee,
        confiance: result.confiance,
        niveauGravite: result.niveauGravite,
        certitude: result.certitude.name,
        imagePath: result.imagePath,
        inferenceTimeMs: _tfliteService.lastInferenceTimeMs,
      );
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Renvoie l'identifiant client du diagnostic, en l'attribuant d'abord
  /// aux diagnostics créés avant son introduction.
  Future<String> ensureClientUuid(DiagnosticLocal diagnostic) async {
    final existing = diagnostic.clientUuid;
    if (existing != null) return existing;
    final generated = generateClientUuid();
    diagnostic.clientUuid = generated;
    await _db.writeTxn(() => _db.diagnosticLocals.put(diagnostic));
    return generated;
  }

  Future<void> markAsSynced(int localId, int serverId) async {
    final diag = await _db.diagnosticLocals.get(localId);
    if (diag != null) {
      diag
        ..isSynced = true
        ..serverId = serverId;
      await _db.writeTxn(() => _db.diagnosticLocals.put(diag));
    }
  }

  Future<void> deleteDiagnostic(int id) async {
    await _db.writeTxn(() => _db.diagnosticLocals.delete(id));
  }

  domain.DiagnosticResult _toDomainEntity(DiagnosticLocal diagnostic) {
    return domain.DiagnosticResult(
      id: diagnostic.id.toString(),
      culture: 'Riz',
      maladieDetectee: diagnostic.maladieDetectee,
      confiance: diagnostic.confiance ?? 0,
      imagePath: diagnostic.imagePath,
      createdAt: diagnostic.dateDiagnostic,
      parcelleId: diagnostic.parcelleLocalId.toString(),
      niveauGravite: diagnostic.niveauGravite,
      // Les diagnostics antérieurs n'ont pas de certitude enregistrée.
      certitude: DiagnosisCertainty.fromName(diagnostic.certitude) ??
          DiagnosisCertainty.possible,
      recommandations: _decodeRecommandations(diagnostic.recommandations),
    );
  }

  List<String> _decodeRecommandations(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const <String>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((item) => item.toString()).toList();
      }
    } on FormatException {
      // Anciennes données enregistrées en texte brut.
    }
    return raw.split('\n').where((line) => line.trim().isNotEmpty).toList();
  }
}
