import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_mada/app/router.dart';
import 'package:agri_mada/features/auth/presentation/screens/login_screen.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

class _MgMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MgMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mg';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('fr'));

  @override
  bool shouldReload(_MgMaterialLocalizationsDelegate old) => false;
}

class _MgCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _MgCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mg';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('fr'));

  @override
  bool shouldReload(_MgCupertinoLocalizationsDelegate old) => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpLoginScreen(
    WidgetTester tester, {
    Locale locale = const Locale('fr'),
  }) async {
    final router = GoRouter(
      initialLocation: AppRoutes.login,
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Register Target')),
          ),
        ),
        GoRoute(
          path: AppRoutes.reset,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Reset Target')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          locale: locale,
          supportedLocales: const [Locale('fr'), Locale('mg')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            _MgMaterialLocalizationsDelegate(),
            _MgCupertinoLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('locale mg ne leve pas d exception de delegates', (tester) async {
    // Arrange
    await pumpLoginScreen(tester, locale: const Locale('mg'));

    // Assert
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('LoginScreen callbacks', () {
    testWidgets(
      'admin comme identifiant ne declenche pas l erreur email invalide',
      (tester) async {
        // Arrange
        await pumpLoginScreen(tester);

        // Act
        await tester.enterText(find.byType(TextFormField).at(0), 'admin');
        await tester.tap(find.text('Se connecter'));
        await tester.pump();

        // Assert
        expect(find.text('Email invalide'), findsNothing);
        expect(find.text('Veuillez entrer votre mot de passe'), findsOneWidget);
      },
    );

    testWidgets('tap Mot de passe oublie affiche l ecran reset',
        (tester) async {
      // Arrange
      await pumpLoginScreen(tester);

      // Act
      await tester.tap(find.text('Mot de passe oublié ?'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Reset Target'), findsOneWidget);
    });

    testWidgets('tap S\'inscrire affiche l ecran register', (tester) async {
      // Arrange
      await pumpLoginScreen(tester);

      // Act
      await tester.ensureVisible(find.text("S'inscrire"));
      await tester.tap(find.text("S'inscrire"));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Register Target'), findsOneWidget);
    });
  });
}
