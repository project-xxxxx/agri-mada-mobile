import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(installTestHarness);
  tearDownAll(resetTestHarness);

  setUp(() async {
    await resetTestHarness();
  });

  patrolTest('onboarding complet au premier lancement', ($) async {
    addTearDown(resetTestHarness);

    // Étape 1 : lancer l'app en mode premier lancement.
    await pumpApp(
      $,
      loggedIn: false,
      onboardingDone: false,
      isTfliteReady: false,
    );

    // Étape 2 : vérifier l'écran onboarding.
    expect(find.text('Bienvenue'), findsOneWidget);
    expect(find.text('Photographiez la feuille malade'), findsOneWidget);

    // Étape 3 : avancer sur les slides.
    await $('Suivant').tap();
    await $.pumpAndSettle();
    await $('Suivant').tap();
    await $.pumpAndSettle();
    await $('Suivant').tap();
    await $.pumpAndSettle();

    // Étape 4 : entrer dans l'app.
    await $('Commencer').tap();
    await $.pumpAndSettle();
    expect(find.text('AgriMada'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);

    // Étape 5 : simuler un relancement et vérifier que l'onboarding ne revient pas.
    await $.pumpWidgetAndSettle(const SizedBox(width: 0, height: 0));
    await pumpApp(
      $,
      loggedIn: false,
      onboardingDone: true,
      isTfliteReady: false,
    );
    expect(find.text('Bienvenue'), findsNothing);
    expect(find.text('Photographiez la feuille malade'), findsNothing);
    expect(find.text('AgriMada'), findsOneWidget);
  });

  patrolTest('passer directement l onboarding', ($) async {
    addTearDown(resetTestHarness);

    // Étape 1 : lancer l'app en premier lancement.
    await pumpApp(
      $,
      loggedIn: false,
      onboardingDone: false,
      isTfliteReady: false,
    );

    // Étape 2 : passer l'onboarding.
    await $('Passer').tap();
    await $.pumpAndSettle();

    // Étape 3 : vérifier la navigation vers l'écran welcome.
    expect(find.text('AgriMada'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
  });
}
