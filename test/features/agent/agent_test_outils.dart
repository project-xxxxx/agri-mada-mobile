// Doublures partagées par les tests du conseiller (ADR-012).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agri_mada/features/agent/data/agent_remote_datasource.dart';
import 'package:agri_mada/features/agent/domain/entities/agent_echange.dart';
import 'package:agri_mada/features/agent/presentation/providers/agent_provider.dart';

Map<String, dynamic> reponseJson({
  String issue = 'repondu',
  String reponse = 'Piste possible : pyriculariose, à confirmer par un technicien.',
  String question = 'Taches en losange ?',
  bool orienter = true,
  List<String> motifs = const ['piste_a_confirmer'],
  List<Map<String, String>> avertissements = const [
    {'code': 'reponse_automatique', 'message': 'Réponse automatique.'},
    {'code': 'fiches_brouillon', 'message': 'Brouillon.'},
  ],
  int? restantes = 19,
  String signature = 'a',
}) {
  return {
    'issue': issue,
    'reponse': reponse,
    'fiches': [
      {'id': 'pyriculariose', 'nom_fr': 'Pyriculariose', 'nom_mg': 'Menalavitra', 'statut_validation': 'brouillon'},
    ],
    'sessions_consultees': [4],
    'avertissements': avertissements,
    'orienter_technicien': orienter,
    'motifs_technicien': motifs,
    'echange': {
      'question': question,
      'reponse': reponse,
      'emis_le': '2026-09-17T10:00:00Z',
      'signature': signature.padRight(64, '0'),
    },
    'questions_restantes': restantes,
  };
}

class FauxDatasource implements AgentRemoteDatasource {
  final appels = <({String question, String langue, String conversationId, List<EchangeSigne> historique})>[];
  final reponses = <Object>[];
  int effacements = 0;

  /// Prochaine réponse : une Map JSON ou une AgentErreur à lever.
  void prevoir(Object reponse) => reponses.add(reponse);

  @override
  Future<ReponseAgent> envoyer({
    required String question,
    required String langue,
    required String conversationId,
    required List<EchangeSigne> historique,
  }) async {
    appels.add((question: question, langue: langue, conversationId: conversationId, historique: historique));
    final prevue = reponses.isEmpty
        ? reponseJson(question: question, signature: '${appels.length}')
        : reponses.removeAt(0);
    if (prevue is AgentErreur) throw AgentException(prevue);
    return ReponseAgent.fromJson(prevue as Map<String, dynamic>);
  }

  @override
  Future<int> effacerMesEchanges() async {
    effacements++;
    return 3;
  }
}

class FauxAccord extends AccordConseillerNotifier {
  FauxAccord(this.initial);

  final bool initial;

  @override
  Future<bool> build() async => initial;

  @override
  Future<void> accepter() async => state = const AsyncData(true);

  @override
  Future<void> retirer() async => state = const AsyncData(false);
}
