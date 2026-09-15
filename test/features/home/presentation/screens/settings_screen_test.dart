import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/app/router.dart';
import 'package:agri_mada/core/local_db/session_service.dart';
import 'package:agri_mada/features/auth/presentation/providers/session_provider.dart';
import 'package:agri_mada/features/home/presentation/screens/settings_screen.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

class MockSessionService extends Mock implements SessionService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsScreen', () {
    testWidgets('affiche le profil local de la session', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((ref) async {
              return {
                'nom': 'Rakoto',
                'prenom': 'Jean',
                'tel': '0341234567',
                'region': 'Analamanga',
              };
            }),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('fr')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Jean'), findsOneWidget);
      expect(find.text('0341234567'), findsOneWidget);
      expect(find.text('Analamanga'), findsOneWidget);
    });

    testWidgets('deconnexion renvoie vers la connexion', (tester) async {
      // Arrange
      final sessionService = MockSessionService();
      when(() => sessionService.clearSession()).thenAnswer((_) async {});

      final router = GoRouter(
        initialLocation: AppRoutes.settings,
        routes: [
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.login,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Login Target')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionServiceProvider.overrideWithValue(sessionService),
            sessionProvider.overrideWith((ref) async {
              return {
                'nom': 'Rakoto',
                'prenom': 'Jean',
                'tel': '0341234567',
                'region': 'Analamanga',
              };
            }),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('fr')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Login Target'), findsOneWidget);
      verify(() => sessionService.clearSession()).called(1);
    });
  });
}
