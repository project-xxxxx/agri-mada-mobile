// Repository local - Gestion des parcelles dans Isar (hors-ligne)

import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/local_db/isar_service.dart';
import '../../../../core/local_db/models/parcelle_local.dart';
import '../../../../core/local_db/models/diagnostic_local.dart';
import '../../../../core/utils/client_uuid.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/parcelle_entity.dart';
import '../../../scan/data/repositories/session_local_repository.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/resultat_scan.dart';
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
    String? ecosysteme,
    String? region,
    String? altitudeTranche,
    double? altitudeMetres,
    String? variete,
    String? saison,
    DateTime? dateRepiquage,
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
      ..ecosysteme = ecosysteme
      ..region = region
      ..altitudeTranche = altitudeTranche
      ..altitudeMetres = altitudeMetres
      ..variete = variete
      ..saison = saison
      ..dateRepiquage = dateRepiquage
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

  /// Supprime une parcelle avec ses scans et les photos associées
  /// (tâche P1.9 : plus de diagnostics orphelins ; sessions incluses en P2.3).
  Future<void> deleteParcelleById(int id) async {
    final parcelle = await _db.parcelleLocals.get(id);
    final diagnostics = await _db.diagnosticLocals
        .filter()
        .parcelleLocalIdEqualTo(id)
        .findAll();

    // Sessions de scan de la parcelle, avec leurs photos.
    final sessionRepository = SessionLocalRepository();
    final photosDeSessions = <String>[];
    for (final session in await sessionRepository.historique(parcelleLocalId: id)) {
      for (final observation in await sessionRepository.observations(session.id)) {
        if (observation.imagePath.isNotEmpty) photosDeSessions.add(observation.imagePath);
      }
      await sessionRepository.supprimerSession(session.id);
    }

    await _db.writeTxn(() async {
      await _db.diagnosticLocals
          .deleteAll(diagnostics.map((diagnostic) => diagnostic.id).toList());
      await _db.parcelleLocals.delete(id);
    });

    final photoPaths = <String?>[
      parcelle?.photoPath,
      for (final diagnostic in diagnostics) diagnostic.imagePath,
      ...photosDeSessions,
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

  /// Construit le journal agricole : chaque parcelle avec son statut de santé,
  /// d'après ses sessions de scan terminées (tâche P2.3).
  Future<List<JournalEntry>> getJournalAgricole() async {
    final parcelles = await getAllParcelles();
    final resultats = await SessionLocalRepository().resultats();

    final parParcelle = <int, List<ResultatScan>>{};
    for (final resultat in resultats) {
      final parcelleId = resultat.parcelleLocalId;
      if (parcelleId == null) continue; // scan rapide non rattaché (P2.6)
      parParcelle.putIfAbsent(parcelleId, () => []).add(resultat);
    }

    final journal = <JournalEntry>[];

    for (final parcelle in parcelles) {
      final scans = parParcelle[parcelle.id] ?? const <ResultatScan>[];
      final dernier = scans.isEmpty ? null : scans.first;

      final statut = switch (dernier) {
        null => 'aucun_diagnostic',
        final scan when scan.estSain => 'sain',
        // Seul un résultat « probable » classe la parcelle malade : une piste
        // du modèle reste à confirmer (P1.2, évaluation du 2026-09-16).
        final scan when scan.estNomme && scan.estConfirme => 'malade',
        _ => 'a_confirmer',
      };

      journal.add(JournalEntry(
        parcelle: parcelle,
        nbDiagnostics: scans.length,
        derniereMaladie: dernier?.ficheId,
        dernierResultat: dernier,
        statut: statut,
      ));
    }

    return journal;
  }
}
