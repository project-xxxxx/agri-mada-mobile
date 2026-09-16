import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/ai/tflite_service.dart';
import 'core/local_db/isar_service.dart';
import 'core/local_db/migrations/session_migration.dart';
import 'core/local_db/session_service.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/tflite_provider.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Initialisation des services hors-ligne ---
  await IsarService.instance.init();
  // Les diagnostics de l'ancienne version deviennent des sessions (tâche P2.3).
  await migrerDiagnosticsVersSessions(IsarService.instance.db);

  final localeCode = await SessionService.instance.getLocaleCode() ?? 'fr';
  final initialLocale = Locale(localeCode);
  var isTFLiteReady = false;
  try {
    await TFLiteService.instance.init();
    isTFLiteReady = TFLiteService.instance.isReady;
    if (!isTFLiteReady) {
      AppLogger.error(
        'Initialisation TFLite terminée mais moteur non prêt',
        error: TFLiteService.instance.lastInitError,
      );
    }
  } catch (e, st) {
    AppLogger.error(
      'Initialisation TFLite échouée: démarrage en mode dégradé sans IA',
      error: e,
      stackTrace: st,
    );
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        isTFLiteReadyProvider.overrideWithValue(isTFLiteReady),
        initialLocaleProvider.overrideWithValue(initialLocale),
      ],
      child: const AgriMadaApp(),
    ),
  );
}
