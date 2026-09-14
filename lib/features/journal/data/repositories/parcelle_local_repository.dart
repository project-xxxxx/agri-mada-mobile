// Repository local - Gestion des parcelles dans Isar (hors-ligne)

import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/local_db/isar_service.dart';
import '../../../../core/local_db/models/parcelle_local.dart';
import '../../../../core/local_db/models/diagnostic_local.dart';
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
            surface: parcelle.surface,
            culture: 'Riz',
            lastDiagnosticDate: latestDiagnostic?.dateDiagnostic,
            isSynced: parcelle.isSynced,
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

  Future<ParcelleLocal> createParcelle({
    required String nomParcelle,
    String? description,
    double? surface,
    double? latitude,
    double? longitude,
    String? photoPath,
  }) async {
    final parcelle = ParcelleLocal()
      ..nomParcelle = nomParcelle
      ..description = description
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
      DateTime createdAt = DateTime.now();

      if (parsedId != null) {
        final existing = await _db.parcelleLocals.get(parsedId);
        if (existing != null) {
          createdAt = existing.createdAt;
        }
      }

      final localParcelle = ParcelleLocal()
        ..id = parsedId ?? Isar.autoIncrement
        ..nomParcelle = parcelle.nom
        ..surface = parcelle.surface
        ..photoPath = parcelle.photoPath
        ..createdAt = createdAt
        ..isSynced = parcelle.isSynced;

      await _db.writeTxn(() => _db.parcelleLocals.put(localParcelle));
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
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
      await _db.writeTxn(() => _db.parcelleLocals.delete(parsedId));
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<void> deleteParcelleById(int id) async {
    await _db.writeTxn(() => _db.parcelleLocals.delete(id));
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
      final statut = nb == 0
          ? 'aucun_diagnostic'
          : (derniereMaladie?.toLowerCase() == 'healthy' ? 'sain' : 'malade');

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
