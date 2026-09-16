// Repository local - Gestion des parcelles dans Isar (hors-ligne)

import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';

import '../../../../core/ai/diagnosis_certainty.dart';
import '../../../../core/ai/disease_catalog.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/local_db/isar_service.dart';
import '../../../../core/local_db/models/parcelle_local.dart';
import '../../../../core/local_db/models/diagnostic_local.dart';
import '../../../../core/utils/client_uuid.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/parcelle_entity.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';

class ParcelleLocalRepository implements JournalRepository {
  Isar get _db => IsarService.instance.db;

  // --- Lecture ---

  Future<List<ParcelleLocal>> getAllParcelles() {
    return _db.parcelleLocals.where().findAll();
  }

  @override
  Future<Either<Failure, List<ParcelleEntity>>> getParcelles() async {
    try {
      final parcelles = await getAllParcelles();
      final allDiagnostics = await _db.diagnosticLocals
          .where()
          .sortByDateDiagnosticDesc()
          .findAll();

      final latestDiagsMap = <int, DiagnosticLocal>{};
      for (final diag in allDiagnostics) {
        latestDiagsMap.putIfAbsent(diag.parcelleLocalId, () => diag);
      }

      final entities = <ParcelleEntity>[];

      for (final parcelle in parcelles) {
        final latestDiagnostic = latestDiagsMap[parcelle.id];

        entities.add(
          ParcelleEntity(
            id: parcelle.id.toString(),
            nom: parcelle.nomParcelle,
            description: parcelle.description,
            surface: parcelle.surface,
            culture: parcelle.culture ?? 'Riz',
            lastDiagnosticDate: latestDiagnostic?.dateDiagnostic,
            isSynced: parcelle.isSynced,
            photoPath: parcelle.photoPath,
          ),
        );
      }

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<ParcelleLocal?> getParcelleById(int id) {
    return _db.parcelleLocals.get(id);
  }

  /// Récupère les parcelles non encore synchronisées avec le serveur
  Future<List<ParcelleLocal>> getUnsyncedParcelles() {
    return _db.parcelleLocals.filter().isSyncedEqualTo(false).findAll();
  }

  // --- Écriture ---

  /// Crée une parcelle et la renvoie avec l'identifiant attribué par Isar
  /// lors du `put` (tâche P1.9 : plus de relecture de « la dernière parcelle »).
  Future<ParcelleLocal> createParcelle({
    required String nomParcelle,
    String? description,
    String? culture,
    double? surface,
    double? latitude,
    double? longitude,
    String? photoPath,
  }) async {
    final parcelle = ParcelleLocal()
      ..clientUuid = generateClientUuid()
      ..nomParcelle = nomParcelle
      ..description = description
      ..culture = culture
      ..surface = surface
      ..latitude = latitude
      ..longitude = longitude
      ..photoPath = photoPath
      ..createdAt = DateTime.now()
      ..isSynced = false;

    await _db.writeTxn(() => _db.parcelleLocals.put(parcelle));
    return parcelle;
  }

  @override
  Future<Either<Failure, Unit>> saveParcelle(ParcelleEntity parcelle) async {
    try {
      final parsedId = int.tryParse(parcelle.id);
      final existing =
          parsedId == null ? null : await _db.parcelleLocals.get(parsedId);

      // Une mise à jour part de l'enregistrement existant : la position GPS,
      // l'identifiant serveur et la date de création ne sont pas écrasés.
      final localParcelle = (existing ?? (ParcelleLocal()..createdAt = DateTime.now()))
        ..nomParcelle = parcelle.nom
        ..description = parcelle.description
        ..culture = parcelle.culture
        ..surface = parcelle.surface
        ..photoPath = parcelle.photoPath
        ..isSynced = parcelle.isSynced;

      await _db.writeTxn(() => _db.parcelleLocals.put(localParcelle));
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Renvoie l'identifiant client de la parcelle, en l'attribuant d'abord
  /// aux parcelles créées avant son introduction.
  Future<String> ensureClientUuid(ParcelleLocal parcelle) async {
    final existing = parcelle.clientUuid;
    if (existing != null) return existing;
    final generated = generateClientUuid();
    parcelle.clientUuid = generated;
    await _db.writeTxn(() => _db.parcelleLocals.put(parcelle));
    return generated;
  }

  Future<void> markAsSynced(int localId, int serverId) async {
    final parcelle = await _db.parcelleLocals.get(localId);
    if (parcelle != null) {
      parcelle
        ..isSynced = true
        ..serverId = serverId;
      await _db.writeTxn(() => _db.parcelleLocals.put(parcelle));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteParcelle(String id) async {
    final parsedId = int.tryParse(id);
    if (parsedId == null) {
      return const Left(ValidationFailure('Identifiant parcelle invalide'));
    }

    try {
      await deleteParcelleById(parsedId);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Supprime une parcelle avec ses diagnostics et les photos associées
  /// (tâche P1.9 : plus de diagnostics orphelins).
  Future<void> deleteParcelleById(int id) async {
    final parcelle = await _db.parcelleLocals.get(id);
    final diagnostics = await _db.diagnosticLocals
        .filter()
        .parcelleLocalIdEqualTo(id)
        .findAll();

    await _db.writeTxn(() async {
      await _db.diagnosticLocals
          .deleteAll(diagnostics.map((diagnostic) => diagnostic.id).toList());
      await _db.parcelleLocals.delete(id);
    });

    final photoPaths = <String?>[
      parcelle?.photoPath,
      for (final diagnostic in diagnostics) diagnostic.imagePath,
    ];
    for (final path in photoPaths.whereType<String>()) {
      await _deleteFileQuietly(path);
    }
  }

  Future<void> _deleteFileQuietly(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e, st) {
      AppLogger.error('Suppression de photo impossible', error: e, stackTrace: st);
    }
  }

  /// Construit le journal agricole : chaque parcelle avec son statut de santé
  Future<List<JournalEntry>> getJournalAgricole() async {
    final parcelles = await getAllParcelles();
    final allDiagnostics = await _db.diagnosticLocals
        .where()
        .sortByDateDiagnosticDesc()
        .findAll();

    final diagMap = <int, List<DiagnosticLocal>>{};
    for (final diag in allDiagnostics) {
      diagMap.putIfAbsent(diag.parcelleLocalId, () => []).add(diag);
    }

    final journal = <JournalEntry>[];

    for (final parcelle in parcelles) {
      // Récupère les diagnostics de cette parcelle via la map
      final diagnostics = diagMap[parcelle.id] ?? [];

      final nb = diagnostics.length;
      final dernierDiag = nb > 0 ? diagnostics.first : null;
      final derniereMaladie = dernierDiag?.maladieDetectee;
      final statut = switch (dernierDiag) {
        null => 'aucun_diagnostic',
        final diag when DiseaseCatalog.isHealthy(diag.maladieDetectee) => 'sain',
        // Seul un diagnostic « probable » classe la parcelle malade : une piste
        // du modèle reste à confirmer (P1.2, évaluation du 2026-09-16).
        final diag when diag.certitude == DiagnosisCertainty.probable.name => 'malade',
        _ => 'a_confirmer',
      };

      journal.add(JournalEntry(
        parcelle: parcelle,
        nbDiagnostics: nb,
        derniereMaladie: derniereMaladie,
        dernierDiagnostic: dernierDiag,
        statut: statut,
      ));
    }

    return journal;
  }
}
