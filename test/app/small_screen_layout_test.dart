// Garde-fou P1.10 : aucun écran d'entrée ne doit déborder sur un téléphone
// d'entrée de gamme (360 dp de large), en français comme en malgache.
//
// Les écrans du parcours multi-organes (P2) sont couverts ici aussi : c'est le
// parcours le plus chargé de l'app (aperçu caméra, questions, résultat fusionné).

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_mada/core/ai/diagnosis_certainty.dart';
import 'package:agri_mada/core/ai/diagnosis_fusion.dart';
import 'package:agri_mada/core/ai/image_quality.dart';
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
import 'package:agri_mada/features/scan/domain/entities/organe.dart';
import 'package:agri_mada/features/scan/presentation/providers/session_scan_provider.dart';
import 'package:agri_mada/features/scan/presentation/screens/capture_screen.dart';
import 'package:agri_mada/features/scan/presentation/screens/organ_picker_screen.dart';
import 'package:agri_mada/features/scan/presentation/screens/scan_questions_screen.dart';
import 'package:agri_mada/features/scan/presentation/screens/session_result_screen.dart';
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

class _SeededSessionNotifier extends ScanSessionNotifier {
  _SeededSessionNotifier(super.ref, ScanSessionState etat) {
    state = etat;
  }
}

const _qualite = ImageQualityReport(
  nettete: 400,
  luminosite: 0.5,
  partBrulee: 0.01,
  probleme: null,
);

const _photoFeuille = PhotoObservee(
  organe: Organe.feuille,
  chemin: 'feuille.jpg',
  qualite: _qualite,
);

/// Écrans de scan : l'état est semé à la main, aucune base ni caméra n'est
/// nécessaire pour juger de la mise en page.
List<Override> _scan(ScanSessionState etat) => [
      scanSessionProvider.overrideWith((ref) => _SeededSessionNotifier(ref, etat)),
      camerasProvider.overrideWith((ref) async => const <CameraDescription>[]),
    ];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sizes = [Size(360, 640), Size(360, 780)];
  const locales = [Locale('fr'), Locale('mg')];

  // Cas le plus dense du résultat : une fiche nommée, un second candidat, les
  // gestes du catalogue, et la session sans parcelle (bloc de rattachement).
  const resultat = ScanSessionState(
    etape: EtapeScan.resultat,
    organe: Organe.feuille,
    sessionId: 1,
    photos: [_photoFeuille],
    fusion: FusedDiagnosis(
      classement: [
        ScoredLabel('Bacterial leaf blight', 0.55),
        ScoredLabel('Brown spot', 0.30),
      ],
      certitude: DiagnosisCertainty.possible,
      nommable: true,
    ),
  );

  final screens = <String, (Widget, bool, List<Override>)>{
    'connexion': (const LoginScreen(), false, const []),
    'inscription': (const RegisterScreen(), false, const []),
    'bienvenue': (const WelcomeScreen(), false, const []),
    'onboarding': (const OnboardingScreen(), false, const []),
    'accueil': (const HomeScreen(), true, const []),
    'scan-organe': (const OrganPickerScreen(), false, const []),
    'scan-capture': (
      const CaptureScreen(),
      false,
      // Avec un refus affiché : c'est la variante la plus haute de l'écran.
      _scan(const ScanSessionState(
        etape: EtapeScan.capture,
        organe: Organe.feuille,
        sessionId: 1,
        photos: [_photoFeuille],
        dernierRefus: ImageQualityIssue.contreJour,
      )),
    ),
    'scan-questions': (
      const ScanQuestionsScreen(),
      false,
      _scan(const ScanSessionState(
        etape: EtapeScan.questions,
        organe: Organe.feuille,
        sessionId: 1,
        photos: [_photoFeuille],
      )),
    ),
    'scan-resultat': (const SessionResultScreen(), false, _scan(resultat)),
  };

  Future<void> pumpAt(
    WidgetTester tester, {
    required Widget screen,
    required bool inShell,
    required Size size,
    required Locale locale,
    List<Override> overrides = const [],
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
          ...overrides,
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

  for (final MapEntry(key: name, value: (screen, inShell, overrides))
      in screens.entries) {
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
            overrides: overrides,
          );

          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
