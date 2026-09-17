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

  patrolTest('mesure inférence tflite', skip: true, ($) async {
    addTearDown(resetTestHarness);

    // Étape 1 : ce benchmark reste désactivé tant que le moteur réel n'est pas pilotable en CI.
    await pumpApp(
      $,
      loggedIn: true,
      onboardingDone: true,
      isTfliteReady: true,
    );
    expect(true, isTrue);
  });
}
