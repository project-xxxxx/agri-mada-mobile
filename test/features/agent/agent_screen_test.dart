import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/providers/connectivity_provider.dart';
import 'package:agri_mada/features/agent/data/agent_remote_datasource.dart';
import 'package:agri_mada/features/agent/presentation/providers/agent_provider.dart';
import 'package:agri_mada/features/agent/presentation/screens/agent_screen.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

import 'agent_test_outils.dart';

void main() {
  late FauxDatasource datasource;
  late AppLocalizations loc;

  setUpAll(() async {
    loc = await AppLocalizations.delegate.load(const Locale('fr'));
  });

  setUp(() => datasource = FauxDatasource());

  Future<void> afficher(WidgetTester tester, {bool accord = true, bool enLigne = true}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          agentRemoteDatasourceProvider.overrideWithValue(datasource),
          synchroniserAvantConseilProvider.overrideWithValue(() async {}),
          accordConseillerProvider.overrideWith(() => FauxAccord(accord)),
          isOnlineProvider.overrideWith((ref) => Stream.value(enLigne)),
        ],
        child: MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AgentScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets("sans accord, rien n'est proposé à part la demande d'accord", (tester) async {
    await afficher(tester, accord: false);

    expect(find.text(loc.agentConsentTitle), findsOneWidget);
    expect(find.text(loc.agentConsentBody(dureeConservationJours)), findsOneWidget);
    expect(find.byKey(const Key('agent_saisie')), findsNothing);

    await tester.tap(find.text(loc.agentConsentAccept));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('agent_saisie')), findsOneWidget);
    expect(find.text(loc.agentDisclaimer), findsOneWidget);
  });

  testWidgets('une suggestion envoie la question et affiche la réponse signalée', (tester) async {
    await afficher(tester);

    await tester.tap(find.text(loc.agentSuggestionPrevention));
    await tester.pumpAndSettle();

    expect(datasource.appels.single.question, loc.agentSuggestionPrevention);
    expect(find.text('Piste possible : pyriculariose, à confirmer par un technicien.'), findsOneWidget);
    expect(find.text('Pyriculariose'), findsOneWidget);
    expect(find.text(loc.agentWarningAutomatic), findsOneWidget);
    expect(find.text(loc.agentWarningDraft), findsOneWidget);
    expect(find.text(loc.agentReasonScanToConfirm), findsOneWidget);
    expect(find.text(loc.agentAskTechnician), findsOneWidget);
    expect(find.text(loc.agentQuotaRemaining(19)), findsOneWidget);
  });

  testWidgets('une urgence de santé est mise en évidence', (tester) async {
    datasource.prevoir(reponseJson(
      issue: 'urgence_sante',
      reponse: 'Urgence : allez au centre de santé.',
      orienter: false,
      motifs: const [],
      avertissements: const [],
      restantes: null,
    ));
    await afficher(tester);

    await tester.enterText(find.byKey(const Key('agent_saisie')), "Mon fils a avalé de l'insecticide");
    await tester.pump();
    await tester.tap(find.byKey(const Key('agent_envoyer')));
    await tester.pumpAndSettle();

    expect(find.text(loc.agentUrgentTitle), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.text(loc.agentAskTechnician), findsNothing);
  });

  testWidgets('une erreur de quota est expliquée et la question rendue', (tester) async {
    datasource.prevoir(AgentErreur.quotaAtteint);
    await afficher(tester);

    await tester.enterText(find.byKey(const Key('agent_saisie')), 'Question refusée ?');
    await tester.pump();
    await tester.tap(find.byKey(const Key('agent_envoyer')));
    await tester.pumpAndSettle();

    expect(find.text(loc.agentErrorQuota), findsOneWidget);
    final champ = tester.widget<TextField>(find.byKey(const Key('agent_saisie')));
    expect(champ.controller!.text, 'Question refusée ?');
  });

  testWidgets('hors ligne, la saisie et les suggestions sont désactivées', (tester) async {
    await afficher(tester, enLigne: false);

    expect(find.text(loc.agentOffline), findsOneWidget);
    final champ = tester.widget<TextField>(find.byKey(const Key('agent_saisie')));
    expect(champ.enabled, isFalse);

    await tester.tap(find.text(loc.agentSuggestionScan));
    await tester.pumpAndSettle();
    expect(datasource.appels, isEmpty);
  });

  testWidgets("le bouton d'envoi reste inactif pour une question trop courte", (tester) async {
    await afficher(tester);

    await tester.enterText(find.byKey(const Key('agent_saisie')), 'a');
    await tester.pump();

    final bouton = tester.widget<IconButton>(find.byKey(const Key('agent_envoyer')));
    expect(bouton.onPressed, isNull);
  });

  testWidgets("effacer mes échanges appelle le serveur après confirmation", (tester) async {
    await afficher(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text(loc.agentDeleteHistory));
    await tester.pumpAndSettle();
    await tester.tap(find.text(loc.agentConfirmDelete));
    await tester.pumpAndSettle();

    expect(datasource.effacements, 1);
    expect(find.text(loc.agentDeleteHistoryDone(3)), findsOneWidget);
  });
}
