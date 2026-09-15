// Garde-fou P1.10 : aucun écran d'entrée ne doit déborder sur un téléphone
// d'entrée de gamme (360 dp de large), en français comme en malgache.

import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_mada/core/sync/providers/sync_provider.dart';
import 'package:agri_mada/core/widgets/main_layout.dart';
import 'package:agri_mada/features/auth/presentation/providers/session_provider.dart';
import 'package:agri_mada/features/auth/presentation/screens/login_screen.dart';
import 'package:agri_mada/features/auth/presentation/screens/register_screen.dart';
import 'package:agri_mada/features/auth/presentation/screens/welcome_screen.dart';
import 'package:agri_mada/features/home/presentation/screens/home_screen.dart';
import 'package:agri_mada/features/journal/domain/entities/journal_entry.dart';
import 'package:agri_mada/features/journal/presentation/providers/journal_provider.dart';
import 'package:agri_mada/features/onboarding/presentation/screens/onboarding_screen.dart';
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

class _FakeSyncNotifier extends SyncNotifier {
  @override
  SyncState build() => const SyncState.idle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sizes = [Size(360, 640), Size(360, 780)];
  const locales = [Locale('fr'), Locale('mg')];

  final screens = <String, (Widget, bool)>{
    'connexion': (const LoginScreen(), false),
    'inscription': (const RegisterScreen(), false),
    'bienvenue': (const WelcomeScreen(), false),
    'onboarding': (const OnboardingScreen(), false),
    'accueil': (const HomeScreen(), true),
  };

  Future<void> pumpAt(
    WidgetTester tester, {
    required Widget screen,
    required bool inShell,
    required Size size,
    required Locale locale,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final screenRoute = GoRoute(
      path: '/screen',
      builder: (context, state) => screen,
    );
    final router = GoRouter(
      initialLocation: '/screen',
      routes: [
        if (inShell)
          ShellRoute(
            builder: (context, state, child) => MainLayout(child: child),
            routes: [screenRoute],
          )
        else
          screenRoute,
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncNotifierProvider.overrideWith(_FakeSyncNotifier.new),
          sessionProvider.overrideWith((ref) async => {'prenom': 'Rasoanirina'}),
          journalAgricoleProvider.overrideWith((ref) async => <JournalEntry>[]),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: locale,
          supportedLocales: locales,
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

  for (final MapEntry(key: name, value: (screen, inShell)) in screens.entries) {
    for (final locale in locales) {
      for (final size in sizes) {
        final label =
            '$name ${locale.languageCode} ${size.width.toInt()}x${size.height.toInt()}';
        testWidgets('$label : aucun débordement', (tester) async {
          await pumpAt(
            tester,
            screen: screen,
            inShell: inShell,
            size: size,
            locale: locale,
          );

          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
