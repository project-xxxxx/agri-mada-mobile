import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:agri_mada/core/local_db/models/diagnostic_local.dart';
import 'package:agri_mada/core/local_db/models/parcelle_local.dart';
import 'package:agri_mada/core/local_db/models/user_local.dart';
import 'package:agri_mada/core/local_db/isar_service.dart';
import 'package:agri_mada/features/journal/data/repositories/parcelle_local_repository.dart';
import 'package:agri_mada/features/journal/domain/entities/parcelle_entity.dart';

import '../../../../helpers/isar_test_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.flutter.io/path_provider');

  late ParcelleLocalRepository repository;

  setUpAll(() async {
    await initIsarCoreForTests();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        final tempDir =
            await Directory.systemTemp.createTemp('agri_mada_test_');
        return tempDir.path;
      }
      return null;
    });
  });

  setUp(() async {
    await IsarService.instance.init();
    repository = ParcelleLocalRepository();
  });

  tearDown(() async {
    final db = IsarService.instance.db;
    await db.writeTxn(() async {
      await db.diagnosticLocals.clear();
      await db.parcelleLocals.clear();
      await db.userLocals.clear();
    });
    await IsarService.instance.close();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('ParcelleLocalRepository', () {
    test('saveParcelle() persiste correctement', () async {
      // Arrange & Act
      final parcelle = await repository.createParcelle(
        nomParcelle: 'Riziere Nord',
        description: 'Parcelle de test',
        surface: 2.5,
      );

      // Assert
      expect(parcelle.id, greaterThan(0));
      expect(parcelle.nomParcelle, 'Riziere Nord');
      expect(parcelle.isSynced, isFalse);
    });

    test('createParcelle() conserve culture et emplacement, avec l\'id attribué',
        () async {
      // Arrange & Act
      final parcelle = await repository.createParcelle(
        nomParcelle: 'Riziere Nord',
        description: 'Fokontany Ambohimanga',
        culture: 'Riz',
        surface: 0.55,
      );
      final stored = await repository.getParcelleById(parcelle.id);

      // Assert
      expect(stored, isNotNull);
      expect(stored!.description, 'Fokontany Ambohimanga');
      expect(stored.culture, 'Riz');
      expect(stored.surface, 0.55);
    });

    test('saveParcelle() met à jour sans effacer position, identifiant serveur ni date',
        () async {
      // Arrange
      final parcelle = await repository.createParcelle(
        nomParcelle: 'Avant',
        latitude: -19.87,
        longitude: 47.03,
      );
      await repository.markAsSynced(parcelle.id, 42);
      final createdAt = (await repository.getParcelleById(parcelle.id))!.createdAt;

      // Act
      await repository.saveParcelle(
        ParcelleEntity(
          id: parcelle.id.toString(),
          nom: 'Après',
          description: 'Bas-fond',
          isSynced: true,
        ),
      );

      // Assert
      final stored = (await repository.getParcelleById(parcelle.id))!;
      expect(stored.nomParcelle, 'Après');
      expect(stored.description, 'Bas-fond');
      expect(stored.latitude, -19.87);
      expect(stored.serverId, 42);
      expect(stored.createdAt, createdAt);
    });

    test('getParcelles() retourne la liste locale', () async {
      // Arrange
      await repository.createParcelle(nomParcelle: 'Parcelle A');
      await repository.createParcelle(nomParcelle: 'Parcelle B');

      // Act
      final parcelles = await repository.getAllParcelles();

      // Assert
      expect(parcelles, hasLength(2));
      expect(parcelles.map((p) => p.nomParcelle),
          containsAll(['Parcelle A', 'Parcelle B']));
    });

    test('deleteParcelle() supprime l\'entree', () async {
      // Arrange
      final parcelle =
          await repository.createParcelle(nomParcelle: 'A supprimer');

      // Act
      await repository.deleteParcelle(parcelle.id.toString());
      final parcelles = await repository.getAllParcelles();

      // Assert
      expect(parcelles, isEmpty);
    });

    test('deleteParcelle() supprime aussi ses diagnostics', () async {
      // Arrange
      final aSupprimer = await repository.createParcelle(nomParcelle: 'A supprimer');
      final aGarder = await repository.createParcelle(nomParcelle: 'A garder');
      final db = IsarService.instance.db;
      await db.writeTxn(() async {
        await db.diagnosticLocals.putAll([
          DiagnosticLocal()
            ..parcelleLocalId = aSupprimer.id
            ..maladieDetectee = 'Brown spot'
            ..dateDiagnostic = DateTime(2026, 1, 1),
          DiagnosticLocal()
            ..parcelleLocalId = aGarder.id
            ..maladieDetectee = 'Leaf smut'
            ..dateDiagnostic = DateTime(2026, 1, 2),
        ]);
      });

      // Act
      await repository.deleteParcelle(aSupprimer.id.toString());

      // Assert
      final remaining = await db.diagnosticLocals.where().findAll();
      expect(remaining, hasLength(1));
      expect(remaining.single.parcelleLocalId, aGarder.id);
      expect(await repository.getAllParcelles(), hasLength(1));
    });
  });
}
