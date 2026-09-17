// Tâche P1.1, portée sur le résultat de session (P2.4) : pour chaque classe du
// modèle, l'écran affiche le nom traduit et exactement les gestes du catalogue,
// sans produit ni dosage, en français comme en malgache.

import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_mada/app/router.dart';
import 'package:agri_mada/core/ai/diagnosis_certainty.dart';
import 'package:agri_mada/core/ai/diagnosis_fusion.dart';
import 'package:agri_mada/core/ai/disease_catalog.dart';
import 'package:agri_mada/core/ai/image_quality.dart';
import 'package:agri_mada/features/scan/domain/entities/organe.dart';
import 'package:agri_mada/features/scan/presentation/providers/session_scan_provider.dart';
import 'package:agri_mada/features/scan/presentation/screens/session_result_screen.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

class _SeededSessionNotifier extends ScanSessionNotifier {
  _SeededSessionNotifier(super.ref, ScanSessionState etat) {
    state = etat;
  }
}

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

const _qualite = ImageQualityReport(
  nettete: 400,
  luminosite: 0.5,
  partBrulee: 0.01,
  probleme: null,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final labels = [
    ...File('assets/model/labels.txt')
        .readAsLinesSync()
        .map((ligne) => ligne.trim())
        .where((ligne) => ligne.isNotEmpty),
    'healthy',
  ];

  final produitOuDose = RegExp(
    r'\d+(,\d+)?\s*(g|kg|l|ml|cl)\s*/|fongicide|cuivre|mancoz|tricyclazole|insecticide|pesticide|herbicide',
    caseSensitive: false,
  );

  Future<void> pumpFusion(WidgetTester tester, FusedDiagnosis fusion, Locale locale) async {
    final etat = ScanSessionState(
      etape: EtapeScan.resultat,
      organe: Organe.feuille,
      sessionId: 1,
      parcelleLocalId: 1,
      photos: [
        PhotoObservee(
          organe: Organe.feuille,
          chemin: 'photo.jpg',
          qualite: _qualite,
          scores: fusion.classement,
        ),
      ],
      fusion: fusion,
    );

    final router = GoRouter(
      initialLocation: AppRoutes.scanSessionResult,
      routes: [
        GoRoute(
          path: AppRoutes.scanSessionResult,
          builder: (context, state) => const SessionResultScreen(),
        ),
        GoRoute(
          path: AppRoutes.journal,
          builder: (context, state) => const Scaffold(body: Text('Journal')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scanSessionProvider.overrideWith((ref) => _SeededSessionNotifier(ref, etat)),
        ],
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

  Future<void> pumpResultat(WidgetTester tester, String label, Locale locale) => pumpFusion(
        tester,
        FusedDiagnosis(
          classement: [ScoredLabel(label, 0.9)],
          certitude: DiagnosisCertainty.possible,
          nommable: true,
        ),
        locale,
      );

  for (final code in ['fr', 'mg']) {
    group('rien de nommé ($code) : le message dit pourquoi (ADR-015)', () {
      final locale = Locale(code);
      final loc = lookupAppLocalizations(locale);
      const incertain = <ScoredLabel>[ScoredLabel('helminthosporiose', 0.4), ScoredLabel('blb', 0.35)];

      testWidgets('photo acceptée mais modèle hésitant : pas « peut-être pas du riz »', (tester) async {
        await pumpFusion(
          tester,
          const FusedDiagnosis(
            classement: incertain,
            certitude: DiagnosisCertainty.incertain,
            nommable: false,
            analyseParModele: true,
            photoAcceptee: true,
          ),
          locale,
        );

        expect(find.text(loc.scanSessionHesitationTitle), findsOneWidget);
        expect(find.text(loc.scanSessionHesitationBody), findsOneWidget);
        expect(find.text(loc.scanUncertainTitle), findsNothing);
        expect(find.text(loc.scanSessionNotRecognizedBody), findsNothing);
        expect(find.text(DiseaseCatalog.displayName('helminthosporiose', loc)), findsNothing,
            reason: 'un résultat incertain ne nomme aucune maladie');
      });

      testWidgets('photo rejetée (pas_riz, végétation) : « ne reconnaît pas cette photo »', (tester) async {
        await pumpFusion(
          tester,
          const FusedDiagnosis(
            classement: <ScoredLabel>[],
            certitude: DiagnosisCertainty.incertain,
            nommable: false,
            analyseParModele: true,
          ),
          locale,
        );

        expect(find.text(loc.scanUncertainTitle), findsOneWidget);
        expect(find.text(loc.scanSessionNotRecognizedBody), findsOneWidget);
        expect(find.text(loc.scanSessionHesitationTitle), findsNothing);
      });

      testWidgets('organe sans modèle : partie non analysée', (tester) async {
        await pumpFusion(
          tester,
          const FusedDiagnosis(
            classement: <ScoredLabel>[],
            certitude: DiagnosisCertainty.incertain,
            nommable: false,
          ),
          locale,
        );

        expect(find.text(loc.scanSessionNoName), findsOneWidget);
        expect(find.text(loc.scanSessionHesitationTitle), findsNothing);
        expect(find.text(loc.scanUncertainTitle), findsNothing);
      });
    });


    for (final label in labels) {
      testWidgets('$label ($code) : nom traduit et gestes du catalogue', (tester) async {
        final locale = Locale(code);
        final loc = lookupAppLocalizations(locale);
        final info = DiseaseCatalog.of(label)!;

        await pumpResultat(tester, label, locale);

        expect(find.text(info.name(loc)), findsOneWidget);
        expect(info.advice, isNotEmpty);
        for (final conseil in info.advice) {
          await tester.scrollUntilVisible(find.text(conseil(loc)), 200);
          expect(find.text(conseil(loc)), findsOneWidget, reason: conseil(loc));
        }

        // Le rappel « pas de traitement chimique » peut nommer ce qu'il exclut.
        final affiches = tester
            .widgetList<Text>(find.byType(Text))
            .map((texte) => texte.data ?? '')
            .where((texte) => texte != loc.scanAdviceNoChemical)
            .join('\n');
        expect(produitOuDose.hasMatch(affiches), isFalse, reason: affiches);
      });
    }
  }
}
