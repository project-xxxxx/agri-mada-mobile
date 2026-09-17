// Tâche P1.8 : trois jours hors ligne puis reconnexion. L'agriculteur reste
// connecté, ses données locales sont intactes et la synchronisation reprend
// dès le retour du réseau, en renouvelant une fois le jeton expiré.
//
// Tout est réel côté app : base Isar, SessionService (stockage sécurisé
// simulé), Dio avec AuthInterceptor, SyncNotifier et dépôts locaux. Seul le
// serveur est remplacé par un transport HTTP qui reproduit le backend.

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/constants/api_constants.dart';
import 'package:agri_mada/core/local_db/isar_service.dart';
import 'package:agri_mada/core/ai/diagnosis_certainty.dart';
import 'package:agri_mada/core/ai/diagnosis_fusion.dart';
import 'package:agri_mada/core/local_db/models/diagnostic_session_local.dart';
import 'package:agri_mada/core/local_db/models/observation_local.dart';
import 'package:agri_mada/core/local_db/models/parcelle_local.dart';
import 'package:agri_mada/core/local_db/models/user_local.dart';
import 'package:agri_mada/core/local_db/session_service.dart';
import 'package:agri_mada/core/network/dio_client.dart';
import 'package:agri_mada/core/sync/providers/sync_provider.dart';
import 'package:agri_mada/features/journal/data/repositories/parcelle_local_repository.dart';
import 'package:agri_mada/features/scan/data/repositories/session_local_repository.dart';
import 'package:agri_mada/features/scan/domain/entities/organe.dart';

import '../helpers/isar_test_core.dart';

ResponseBody _json(int status, Object body) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

/// Reproduit le backend : jeton d'accès, rotation du jeton de rafraîchissement
/// et réponses de synchronisation indexées par client_uuid.
class _Backend implements HttpClientAdapter {
  bool online = false;
  int refreshCalls = 0;
  int attemptsWhileOffline = 0;

  static const validAccessToken = 'acces-neuf';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (!online) {
      attemptsWhileOffline++;
      throw DioException.connectionError(requestOptions: options, reason: 'Pas de réseau');
    }

    final body = options.data as Map;
    if (options.path == ApiConstants.refreshToken) {
      refreshCalls++;
      if (body['refresh_token'] != 'refresh-1') {
        return _json(401, {'detail': 'Jeton de rafraîchissement invalide ou expiré.'});
      }
      return _json(200, {
        'access_token': validAccessToken,
        'token_type': 'bearer',
        'refresh_token': 'refresh-2',
        'expires_in': 3600,
      });
    }

    if (options.headers['Authorization'] != 'Bearer $validAccessToken') {
      return _json(401, {'detail': 'Token invalide ou expiré'});
    }

    List<Map<String, dynamic>> itemsOf(String key, int firstId) => [
          for (final (index, item) in (body[key] as List).indexed)
            {'id': firstId + index, 'client_uuid': (item as Map)['client_uuid']},
        ];

    return switch (options.path) {
      '/sync/parcelles' => _json(200, {'parcelles': itemsOf('parcelles', 700)}),
      '/sync/sessions' => _json(200, {'sessions': itemsOf('sessions', 900)}),
      _ => _json(404, {'detail': 'Route inconnue'}),
    };
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorage = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
  final storage = <String, String>{};

  setUpAll(() async {
    await initIsarCoreForTests();
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(secureStorage, (call) async {
      final args = Map<String, dynamic>.from(call.arguments as Map);
      final key = args['key'] as String?;
      switch (call.method) {
        case 'write':
          storage[key!] = args['value'] as String;
        case 'read':
          return storage[key];
        case 'delete':
          storage.remove(key);
        case 'deleteAll':
          storage.clear();
      }
      return null;
    });
    messenger.setMockMethodCallHandler(pathProvider, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return (await Directory.systemTemp.createTemp('agri_mada_scenario_')).path;
      }
      return null;
    });
  });

  setUp(() async {
    storage.clear();
    await IsarService.instance.init();
  });

  tearDown(() async {
    final db = IsarService.instance.db;
    await db.writeTxn(() async {
      await db.diagnosticSessionLocals.clear();
      await db.observationLocals.clear();
      await db.parcelleLocals.clear();
      await db.userLocals.clear();
    });
    await IsarService.instance.close();
  });

  tearDownAll(() {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(secureStorage, null);
    messenger.setMockMethodCallHandler(pathProvider, null);
  });

  test('trois jours hors ligne puis reconnexion : session conservée, synchronisation reprise',
      () async {
    final session = SessionService.instance;
    final parcelles = ParcelleLocalRepository();

    // Avant le départ : session ouverte, langue malgache, une parcelle et un
    // diagnostic enregistrés sur le téléphone.
    await session.saveSession(token: 'acces-perime', tokenType: 'bearer', refreshToken: 'refresh-1');
    await session.saveProfile(
      userId: 7,
      nom: 'Rakotonirina',
      prenom: 'Hery',
      tel: '0340000000',
      region: 'Vakinankaratra',
    );
    await session.saveLocaleCode('mg');
    final parcelle = await parcelles.createParcelle(nomParcelle: 'Tanimbary ambany');
    final sessions = SessionLocalRepository();
    final scanSession = await sessions.ouvrirSession(parcelleLocalId: parcelle.id);
    await sessions.ajouterObservation(
      sessionId: scanSession.id,
      organe: Organe.feuille,
      imagePath: 'feuille.jpg',
      topK: const [ScoredLabel('Brown spot', 0.62)],
    );
    await sessions.enregistrerResultat(
      sessionId: scanSession.id,
      fusion: const FusedDiagnosis(
        classement: [ScoredLabel('Brown spot', 0.62)],
        certitude: DiagnosisCertainty.possible,
        nommable: true,
      ),
      graviteDeclaree: 'moins_tiers',
    );

    final backend = _Backend();
    final container = ProviderContainer(
      overrides: [httpClientAdapterProvider.overrideWithValue(backend)],
    );
    addTearDown(container.dispose);
    final sync = container.read(syncNotifierProvider.notifier);

    // Jours 1 à 3 : aucune connexion. Chaque tentative échoue sans toucher à la session.
    for (var day = 1; day <= 3; day++) {
      await sync.syncData();
      expect(
        container.read(syncNotifierProvider),
        const SyncState.error(SyncErrorReason.failed),
        reason: 'jour $day',
      );
    }
    expect(backend.attemptsWhileOffline, greaterThan(0));
    expect(await session.isLoggedIn(), isTrue);
    expect(await session.isReauthRequired(), isFalse);
    expect(await session.getLocaleCode(), 'mg');
    expect((await parcelles.getParcelleById(parcelle.id))!.isSynced, isFalse);

    // Retour du réseau : le jeton d'accès a expiré, il est renouvelé une seule fois.
    backend.online = true;
    await sync.syncData();

    expect(container.read(syncNotifierProvider), const SyncState.success());
    expect(backend.refreshCalls, 1);
    expect(await session.isLoggedIn(), isTrue);
    expect(await session.getToken(), _Backend.validAccessToken);
    expect(await session.getRefreshToken(), 'refresh-2');
    expect(await session.getPrenom(), 'Hery');

    final storedParcelle = (await parcelles.getParcelleById(parcelle.id))!;
    expect(storedParcelle.isSynced, isTrue);
    expect(storedParcelle.serverId, 700);
    final storedSession =
        (await IsarService.instance.db.diagnosticSessionLocals.get(scanSession.id))!;
    expect(storedSession.isSynced, isTrue);
    expect(storedSession.serverId, 900);
  });
}
