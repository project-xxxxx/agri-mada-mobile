// Tâche P2.3 : la migration doit reprendre les anciens diagnostics sans rien
// perdre, et pouvoir être rejouée sans créer de doublon.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:agri_mada/core/local_db/isar_service.dart';
import 'package:agri_mada/core/local_db/migrations/session_migration.dart';
import 'package:agri_mada/core/local_db/models/diagnostic_local.dart';
import 'package:agri_mada/core/local_db/models/diagnostic_session_local.dart';
import 'package:agri_mada/core/local_db/models/observation_local.dart';
import 'package:agri_mada/features/scan/data/repositories/session_local_repository.dart';
import 'package:agri_mada/features/scan/domain/entities/organe.dart';

import '../../../helpers/isar_test_core.dart';

DiagnosticLocal _ancienDiagnostic({
  required String maladie,
  String? clientUuid,
  int parcelleLocalId = 1,
  double? confiance,
  String? certitude,
  String? gravite,
  bool isSynced = false,
  int? serverId,
  DateTime? date,
}) =>
    DiagnosticLocal()
      ..clientUuid = clientUuid
      ..parcelleLocalId = parcelleLocalId
      ..maladieDetectee = maladie
      ..confiance = confiance
      ..certitude = certitude
      ..niveauGravite = gravite
      ..imagePath = 'ancienne-photo.jpg'
      ..dateDiagnostic = date ?? DateTime(2026, 5, 20)
      ..isSynced = isSynced
      ..serverId = serverId;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() async {
    await initIsarCoreForTests();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return (await Directory.systemTemp.createTemp('agri_mada_migration_')).path;
      }
      return null;
    });
  });

  setUp(() => IsarService.instance.init());

  tearDown(() async {
    final db = IsarService.instance.db;
    await db.writeTxn(() async {
      await db.diagnosticLocals.clear();
      await db.diagnosticSessionLocals.clear();
      await db.observationLocals.clear();
    });
    await IsarService.instance.close();
  });

  test('une base sans ancien diagnostic ne crée aucune session', () async {
    expect(await migrerDiagnosticsVersSessions(IsarService.instance.db), 0);
  });

  test('chaque ancien diagnostic devient une session avec une observation feuille', () async {
    final db = IsarService.instance.db;
    await db.writeTxn(() async {
      await db.diagnosticLocals.putAll([
        _ancienDiagnostic(
          maladie: 'Brown spot',
          clientUuid: 'uuid-connu',
          confiance: 0.71,
          certitude: 'possible',
          gravite: 'moins_tiers',
        ),
        _ancienDiagnostic(
          maladie: 'Bacterial leaf blight',
          parcelleLocalId: 2,
          isSynced: true,
          serverId: 55,
          date: DateTime(2026, 6, 2),
        ),
      ]);
    });

    final creees = await migrerDiagnosticsVersSessions(db);

    expect(creees, 2);
    final sessions = await db.diagnosticSessionLocals.where().findAll();
    expect(sessions, hasLength(2));

    final migree = sessions.firstWhere((s) => s.resultatFicheId == 'Brown spot');
    expect(migree.clientUuid, 'uuid-connu');
    expect(migree.parcelleLocalId, 1);
    expect(migree.certitude, 'possible');
    expect(migree.graviteDeclaree, 'moins_tiers');
    expect(migree.createdAt, DateTime(2026, 5, 20));
    expect(decoderClassement(migree.classement).single.score, closeTo(0.71, 1e-9));

    final synchronisee = sessions.firstWhere((s) => s.resultatFicheId == 'Bacterial leaf blight');
    expect(synchronisee.isSynced, isTrue);
    expect(synchronisee.serverId, 55);
    expect(synchronisee.clientUuid, isNotEmpty, reason: 'un identifiant est attribué au passage');

    final observations = await db.observationLocals.where().findAll();
    expect(observations, hasLength(2));
    expect(observations.every((o) => o.organeCode == Organe.feuille.code), isTrue);
    expect(observations.first.imagePath, 'ancienne-photo.jpg');
  });

  test('la migration peut être rejouée sans créer de doublon', () async {
    final db = IsarService.instance.db;
    await db.writeTxn(() async {
      await db.diagnosticLocals.put(_ancienDiagnostic(maladie: 'Leaf smut'));
    });

    expect(await migrerDiagnosticsVersSessions(db), 1);
    expect(await migrerDiagnosticsVersSessions(db), 0);

    expect(await db.diagnosticSessionLocals.count(), 1);
    expect(await db.observationLocals.count(), 1);
  });

  test('les anciens diagnostics sont conservés', () async {
    final db = IsarService.instance.db;
    await db.writeTxn(() async {
      await db.diagnosticLocals.put(_ancienDiagnostic(maladie: 'Brown spot'));
    });

    await migrerDiagnosticsVersSessions(db);

    expect(await db.diagnosticLocals.count(), 1);
  });
}
