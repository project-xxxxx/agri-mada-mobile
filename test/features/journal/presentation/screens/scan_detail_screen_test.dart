import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/app/router.dart';
import 'package:agri_mada/core/ai/diagnosis_certainty.dart';
import 'package:agri_mada/features/journal/domain/entities/detail_scan.dart';
import 'package:agri_mada/features/journal/domain/entities/resultat_scan.dart';
import 'package:agri_mada/features/journal/presentation/providers/journal_provider.dart';
import 'package:agri_mada/features/journal/presentation/screens/scan_detail_screen.dart';
import 'package:agri_mada/features/knowledge/presentation/providers/fiches_provider.dart';
import 'package:agri_mada/features/scan/data/repositories/session_local_repository.dart';
import 'package:agri_mada/features/scan/domain/entities/organe.dart';
import 'package:agri_mada/features/scan/presentation/providers/session_scan_provider.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

class _MockRepository extends Mock implements SessionLocalRepository {}

DetailScan _detail({
  String? ficheId = 'blb',
  String certitude = 'possible',
  bool synchronise = false,
}) =>
    DetailScan(
      resume: ResultatScan(
        sessionId: 7,
        date: DateTime(2026, 9, 17, 9, 30),
        organes: const [Organe.feuille],
        ficheId: ficheId,
        certitude: certitude,
        graviteDeclaree: 'plus_tiers',
        nbPhotos: 1,
      ),
      photos: const [
        PhotoDuScan(
          organe: Organe.feuille,
          imagePath: 'absente.jpg',
          reponses: {'feuille_taches': 'bandes_bord'},
        ),
      ],
      classement: const [ScoredLabel('blb', 0.6), ScoredLabel('bls', 0.3)],
      estSynchronise: synchronise,
    );

void main() {
  late _MockRepository repository;

  setUp(() {
    repository = _MockRepository();
    when(() => repository.supprimerSession(any())).thenAnswer((_) async {});
  });

  Future<void> pumpDetail(WidgetTester tester, DetailScan? detail) async {
    final router = GoRouter(
      initialLocation: AppRoutes.scanDetailPath(7),
      routes: [
        GoRoute(path: AppRoutes.journal, builder: (context, state) => const Text('Journal')),
        GoRoute(
          path: AppRoutes.scanDetail,
          builder: (context, state) => ScanDetailScreen(
            sessionId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          detailScanProvider(7).overrideWith((ref) async => detail),
          parcellesProvider.overrideWith((ref) async => const []),
          fichesProvider.overrideWith((ref) async => const []),
          sessionRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('fr'),
          supportedLocales: const [Locale('fr'), Locale('mg')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // La page défile verticalement ; la rangée de photos a son propre défilement.
  Future<void> defilerJusqua(WidgetTester tester, Finder cible) =>
      tester.scrollUntilVisible(cible, 200, scrollable: find.byType(Scrollable).first);

  testWidgets('un scan nommé reste une piste à confirmer, avec les autres pistes et les réponses',
      (tester) async {
    await pumpDetail(tester, _detail());

    expect(find.text('Piste à confirmer'), findsOneWidget);
    expect(find.textContaining('Autres possibilités'), findsOneWidget);
    expect(find.textContaining('Plus d\'un tiers'), findsOneWidget);
    expect(find.textContaining('Bandes gris-vert puis jaunes', findRichText: true), findsOneWidget);
    await defilerJusqua(tester, find.text('Pas encore rattaché à une parcelle'));
    expect(find.text('Pas encore rattaché à une parcelle'), findsOneWidget);
  });

  testWidgets('un scan non nommé ne montre aucune piste du modèle (ADR-006)', (tester) async {
    await pumpDetail(tester, _detail(ficheId: null, certitude: 'incertain'));

    expect(find.text('Résultat non nommé'), findsOneWidget);
    expect(find.textContaining('Autres possibilités'), findsNothing);
    expect(find.text('Piste à confirmer'), findsNothing);
  });

  testWidgets('un scan disparu le dit', (tester) async {
    await pumpDetail(tester, null);

    expect(find.text('Ce scan n\'existe plus sur ce téléphone.'), findsOneWidget);
  });

  testWidgets('supprimer demande confirmation, prévient pour le serveur, puis revient au journal',
      (tester) async {
    await pumpDetail(tester, _detail(synchronise: true));

    await defilerJusqua(tester, find.text('Supprimer ce scan'));
    await tester.tap(find.text('Supprimer ce scan'));
    await tester.pumpAndSettle();

    expect(find.textContaining('il y reste enregistré'), findsOneWidget);
    verifyNever(() => repository.supprimerSession(any()));

    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();

    verify(() => repository.supprimerSession(7)).called(1);
    expect(find.text('Journal'), findsOneWidget);
  });

  testWidgets('annuler la suppression ne supprime rien', (tester) async {
    await pumpDetail(tester, _detail());

    await defilerJusqua(tester, find.text('Supprimer ce scan'));
    await tester.tap(find.text('Supprimer ce scan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    verifyNever(() => repository.supprimerSession(any()));
    expect(find.byType(ScanDetailScreen), findsOneWidget);
  });
}
