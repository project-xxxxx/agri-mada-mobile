import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/features/agent/data/agent_remote_datasource.dart';
import 'package:agri_mada/features/agent/domain/entities/agent_echange.dart';

import 'agent_test_outils.dart';

DioException _erreurHttp(int statut, {Object? detail}) {
  final requete = RequestOptions(path: '/agent/message');
  return DioException(
    requestOptions: requete,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: requete, statusCode: statut, data: {'detail': detail}),
  );
}

void main() {
  test('une réponse du serveur se lit entièrement', () {
    final reponse = ReponseAgent.fromJson(reponseJson());

    expect(reponse.issue, IssueAgent.repondu);
    expect(reponse.fiches.single.nom(enMalgache: true), 'Menalavitra');
    expect(reponse.sessionsConsultees, [4]);
    expect(reponse.avertissements.map((a) => a.code), ['reponse_automatique', 'fiches_brouillon']);
    expect(reponse.orienterTechnicien, isTrue);
    expect(reponse.questionsRestantes, 19);
  });

  test("l'échange signé repart à l'identique, horodatage compris", () {
    final echange = ReponseAgent.fromJson(reponseJson()).echange;

    expect(echange.toJson()['emis_le'], '2026-09-17T10:00:00Z');
    expect(EchangeSigne.fromJson(echange.toJson()).signature, echange.signature);
  });

  test('une réponse fixe ne donne pas de quota restant, une issue inconnue est tolérée', () {
    final reponse = ReponseAgent.fromJson(reponseJson(issue: 'nouvelle_issue', restantes: null));

    expect(reponse.issue, IssueAgent.inconnue);
    expect(reponse.questionsRestantes, isNull);
  });

  test('une fiche sans nom malgache garde son nom français en malgache', () {
    const fiche = FicheAgent(id: 'bakanae', nomFr: 'Bakanae', statutValidation: 'brouillon');
    expect(fiche.nom(enMalgache: true), 'Bakanae');
  });

  group('traduction des erreurs', () {
    test('réseau', () {
      final erreur = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionError,
      );
      expect(AgentRemoteDatasource.traduireErreur(erreur), AgentErreur.horsLigne);
    });

    test('délai de réponse dépassé : service indisponible, pas hors ligne', () {
      final erreur = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.receiveTimeout,
      );
      expect(AgentRemoteDatasource.traduireErreur(erreur), AgentErreur.indisponible);
    });

    test('codes HTTP', () {
      expect(AgentRemoteDatasource.traduireErreur(_erreurHttp(401)), AgentErreur.sessionExpiree);
      expect(AgentRemoteDatasource.traduireErreur(_erreurHttp(403)), AgentErreur.consentementRequis);
      expect(
        AgentRemoteDatasource.traduireErreur(_erreurHttp(422, detail: 'Historique de conversation invalide')),
        AgentErreur.historiqueInvalide,
      );
      expect(
        AgentRemoteDatasource.traduireErreur(_erreurHttp(422, detail: [{'loc': ['body', 'question']}])),
        AgentErreur.inconnue,
      );
      expect(AgentRemoteDatasource.traduireErreur(_erreurHttp(429)), AgentErreur.quotaAtteint);
      expect(AgentRemoteDatasource.traduireErreur(_erreurHttp(503)), AgentErreur.indisponible);
    });
  });
}
