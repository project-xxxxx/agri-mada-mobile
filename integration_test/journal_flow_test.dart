import 'package:agri_mada/features/journal/presentation/screens/journal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app_helper.dart';
import 'helpers/test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(installTestHarness);
  tearDownAll(resetTestHarness);

  setUp(() async {
    await resetTestHarness();
  });

  patrolTest('créer une parcelle puis consulter le journal', ($) async {
    addTearDown(resetTestHarness);

    // Étape 1 : démarrer l'app avec une session valide.
    await pumpApp(
      $,
      loggedIn: true,
      onboardingDone: true,
      isTfliteReady: true,
    );

    // Étape 2 : ouvrir le journal.
    await $(find.text('Journal')).tap();
    await $.pumpAndSettle();
    expect(find.byType(JournalScreen), findsOneWidget);

    // Étape 3 : vérifier l'état vide.
    expect(find.text('Aucune parcelle'), findsOneWidget);

    // Étape 4 : ouvrir le formulaire de parcelle.
    await $(find.text('Ajouter une parcelle')).tap();
    await $.pumpAndSettle();

    // Étape 5 : remplir le formulaire.
    await $(TextFormField).at(0).enterText('Parcelle Test');
    await $(TextFormField).at(1).enterText('Riz');
    await $(TextFormField).at(2).enterText('2');

    // Étape 6 : valider la création.
    await $('Enregistrer').tap();
    await $.pumpAndSettle();

    // Étape 7 : vérifier la présence de la parcelle et du compteur.
    expect(find.text('Parcelle Test'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
  });

  patrolTest('exporter un journal vide affiche un message', ($) async {
    addTearDown(resetTestHarness);

    // Étape 1 : préparer un état sans données locales.
    await pumpApp(
      $,
      loggedIn: true,
      onboardingDone: true,
      isTfliteReady: true,
    );

    // Étape 2 : ouvrir le journal.
    await $(find.text('Journal')).tap();
    await $.pumpAndSettle();

    // Étape 3 : déclencher l'export.
    await $(find.byTooltip('Exporter')).tap();
    await $.pumpAndSettle();

    // Étape 4 : vérifier le message d'absence de données.
    expect(find.text('Aucun diagnostic à exporter'), findsOneWidget);
  });

  patrolTest('consulter detail et evolution (smoke)', ($) async {
    addTearDown(resetTestHarness);

    // Étape 1 : préparer une parcelle avec 3 diagnostics.
    await seedParcelles([buildTestParcelle(id: 1)]);
    await seedDiagnostics([
      buildTestDiagnostic(id: 1, parcelleLocalId: 1),
      buildTestDiagnostic(id: 2, parcelleLocalId: 1),
      buildTestDiagnostic(id: 3, parcelleLocalId: 1),
    ]);

    await pumpApp(
      $,
      loggedIn: true,
      onboardingDone: true,
      isTfliteReady: true,
    );

    // Étape 2 : ouvrir le journal.
    await $(find.text('Journal')).tap();
    await $.pumpAndSettle();

    // Étape 3 : vérifier la présence de la parcelle et d'indices d'historique.
    expect(find.text('Parcelle Test'), findsOneWidget);
    expect(find.textContaining('analyses'), findsWidgets);
    expect(find.textContaining('Brown spot'), findsWidgets);
  });
}
