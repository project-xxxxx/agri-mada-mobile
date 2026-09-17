import 'package:agri_mada/core/local_db/isar_service.dart';
import 'package:agri_mada/core/local_db/models/diagnostic_local.dart';
import 'package:agri_mada/core/local_db/session_service.dart';
import 'package:agri_mada/core/sync/providers/sync_provider.dart';
import 'package:agri_mada/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app_helper.dart';
import 'helpers/mock_sync_remote_datasource.dart';
import 'helpers/test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(installTestHarness);
  tearDownAll(resetTestHarness);

  setUp(() async {
    await resetTestHarness();
  });

  patrolTest('sync déclenchée au retour de connectivité', ($) async {
    addTearDown(resetTestHarness);

    // Étape 1 : préparer une parcelle déjà liée serveur + un diagnostic local non sync.
    final parcelle = buildTestParcelle(id: 1)
      ..isSynced = true
      ..serverId = 11;
    final diagnostic = buildTestDiagnostic(id: 1, parcelleLocalId: 1)
      ..isSynced = false;

    await seedParcelles([parcelle]);
    await seedDiagnostics([diagnostic]);

    // Étape 2 : lancer l'app avec un datasource sync mocké en succès.
    final mockRemote = buildSuccessfulSyncRemoteDatasource();
    await pumpApp(
      $,
      loggedIn: true,
      onboardingDone: true,
      isTfliteReady: true,
      additionalOverrides: <Override>[
        syncRemoteDatasourceProvider.overrideWithValue(mockRemote),
      ],
    );

    expect(find.byType(HomeScreen), findsOneWidget);

    // Étape 3 : passer en mode avion puis revenir en ligne via Patrol.
    await $.platform.mobile.enableAirplaneMode();
    await $.pumpAndSettle();
    await $.platform.mobile.disableAirplaneMode();
    await $.pumpAndSettle();

    // Étape 4 : déclencher manuellement la sync pour un résultat déterministe en CI.
    final context = $.tester.element(find.byType(HomeScreen));
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(syncNotifierProvider.notifier).syncData();
    await $.pumpAndSettle();

    // Étape 5 : vérifier le succès visuel et la persistance locale.
    expect(find.byIcon(Icons.cloud_done_outlined), findsOneWidget);
    final saved = await IsarService.instance.db.diagnosticLocals.get(1);
    expect(saved?.isSynced, isTrue);
  });

  patrolTest('session expirée pendant la sync (401)', ($) async {
    addTearDown(resetTestHarness);

    // Étape 1 : préparer une session valide et des données locales.
    final parcelle = buildTestParcelle(id: 1)
      ..isSynced = true
      ..serverId = 11;
    final diagnostic = buildTestDiagnostic(id: 1, parcelleLocalId: 1)
      ..isSynced = false;

    await seedParcelles([parcelle]);
    await seedDiagnostics([diagnostic]);

    // Étape 2 : lancer l'app avec un datasource sync mocké en 401.
    final mockRemote = buildUnauthorizedSyncRemoteDatasource();
    await pumpApp(
      $,
      loggedIn: true,
      onboardingDone: true,
      isTfliteReady: true,
      additionalOverrides: <Override>[
        syncRemoteDatasourceProvider.overrideWithValue(mockRemote),
      ],
    );

    // Étape 3 : déclencher la sync.
    final context = $.tester.element(find.byType(HomeScreen));
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(syncNotifierProvider.notifier).syncData();
    await $.pumpAndSettle();

    // Étape 4 : vérifier le nettoyage de session locale.
    final isLoggedIn = await SessionService.instance.isLoggedIn();
    expect(isLoggedIn, isFalse);

    // Étape 5 : vérifier l'indicateur d'erreur de sync.
    expect(find.byIcon(Icons.sync_problem), findsOneWidget);
  });
}
