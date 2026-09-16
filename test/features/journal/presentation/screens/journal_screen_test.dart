import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/local_db/models/diagnostic_local.dart';
import 'package:agri_mada/features/journal/presentation/diagnostic_filter.dart';
import 'package:agri_mada/features/journal/presentation/providers/journal_provider.dart';
import 'package:agri_mada/features/journal/presentation/screens/journal_screen.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

DiagnosticLocal _diagnostic(
  int id,
  String label,
  DateTime date, {
  String? severity,
}) =>
    DiagnosticLocal()
      ..id = id
      ..parcelleLocalId = 1
      ..maladieDetectee = label
      ..niveauGravite = severity
      ..dateDiagnostic = date;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.now();
  final healthyToday = _diagnostic(1, 'healthy', now);
  final severeYesterday = _diagnostic(
    2,
    'Brown spot',
    now.subtract(const Duration(days: 1)),
    severity: 'plus_tiers',
  );
  final oldSmut = _diagnostic(
    3,
    'Leaf smut',
    now.subtract(const Duration(days: 30)),
    severity: 'quelques_plants',
  );
  final all = [healthyToday, severeYesterday, oldSmut];

  group('applyDiagnosticFilter', () {
    final reference = DateTime(2026, 9, 15, 12);
    final recent = _diagnostic(10, 'Brown spot', DateTime(2026, 9, 8, 12));
    final tooOld = _diagnostic(11, 'Brown spot', DateTime(2026, 9, 8, 11, 59));

    test('7 derniers jours : garde la limite exacte, écarte ce qui est plus ancien', () {
      expect(
        applyDiagnosticFilter([recent, tooOld], DiagnosticFilter.lastSevenDays, now: reference),
        [recent],
      );
    });

    test('grave : seulement « plus d\'un tiers » déclaré par l\'agriculteur', () {
      expect(applyDiagnosticFilter(all, DiagnosticFilter.severe), [severeYesterday]);
    });

    test('sains : seulement les plantes saines', () {
      expect(applyDiagnosticFilter(all, DiagnosticFilter.healthy), [healthyToday]);
    });

    test('tous : rien n\'est écarté', () {
      expect(applyDiagnosticFilter(all, DiagnosticFilter.all), all);
    });
  });

  group('JournalScreen', () {
    Future<void> pumpJournal(WidgetTester tester, List<DiagnosticLocal> diagnostics) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            diagnosticsHistoryProvider.overrideWith((ref) async => diagnostics),
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

    const healthyName = 'Plante saine';
    const brownSpotName = 'Helminthosporiose (tache brune)';
    const smutName = 'Charbon foliaire';

    testWidgets('les filtres restreignent réellement la liste', (tester) async {
      await pumpJournal(tester, all);
      expect(find.text(healthyName), findsOneWidget);
      expect(find.text(brownSpotName), findsOneWidget);
      expect(find.text(smutName), findsOneWidget);

      await tapChip(tester, '7 derniers jours');
      expect(find.text(smutName), findsNothing);
      expect(find.text(brownSpotName), findsOneWidget);

      await tapChip(tester, "Plus d'un tiers touché");
      expect(find.text(brownSpotName), findsOneWidget);
      expect(find.text(healthyName), findsNothing);

      await tapChip(tester, 'Sains');
      expect(find.text(healthyName), findsOneWidget);
      expect(find.text(brownSpotName), findsNothing);

      await tapChip(tester, 'Tous');
      expect(find.text(smutName), findsOneWidget);
    });

    testWidgets('un filtre sans résultat le dit clairement', (tester) async {
      await pumpJournal(tester, [healthyToday]);

      await tapChip(tester, "Plus d'un tiers touché");

      expect(find.text('Aucune analyse ne correspond à ce filtre'), findsOneWidget);
    });
  });
}
