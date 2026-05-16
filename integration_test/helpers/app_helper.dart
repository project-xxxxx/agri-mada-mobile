import 'dart:io';

import 'package:agri_mada/app/app.dart';
import 'package:agri_mada/features/scan/domain/entities/diagnostic_result.dart';
import 'package:agri_mada/core/providers/tflite_provider.dart';
import 'package:agri_mada/core/local_db/isar_service.dart';
import 'package:agri_mada/core/local_db/models/diagnostic_local.dart';
import 'package:agri_mada/core/local_db/models/parcelle_local.dart';
import 'package:agri_mada/core/local_db/session_service.dart';
import 'package:agri_mada/features/auth/presentation/providers/session_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol/patrol.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'mock_image_picker.dart';
import 'mock_tflite.dart';

class MockSessionService extends Mock implements SessionService {}

const _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);
const _pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

final Map<String, String?> _secureStorage = <String, String?>{};
Directory? _documentsDirectory;
ImagePickerPlatform? _previousImagePickerPlatform;

Future<void> installTestHarness() async {
  registerTfliteFallbacks();

  _previousImagePickerPlatform ??= ImagePickerPlatform.instance;
  _documentsDirectory ??=
      await Directory.systemTemp.createTemp('agri_mada_docs_');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_secureStorageChannel, (MethodCall call) async {
    final args = call.arguments as Map<String, dynamic>;
    switch (call.method) {
      case 'write':
        _secureStorage[args['key'] as String] =
            args['value'] as String?;
        return null;
      case 'read':
        return _secureStorage[args['key'] as String];
      case 'delete':
        _secureStorage.remove(args['key'] as String);
        return null;
      case 'readAll':
        return Map<String, String>.fromEntries(
          _secureStorage.entries
              .where((entry) => entry.value != null)
              .map((entry) => MapEntry(entry.key, entry.value!)),
        );
      case 'deleteAll':
        _secureStorage.clear();
        return null;
      case 'containsKey':
        return _secureStorage.containsKey(args['key'] as String);
      default:
        return null;
    }
  });

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_pathProviderChannel, (MethodCall call) async {
    if (call.method == 'getApplicationDocumentsDirectory' ||
        call.method == 'getApplicationSupportDirectory') {
      return _documentsDirectory!.path;
    }

    return null;
  });

  ImagePickerPlatform.instance = TestImagePickerPlatform();
  await IsarService.instance.init();
}

Future<void> resetTestHarness() async {
  _secureStorage.clear();

  final db = IsarService.instance.db;
  await db.writeTxn(() async {
    await db.diagnosticLocals.clear();
    await db.parcelleLocals.clear();
  });

  await SessionService.instance.clearSession();
  _secureStorage['onboarding_done'] = 'false';

  if (_previousImagePickerPlatform != null) {
    ImagePickerPlatform.instance = _previousImagePickerPlatform!;
  }
}

Future<void> seedSession({
  required bool loggedIn,
  required bool onboardingDone,
  String token = 'jwt-token',
  String tokenType = 'Bearer',
  int userId = 1,
  String nom = 'Rabe',
  String prenom = 'Test',
  String tel = '0340000000',
  String region = 'Analamanga',
}) async {
  if (loggedIn) {
    await SessionService.instance
        .saveSession(token: token, tokenType: tokenType);
    await SessionService.instance.saveProfile(
      userId: userId,
      nom: nom,
      prenom: prenom,
      tel: tel,
      region: region,
    );
  } else {
    await SessionService.instance.clearSession();
  }

  _secureStorage['onboarding_done'] = onboardingDone ? 'true' : 'false';
}

Future<void> seedParcelles(List<ParcelleLocal> parcelles) async {
  final db = IsarService.instance.db;
  await db.writeTxn(() async {
    await db.parcelleLocals.clear();
    await db.parcelleLocals.putAll(parcelles);
  });
}

Future<void> seedDiagnostics(List<DiagnosticLocal> diagnostics) async {
  final db = IsarService.instance.db;
  await db.writeTxn(() async {
    await db.diagnosticLocals.clear();
    await db.diagnosticLocals.putAll(diagnostics);
  });
}

Future<void> pumpApp(
  PatrolIntegrationTester $, {
  required bool loggedIn,
  required bool onboardingDone,
  bool isTfliteReady = true,
  DiagnosticResult? tfliteResult,
  MockTFLiteService? tfliteService,
  MockSessionService? sessionService,
  TestImagePickerPlatform? imagePickerPlatform,
  List<Override> additionalOverrides = const <Override>[],
}) async {
  await installTestHarness();
  await seedSession(loggedIn: loggedIn, onboardingDone: onboardingDone);

  final effectiveTfliteService = tfliteService ??
      buildMockTfliteService(result: tfliteResult, isReady: isTfliteReady);
  final effectiveSessionService = sessionService ?? MockSessionService();

  when(() => effectiveSessionService.isLoggedIn())
      .thenAnswer((_) async => loggedIn);
  when(() => effectiveSessionService.getProfile()).thenAnswer(
    (_) async => <String, String?>{
      'nom': 'Rabe',
      'prenom': 'Test',
      'tel': '0340000000',
      'region': 'Analamanga',
    },
  );

  if (imagePickerPlatform != null) {
    ImagePickerPlatform.instance = imagePickerPlatform;
  }

  await $.pumpWidgetAndSettle(
    ProviderScope(
      overrides: [
        isTFLiteReadyProvider.overrideWithValue(isTfliteReady),
        tfliteServiceProvider.overrideWithValue(effectiveTfliteService),
        sessionServiceProvider.overrideWithValue(effectiveSessionService),
        ...additionalOverrides,
      ],
      child: const AgriMadaApp(),
    ),
  );
}
