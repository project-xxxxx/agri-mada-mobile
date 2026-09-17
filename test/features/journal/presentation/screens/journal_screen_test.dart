import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/features/journal/domain/entities/resultat_scan.dart';
import 'package:agri_mada/features/journal/presentation/diagnostic_filter.dart';
import 'package:agri_mada/features/journal/presentation/providers/journal_provider.dart';
import 'package:agri_mada/features/journal/presentation/screens/journal_screen.dart';
import 'package:agri_mada/features/scan/domain/entities/organe.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

ResultatScan _resultat(
  int id,
  String? fiche,
  DateTime date, {
  String? gravite,
  String certitude = 'possible',
  List<Organe> organes = const [Organe.feuille],
}) =>
    ResultatScan(
      sessionId: id,
      date: date,
      organes: organes,
      parcelleLocalId: 1,
      ficheId: fiche,
      certitude: certitude,
      graviteDeclaree: gravite,
      nbPhotos: 1,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.now();
  final sainAujourdhui = _resultat(1, 'healthy', now, certitude: 'probable');
  final graveHier = _resultat(
    2,
    'Brown spot',
    now.subtract(const Duration(days: 1)),
    gravite: 'plus_tiers',
  );
  final ancienCharbon = _resultat(
    3,
    'Leaf smut',
    now.subtract(const Duration(days: 30)),
    gravite: 'quelques_plants',
  );
  final nonNomme = _resultat(
    4,
    null,
    now,
    organes: const [Organe.racines],
    certitude: 'incertain',
  );
  final tous = [sainAujourdhui, graveHier, ancienCharbon];

  group('applyDiagnosticFilter', () {
    final reference = DateTime(2026, 9, 15, 12);
    final recent = _resultat(10, 'Brown spot', DateTime(2026, 9, 8, 12));
    final tropAncien = _resultat(11, 'Brown spot', DateTime(2026, 9, 8, 11, 59));

    test('7 derniers jours : garde la limite exacte, écarte ce qui est plus ancien', () {
      expect(
        applyDiagnosticFilter(
          [recent, tropAncien],
          DiagnosticFilter.lastSevenDays,
          now: reference,
        ),
        [recent],
      );
    });

    test('grave : seulement « plus d\'un tiers » déclaré par l\'agriculteur', () {
      expect(applyDiagnosticFilter(tous, DiagnosticFilter.severe), [graveHier]);
    });

    test('sains : seulement les plantes saines', () {
      expect(applyDiagnosticFilter(tous, DiagnosticFilter.healthy), [sainAujourdhui]);
    });

    test('tous : rien n\'est écarté', () {
      expect(applyDiagnosticFilter(tous, DiagnosticFilter.all), tous);
    });
  });

  group('JournalScreen', () {
    Future<void> pumpJournal(WidgetTester tester, List<ResultatScan> resultats) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            resultatsHistoryProvider.overrideWith((ref) async => resultats),
          ],
          child: const MaterialApp(
            locale: Locale('fr'),
            supportedLocales: [Locale('fr'), Locale('mg')],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: JournalScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> tapChip(WidgetTester tester, String label) async {
      await tester.tap(find.widgetWithText(ChoiceChip, label));
      await tester.pumpAndSettle();
    }

    const nomSain = 'Plante saine';
    const nomTacheBrune = 'Helminthosporiose (tache brune)';
    const nomCharbon = 'Charbon foliaire';

    testWidgets('les filtres restreignent réellement la liste', (tester) async {
      await pumpJournal(tester, tous);
      expect(find.text(nomSain), findsOneWidget);
      expect(find.text(nomTacheBrune), findsOneWidget);
      expect(find.text(nomCharbon), findsOneWidget);

      await tapChip(tester, '7 derniers jours');
      expect(find.text(nomCharbon), findsNothing);
      expect(find.text(nomTacheBrune), findsOneWidget);

      await tapChip(tester, "Plus d'un tiers touché");
      expect(find.text(nomTacheBrune), findsOneWidget);
      expect(find.text(nomSain), findsNothing);

      await tapChip(tester, 'Sains');
      expect(find.text(nomSain), findsOneWidget);
      expect(find.text(nomTacheBrune), findsNothing);

      await tapChip(tester, 'Tous');
      expect(find.text(nomCharbon), findsOneWidget);
    });

    testWidgets('un filtre sans résultat le dit clairement', (tester) async {
      await pumpJournal(tester, [sainAujourdhui]);

      await tapChip(tester, "Plus d'un tiers touché");

      expect(find.text('Aucune analyse ne correspond à ce filtre'), findsOneWidget);
    });

    testWidgets('un scan sans maladie nommée le dit, avec l\'organe observé (P2.3)',
        (tester) async {
      await pumpJournal(tester, [nonNomme]);

      expect(find.text('Résultat non nommé'), findsOneWidget);
      expect(find.text('Racines'), findsOneWidget);
      expect(find.text('À confirmer'), findsOneWidget);
    });

    testWidgets('un résultat probable n\'affiche pas « À confirmer »', (tester) async {
      await pumpJournal(tester, [sainAujourdhui]);

      expect(find.text('À confirmer'), findsNothing);
      expect(find.text('Sain'), findsOneWidget);
    });
  });
}
