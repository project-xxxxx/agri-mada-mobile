import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_mada/app/app.dart';
import 'package:agri_mada/app/router.dart';
import 'package:agri_mada/core/sync/providers/sync_provider.dart';
import 'package:agri_mada/features/auth/presentation/providers/session_provider.dart';
import 'package:agri_mada/features/journal/presentation/providers/journal_provider.dart';
import 'package:agri_mada/features/journal/domain/entities/journal_entry.dart';

class _FakeSyncNotifier extends SyncNotifier {
  @override
  SyncState build() => const SyncState.idle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final storage = <String, String>{};

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel,
            (MethodCall call) async {
      final args = call.arguments as Map<String, dynamic>;
      switch (call.method) {
        case 'write':
          storage[args['key'] as String] =
              args['value'] as String;
          return null;
        case 'read':
          return storage[args['key'] as String];
        case 'delete':
          storage.remove(args['key'] as String);
          return null;
        case 'deleteAll':
          storage.clear();
          return null;
        default:
          return null;
      }
    });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  setUp(() {
    storage.clear();
  });

  Future<(ProviderContainer, GoRouter)> pumpApp(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        syncNotifierProvider.overrideWith(_FakeSyncNotifier.new),
        sessionProvider.overrideWith((ref) async {
          return {'prenom': 'Jean'};
        }),
        journalAgricoleProvider.overrideWith((ref) async {
          return <JournalEntry>[];
        }),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AgriMadaApp(),
      ),
    );
    await tester.pumpAndSettle();

    final router = container.read(routerProvider);
    return (container, router);
  }

  group('Router guards', () {
    testWidgets('redirige vers onboarding si onboarding non termine', (
      tester,
    ) async {
      // Arrange
      storage['onboarding_done'] = 'false';

      // Act
      final (container, _) = await pumpApp(tester);

      // Assert
      expect(find.text('Passer'), findsOneWidget);
      container.dispose();
    });

    testWidgets('redirige vers welcome si onboarding termine et non connecte', (
      tester,
    ) async {
      // Arrange
      storage['onboarding_done'] = 'true';

      // Act
      final (container, _) = await pumpApp(tester);

      // Assert
      expect(find.text('Commencer'), findsOneWidget);
      container.dispose();
    });

    testWidgets('redirige vers login quand route protegee et non connecte', (
      tester,
    ) async {
      // Arrange
      storage['onboarding_done'] = 'true';

      // Act
      final (container, router) = await pumpApp(tester);
      router.go(AppRoutes.home);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Mot de passe oublie ?'), findsOneWidget);
      container.dispose();
    });

    testWidgets('redirige vers home quand connecte et acces login',
        (tester) async {
      // Arrange
      storage['onboarding_done'] = 'true';
      storage['auth_token'] = 'jwt-token';
      storage['auth_token_type'] = 'bearer';

      // Act
      final (container, router) = await pumpApp(tester);
      router.go(AppRoutes.login);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.menu), findsOneWidget);
      container.dispose();
    });
  });
}
