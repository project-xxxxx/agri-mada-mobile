import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/providers/locale_provider.dart';
import 'package:agri_mada/features/agent/data/agent_remote_datasource.dart';
import 'package:agri_mada/features/agent/presentation/providers/agent_provider.dart';

import 'agent_test_outils.dart';

void main() {
  late FauxDatasource datasource;
  late int synchronisations;

  ProviderContainer conteneur({Locale locale = const Locale('fr')}) {
    final conteneur = ProviderContainer(
      overrides: [
        agentRemoteDatasourceProvider.overrideWithValue(datasource),
        synchroniserAvantConseilProvider.overrideWithValue(() async => synchronisations++),
        initialLocaleProvider.overrideWithValue(locale),
        accordConseillerProvider.overrideWith(() => FauxAccord(true)),
      ],
    );
    addTearDown(conteneur.dispose);
    return conteneur;
  }

  setUp(() {
    datasource = FauxDatasource();
    synchronisations = 0;
  });

  test('les scans sont synchronisés avant chaque question', () async {
    final c = conteneur();

    await c.read(conversationConseillerProvider.notifier).envoyer('Que dit mon dernier scan ?');

    expect(synchronisations, 1);
    final etat = c.read(conversationConseillerProvider);
    expect(etat.elements, hasLength(2));
    expect(etat.questionsRestantes, 19);
    expect(etat.envoiEnCours, isFalse);
  });

  test("l'échange signé de la première réponse accompagne la deuxième question", () async {
    final c = conteneur();
    final notifier = c.read(conversationConseillerProvider.notifier);

    await notifier.envoyer('Question un ?');
    await notifier.envoyer('Question deux ?');

    expect(datasource.appels[0].historique, isEmpty);
    expect(datasource.appels[1].historique.single.question, 'Question un ?');
    expect(datasource.appels[1].conversationId, datasource.appels[0].conversationId);
  });

  test("l'historique renvoyé se limite aux six derniers échanges", () async {
    final c = conteneur();
    final notifier = c.read(conversationConseillerProvider.notifier);

    for (var i = 1; i <= 8; i++) {
      await notifier.envoyer('Question $i ?');
    }

    final historique = datasource.appels.last.historique;
    expect(historique, hasLength(maxEchangesHistorique));
    expect(historique.first.question, 'Question 2 ?');
    expect(historique.last.question, 'Question 7 ?');
  });

  test('en malgache, la question part avec la langue mg', () async {
    final c = conteneur(locale: const Locale('mg'));

    await c.read(conversationConseillerProvider.notifier).envoyer('Inona ny menalavitra?');

    expect(datasource.appels.single.langue, 'mg');
  });

  test('une question trop courte ou un double envoi ne partent pas', () async {
    final c = conteneur();
    final notifier = c.read(conversationConseillerProvider.notifier);

    await notifier.envoyer('  a ');
    final premier = notifier.envoyer('Question un ?');
    final second = notifier.envoyer('Question deux ?');
    await Future.wait([premier, second]);

    expect(datasource.appels.map((a) => a.question), ['Question un ?']);
  });

  test("un échec retire la question du fil et la rend à l'utilisateur", () async {
    datasource.prevoir(AgentErreur.quotaAtteint);
    final c = conteneur();

    await c.read(conversationConseillerProvider.notifier).envoyer('Question refusée ?');

    final etat = c.read(conversationConseillerProvider);
    expect(etat.elements, isEmpty);
    expect(etat.erreur, AgentErreur.quotaAtteint);
    expect(etat.questionNonEnvoyee, 'Question refusée ?');
    expect(etat.envoiEnCours, isFalse);
  });

  test('un historique refusé par le serveur recommence la conversation', () async {
    final c = conteneur();
    final notifier = c.read(conversationConseillerProvider.notifier);
    await notifier.envoyer('Question un ?');
    final ancienne = c.read(conversationConseillerProvider).conversationId;

    datasource.prevoir(AgentErreur.historiqueInvalide);
    await notifier.envoyer('Question deux ?');

    final etat = c.read(conversationConseillerProvider);
    expect(etat.conversationId, isNot(ancienne));
    expect(etat.elements, isEmpty);
    expect(etat.historique, isEmpty);
    expect(etat.questionNonEnvoyee, 'Question deux ?');
    expect(etat.questionsRestantes, 19);
  });

  test("un refus d'accord côté serveur retire l'accord local", () async {
    datasource.prevoir(AgentErreur.consentementRequis);
    final c = conteneur();
    await c.read(accordConseillerProvider.future);

    await c.read(conversationConseillerProvider.notifier).envoyer('Question ?');
    await Future<void>.delayed(Duration.zero);

    expect(c.read(accordConseillerProvider).value, isFalse);
  });

  test('une nouvelle conversation vide le fil mais garde le quota connu', () async {
    final c = conteneur();
    final notifier = c.read(conversationConseillerProvider.notifier);
    await notifier.envoyer('Question un ?');
    final ancienne = c.read(conversationConseillerProvider).conversationId;

    notifier.nouvelleConversation();

    final etat = c.read(conversationConseillerProvider);
    expect(etat.elements, isEmpty);
    expect(etat.conversationId, isNot(ancienne));
    expect(etat.questionsRestantes, 19);
  });
}
