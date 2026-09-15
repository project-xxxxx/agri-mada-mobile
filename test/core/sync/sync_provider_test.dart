import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/core/local_db/models/diagnostic_local.dart';
import 'package:agri_mada/core/local_db/isar_service.dart';
import 'package:agri_mada/core/local_db/models/parcelle_local.dart';
import 'package:agri_mada/core/local_db/models/user_local.dart';
import 'package:agri_mada/core/local_db/session_service.dart';
import 'package:agri_mada/core/sync/data/datasources/sync_remote_datasource.dart';
import 'package:agri_mada/core/sync/providers/sync_provider.dart';
import 'package:agri_mada/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:agri_mada/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_mada/features/auth/presentation/providers/session_provider.dart';
import 'package:agri_mada/features/journal/data/repositories/parcelle_local_repository.dart';
import 'package:agri_mada/features/scan/data/repositories/diagnostic_local_repository.dart';

import '../../helpers/isar_test_core.dart';

class MockSyncRemoteDatasource extends Mock implements SyncRemoteDatasource {}

class MockAuthRepositoryImpl extends Mock implements AuthRepositoryImpl {}

class MockSessionService extends Mock implements SessionService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.flutter.io/path_provider');

  late ProviderContainer container;
  late MockSyncRemoteDatasource mockSyncRemoteDatasource;
  late MockAuthRepositoryImpl mockAuthRepository;
  late MockSessionService mockSessionService;

  setUpAll(() async {
    await initIsarCoreForTests();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        final tempDir =
            await Directory.systemTemp.createTemp('agri_mada_sync_');
        return tempDir.path;
      }
      return null;
    });
  });

  setUp(() async {
    await IsarService.instance.init();

    mockSyncRemoteDatasource = MockSyncRemoteDatasource();
    mockAuthRepository = MockAuthRepositoryImpl();
    mockSessionService = MockSessionService();

    when(() => mockAuthRepository.logout()).thenAnswer(
      (_) async => const Right(unit),
    );
    when(() => mockSessionService.isReauthRequired())
        .thenAnswer((_) async => false);

    container = ProviderContainer(
      overrides: [
        syncRemoteDatasourceProvider
            .overrideWithValue(mockSyncRemoteDatasource),
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        sessionServiceProvider.overrideWithValue(mockSessionService),
      ],
    );
  });

  tearDown(() async {
    final db = IsarService.instance.db;
    await db.writeTxn(() async {
      await db.diagnosticLocals.clear();
      await db.parcelleLocals.clear();
      await db.userLocals.clear();
    });
    await IsarService.instance.close();
    container.dispose();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  DioException unauthorized({Object? error}) => DioException(
        requestOptions: RequestOptions(path: '/sync/parcelles'),
        error: error,
        response: error == null
            ? Response(
                requestOptions: RequestOptions(path: '/sync/parcelles'),
                statusCode: 401,
              )
            : null,
      );

  group('SyncNotifier', () {
    test('sync reussie -> SyncState.success()', () async {
      // Arrange
      when(() => mockSyncRemoteDatasource.syncParcelles(any())).thenAnswer(
        (_) async => {'parcelles': <Map<String, dynamic>>[]},
      );
      when(() => mockSyncRemoteDatasource.syncDiagnostics(any())).thenAnswer(
        (_) async => {'diagnostics': <Map<String, dynamic>>[]},
      );

      // Act
      await container.read(syncNotifierProvider.notifier).syncData();

      // Assert
      expect(container.read(syncNotifierProvider), const SyncState.success());
    });

    test('401 -> session conservée, reconnexion demandée pour synchroniser',
        () async {
      // Arrange
      final parcelleRepo = ParcelleLocalRepository();
      await parcelleRepo.createParcelle(nomParcelle: 'Parcelle 401');
      when(() => mockSyncRemoteDatasource.syncParcelles(any()))
          .thenThrow(unauthorized());

      // Act
      await container.read(syncNotifierProvider.notifier).syncData();

      // Assert
      expect(
        container.read(syncNotifierProvider),
        const SyncState.error(SyncNotifier.reauthRequiredMessage),
      );
      verifyNever(() => mockAuthRepository.logout());
    });

    test(
        'timeout -> retry 2 fois puis SyncState.error("Erreur de synchronisation")',
        () async {
      // Arrange
      final parcelleRepo = ParcelleLocalRepository();
      await parcelleRepo.createParcelle(nomParcelle: 'Parcelle timeout');

      when(() => mockSyncRemoteDatasource.syncParcelles(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/sync/parcelles'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      // Act
      await container.read(syncNotifierProvider.notifier).syncData();

      // Assert
      verify(() => mockSyncRemoteDatasource.syncParcelles(any())).called(2);
      expect(
        container.read(syncNotifierProvider),
        const SyncState.error('Erreur de synchronisation'),
      );
    });

    test('AuthFailure de l\'intercepteur -> reconnexion demandée, pas de logout',
        () async {
      // Arrange
      final parcelleRepo = ParcelleLocalRepository();
      await parcelleRepo.createParcelle(nomParcelle: 'Parcelle token refusé');
      when(() => mockSyncRemoteDatasource.syncParcelles(any())).thenThrow(
        unauthorized(error: const AuthFailure('Session expirée')),
      );

      // Act
      await container.read(syncNotifierProvider.notifier).syncData();

      // Assert
      expect(
        container.read(syncNotifierProvider),
        const SyncState.error(SyncNotifier.reauthRequiredMessage),
      );
      verifyNever(() => mockAuthRepository.logout());
    });

    test('reconnexion requise -> aucun appel réseau', () async {
      // Arrange
      await ParcelleLocalRepository().createParcelle(nomParcelle: 'En attente');
      when(() => mockSessionService.isReauthRequired())
          .thenAnswer((_) async => true);

      // Act
      await container.read(syncNotifierProvider.notifier).syncData();

      // Assert
      verifyNever(() => mockSyncRemoteDatasource.syncParcelles(any()));
      expect(
        container.read(syncNotifierProvider),
        const SyncState.error(SyncNotifier.reauthRequiredMessage),
      );
    });

    test('parcelles associées par client_uuid, pas par position (P1.9)',
        () async {
      // Arrange
      final parcelleRepo = ParcelleLocalRepository();
      final nouvelle = await parcelleRepo.createParcelle(nomParcelle: 'Nouvelle');
      // Parcelle créée avant l'introduction de client_uuid.
      final ancienne = ParcelleLocal()
        ..nomParcelle = 'Ancienne'
        ..createdAt = DateTime(2025, 11, 2);
      final db = IsarService.instance.db;
      await db.writeTxn(() => db.parcelleLocals.put(ancienne));

      late List<Map<String, dynamic>> sent;
      when(() => mockSyncRemoteDatasource.syncParcelles(any()))
          .thenAnswer((invocation) async {
        final body = invocation.positionalArguments.first as Map<String, dynamic>;
        sent = (body['parcelles'] as List).cast<Map<String, dynamic>>();
        // Le serveur répond dans l'ordre inverse.
        return {
          'parcelles': [
            for (final (index, item) in sent.indexed.toList().reversed)
              {'id': 100 + index, 'client_uuid': item['client_uuid']},
          ],
        };
      });

      // Act
      await container.read(syncNotifierProvider.notifier).syncData();

      // Assert
      expect(container.read(syncNotifierProvider), const SyncState.success());
      for (final local in [nouvelle, ancienne]) {
        final stored = (await db.parcelleLocals.get(local.id))!;
        final sentIndex =
            sent.indexWhere((item) => item['client_uuid'] == stored.clientUuid);
        expect(stored.clientUuid, isNotNull);
        expect(sentIndex, isNot(-1));
        expect(stored.isSynced, isTrue);
        expect(stored.serverId, 100 + sentIndex);
      }
    });

    test('diagnostic envoyé avec son client_uuid, celui de la parcelle et la certitude',
        () async {
      // Arrange
      final parcelleRepo = ParcelleLocalRepository();
      final parcelle = await parcelleRepo.createParcelle(nomParcelle: 'Sud');
      await parcelleRepo.markAsSynced(parcelle.id, 7);
      final diagnostic = await DiagnosticLocalRepository().saveDiagnostic(
        parcelleLocalId: parcelle.id,
        maladieDetectee: 'Brown spot',
        certitude: 'probable',
        niveauGravite: 'moins_tiers',
      );

      late Map<String, dynamic> sent;
      when(() => mockSyncRemoteDatasource.syncDiagnostics(any()))
          .thenAnswer((invocation) async {
        final body = invocation.positionalArguments.first as Map<String, dynamic>;
        sent = (body['diagnostics'] as List).cast<Map<String, dynamic>>().single;
        return {
          'diagnostics': [
            {'id': 55, 'client_uuid': sent['client_uuid']},
          ],
        };
      });

      // Act
      await container.read(syncNotifierProvider.notifier).syncData();

      // Assert
      final db = IsarService.instance.db;
      final stored = (await db.diagnosticLocals.get(diagnostic.id))!;
      final storedParcelle = (await db.parcelleLocals.get(parcelle.id))!;
      expect(sent['client_uuid'], stored.clientUuid);
      expect(sent['parcelle_client_uuid'], storedParcelle.clientUuid);
      expect(sent['parcelle_id'], 7);
      expect(sent['certitude'], 'probable');
      expect(stored.isSynced, isTrue);
      expect(stored.serverId, 55);
    });
  });
}
