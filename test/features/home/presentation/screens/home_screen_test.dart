import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/core/providers/connectivity_provider.dart';
import 'package:agri_mada/core/providers/tflite_provider.dart';
import 'package:agri_mada/core/widgets/main_layout.dart';
import 'package:agri_mada/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:agri_mada/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_mada/core/sync/providers/sync_provider.dart';
import 'package:agri_mada/features/auth/presentation/providers/session_provider.dart';
import 'package:agri_mada/features/home/presentation/screens/home_screen.dart';
import 'package:agri_mada/features/journal/presentation/providers/journal_provider.dart';
import 'package:agri_mada/features/journal/domain/entities/journal_entry.dart';
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

class _MockAuthRepositoryImpl extends Mock implements AuthRepositoryImpl {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget target(String label) =>
      Scaffold(body: Center(child: Text(label)));

  /// Accueil rendu comme dans l'application : dans le shell MainLayout,
  /// qui porte le menu latéral et la barre de navigation.
  Future<void> pumpHome(
    WidgetTester tester, {
    List<Override> extraOverrides = const [],
  }) async {
    final router = GoRouter(
      initialLocation: '/landing',
      routes: [
        GoRoute(path: '/', builder: (context, state) => target('Splash Target')),
        ShellRoute(
          builder: (context, state, child) => MainLayout(child: child),
          routes: [
            GoRoute(
              path: '/landing',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        GoRoute(path: '/home', builder: (context, state) => target('Home Target')),
        GoRoute(path: '/scanning', builder: (context, state) => target('Scanning Target')),
        GoRoute(path: '/journal', builder: (context, state) => target('Journal Target')),
        GoRoute(path: '/settings', builder: (context, state) => target('Settings Target')),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncNotifierProvider.overrideWith(_FakeSyncNotifier.new),
          sessionProvider.overrideWith((ref) async {
            return {'prenom': 'Jean'};
          }),
          journalAgricoleProvider.overrideWith((ref) async {
            return <JournalEntry>[];
          }),
          ...extraOverrides,
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('fr'),
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

  /// La surface de test ne fait que 600 px de haut : « Paramètres » est
  /// sous la ligne de flottaison de la liste du menu.
  Future<void> scrollMenuTo(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(
      find.text(text),
      80,
      scrollable: find.descendant(
        of: find.byType(Drawer),
        matching: find.byType(Scrollable),
      ),
    );
    // Amène l'entrée entièrement dans la zone visible : sinon son centre peut
    // rester sous le bord de la liste et le tap tombe à côté.
    await tester.ensureVisible(find.text(text));
    await tester.pumpAndSettle();
  }

  group('HomeScreen callbacks', () {
    testWidgets('callback menu ouvre le drawer', (tester) async {
      // Arrange
      await pumpHome(tester);

      // Act
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('AgriMada'), findsOneWidget);
      await scrollMenuTo(tester, 'Paramètres');
      expect(find.text('Paramètres'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('callback Paramètres navigue vers /settings', (tester) async {
      // Arrange
      await pumpHome(tester);

      // Act
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await scrollMenuTo(tester, 'Paramètres');
      await tester.tap(find.text('Paramètres'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Settings Target'), findsOneWidget);
    });

    testWidgets('callback Accueil ne crash pas et navigue vers /home', (
      tester,
    ) async {
      // Arrange
      await pumpHome(tester);

      // Act
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Home Target'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('callback Déconnexion appelle logout et navigue vers /', (
      tester,
    ) async {
      // Arrange
      final mockAuthRepository = _MockAuthRepositoryImpl();
      when(() => mockAuthRepository.logout()).thenAnswer(
        (_) async => const Right(unit),
      );
      await pumpHome(
        tester,
        extraOverrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );

      // Act
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Déconnexion'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Splash Target'), findsOneWidget);
      verify(() => mockAuthRepository.logout()).called(1);
    });
  });

  group('HomeScreen états réels (P1.10)', () {
    testWidgets('pas de recherche ni de filtre factices', (tester) async {
      await pumpHome(tester);

      expect(find.byIcon(Icons.search), findsNothing);
      expect(find.byIcon(Icons.tune), findsNothing);
    });

    testWidgets('badge hors ligne affiché seulement sans réseau', (tester) async {
      await pumpHome(
        tester,
        extraOverrides: [
          isOnlineProvider.overrideWith((ref) => Stream.value(false)),
        ],
      );

      expect(find.text('Mode hors ligne'), findsOneWidget);
    });

    testWidgets('aucun badge hors ligne avec réseau', (tester) async {
      await pumpHome(
        tester,
        extraOverrides: [
          isOnlineProvider.overrideWith((ref) => Stream.value(true)),
        ],
      );

      expect(find.text('Mode hors ligne'), findsNothing);
    });

    testWidgets('statut IA suit le chargement réel du modèle', (tester) async {
      await pumpHome(
        tester,
        extraOverrides: [isTFLiteReadyProvider.overrideWithValue(false)],
      );
      expect(find.text('Analyse photo indisponible'), findsOneWidget);
      expect(find.text('Analyse photo prête'), findsNothing);
    });

    testWidgets('logo ISPM affiché dans la carte résumé', (tester) async {
      await pumpHome(tester);

      expect(
        find.image(const AssetImage('assets/images/logo_ispm.png')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel("Logo de l'ISPM"), findsOneWidget);
      expect(find.byIcon(Icons.grass), findsNothing);
    });

    testWidgets('statut IA prêt quand le modèle est chargé', (tester) async {
      await pumpHome(
        tester,
        extraOverrides: [isTFLiteReadyProvider.overrideWithValue(true)],
      );
      expect(find.text('Analyse photo prête'), findsOneWidget);
    });
  });
}
