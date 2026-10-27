import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/core/local_db/models/diagnostic_local.dart';
import 'package:agri_mada/core/ai/diagnosis_certainty.dart';
import 'package:agri_mada/core/ai/diagnosis_fusion.dart';
import 'package:agri_mada/core/local_db/models/diagnostic_session_local.dart';
import 'package:agri_mada/features/scan/data/repositories/session_local_repository.dart';
import 'package:agri_mada/features/scan/domain/entities/organe.dart';
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
        const SyncState.error(SyncErrorReason.reauthRequired),
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
        const SyncState.error(SyncErrorReason.failed),
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
        const SyncState.error(SyncErrorReason.reauthRequired),
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
        const SyncState.error(SyncErrorReason.reauthRequired),
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

    test('session envoyée avec ses observations, sa parcelle et sa certitude', () async {
      // Arrange
      final parcelleRepo = ParcelleLocalRepository();
      final parcelle = await parcelleRepo.createParcelle(nomParcelle: 'Sud');
      await parcelleRepo.markAsSynced(parcelle.id, 7);

      final sessionRepo = SessionLocalRepository();
      final session = await sessionRepo.ouvrirSession(parcelleLocalId: parcelle.id);
      await sessionRepo.ajouterObservation(
        sessionId: session.id,
        organe: Organe.feuille,
        imagePath: 'feuille.jpg',
        topK: const [ScoredLabel('Brown spot', 0.62)],
      );
      await sessionRepo.enregistrerResultat(
        sessionId: session.id,
        fusion: const FusedDiagnosis(
          classement: [ScoredLabel('Brown spot', 0.62)],
          certitude: DiagnosisCertainty.possible,
          nommable: true,
        ),
        graviteDeclaree: 'moins_tiers',
      );

      late Map<String, dynamic> sent;
      when(() => mockSyncRemoteDatasource.syncSessions(any()))
          .thenAnswer((invocation) async {
        final body = invocation.positionalArguments.first as Map<String, dynamic>;
        sent = (body['sessions'] as List).cast<Map<String, dynamic>>().single;
        return {
          'sessions': [
            {'id': 55, 'client_uuid': sent['client_uuid']},
          ],
        };
      });

      // Act
      await container.read(syncNotifierProvider.notifier).syncData();

      // Assert
      final db = IsarService.instance.db;
      final stored = (await db.diagnosticSessionLocals.get(session.id))!;
      final storedParcelle = (await db.parcelleLocals.get(parcelle.id))!;
      expect(sent['client_uuid'], stored.clientUuid);
      expect(sent['parcelle_client_uuid'], storedParcelle.clientUuid);
      expect(sent['parcelle_id'], 7);
      expect(sent['certitude'], 'possible');
      expect(sent['gravite_declaree'], 'moins_tiers');
      final observations = (sent['observations'] as List).cast<Map<String, dynamic>>();
      expect(observations.single['organe'], 'feuille');
      expect(stored.isSynced, isTrue);
      expect(stored.serverId, 55);
    });

    test('une session sans parcelle part quand même (P2.6)', () async {
      // Arrange
      final sessionRepo = SessionLocalRepository();
      final session = await sessionRepo.ouvrirSession();
      await sessionRepo.ajouterObservation(
        sessionId: session.id,
        organe: Organe.racines,
        imagePath: 'racines.jpg',
      );
      await sessionRepo.enregistrerResultat(
        sessionId: session.id,
        fusion: const FusedDiagnosis(
          classement: [],
          certitude: DiagnosisCertainty.incertain,
          nommable: false,
        ),
      );

      late Map<String, dynamic> sent;
      when(() => mockSyncRemoteDatasource.syncSessions(any()))
          .thenAnswer((invocation) async {
        final body = invocation.positionalArguments.first as Map<String, dynamic>;
        sent = (body['sessions'] as List).cast<Map<String, dynamic>>().single;
        return {
          'sessions': [
            {'id': 77, 'client_uuid': sent['client_uuid']},
          ],
        };
      });

      // Act
      await container.read(syncNotifierProvider.notifier).syncData();

      // Assert
      expect(sent.containsKey('parcelle_id'), isFalse);
      expect(sent['resultat_fiche_id'], isNull);
      final stored = (await IsarService.instance.db.diagnosticSessionLocals
          .get(session.id))!;
      expect(stored.isSynced, isTrue);
      expect(stored.serverId, 77);
    });
  });
}
