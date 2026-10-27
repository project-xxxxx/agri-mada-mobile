import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/app/app.dart';
import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/core/local_db/isar_service.dart';
import 'package:agri_mada/core/local_db/models/diagnostic_local.dart';
import 'package:agri_mada/core/local_db/models/parcelle_local.dart';
import 'package:agri_mada/core/local_db/session_service.dart';
import 'package:agri_mada/core/local_db/models/user_local.dart';
import 'package:agri_mada/features/auth/domain/entities/auth_entity.dart';
import 'package:agri_mada/features/auth/domain/usecases/login_usecase.dart';
import 'package:agri_mada/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_mada/features/home/presentation/screens/home_screen.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  final secureStorage = <String, String>{};

  late MockLoginUseCase mockLoginUseCase;

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel,
            (MethodCall call) async {
      final args = call.arguments as Map<String, dynamic>;
      switch (call.method) {
        case 'write':
          secureStorage[args['key'] as String] =
              args['value'] as String;
          return null;
        case 'read':
          return secureStorage[args['key'] as String];
        case 'delete':
          secureStorage.remove(args['key'] as String);
          return null;
        default:
          return null;
      }
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel,
            (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        final tempDir = await Directory.systemTemp.createTemp('agri_mada_it_');
        return tempDir.path;
      }
      return null;
    });
  });

  setUp(() async {
    secureStorage.clear();
    mockLoginUseCase = MockLoginUseCase();
    await IsarService.instance.init();
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
        .setMockMethodCallHandler(secureStorageChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
  });

  testWidgets(
      'lancer app -> splash -> welcome -> login valide -> arrive sur home',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 2600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Arrange
    await SessionService.instance.clearSession();

    const user = UserProfile(
      userId: 'user-1',
      email: 'test@agri.mg',
      phoneNumber: '0340000000',
    );

    when(() => mockLoginUseCase.call(
          tel: any(named: 'tel'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Right<Failure, UserProfile>(user));

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
        ],
        child: const AgriMadaApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Commencer'), findsOneWidget);

    await tester.tap(find.text('Se connecter').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'test@agri.mg');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Se connecter').first);
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('lancer app avec session existante -> splash -> home',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 2600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Arrange
    await SessionService.instance.saveSession(
      token: 'jwt-token',
      tokenType: 'Bearer',
    );

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
        ],
        child: const AgriMadaApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('token expire simule -> splash -> redirection vers login/welcome',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 2600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Arrange
    await SessionService.instance.saveSession(
      token: 'expired-token',
      tokenType: 'Bearer',
    );
    await SessionService.instance.clearSession();

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
        ],
        child: const AgriMadaApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Commencer'), findsOneWidget);
  });
}
