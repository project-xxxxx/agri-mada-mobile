// Appels à l'agent de conseil du serveur (ADR-012).

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/entities/agent_echange.dart';

enum AgentErreur {
  horsLigne,
  sessionExpiree,
  consentementRequis,
  historiqueInvalide,
  quotaAtteint,
  indisponible,
  inconnue,
}

class AgentException implements Exception {
  const AgentException(this.erreur);

  final AgentErreur erreur;

  @override
  String toString() => 'AgentException($erreur)';
}

class AgentRemoteDatasource {
  AgentRemoteDatasource(this._dio);

  final Dio _dio;

  /// L'agent enchaîne recherche et génération : plus long qu'une synchronisation.
  static const Duration delaiReponse = Duration(seconds: 60);

  Future<ReponseAgent> envoyer({
    required String question,
    required String langue,
    required String conversationId,
    required List<EchangeSigne> historique,
  }) async {
    try {
      final reponse = await _dio.post<Map<String, dynamic>>(
        '/agent/message',
        data: {
          'question': question,
          'langue': langue,
          'conversation_id': conversationId,
          'historique': [for (final echange in historique) echange.toJson()],
          // L'écran n'envoie rien tant que l'utilisateur n'a pas accepté.
          'consentement_conservation': true,
        },
        options: Options(receiveTimeout: delaiReponse),
      );
      return ReponseAgent.fromJson(reponse.data!);
    } on DioException catch (erreur) {
      throw AgentException(traduireErreur(erreur));
    }
  }

  /// Droit à l'effacement : renvoie le nombre d'échanges supprimés sur le serveur.
  Future<int> effacerMesEchanges() async {
    try {
      final reponse = await _dio.delete<Map<String, dynamic>>('/agent/traces');
      return (reponse.data?['supprimees'] as int?) ?? 0;
    } on DioException catch (erreur) {
      throw AgentException(traduireErreur(erreur));
    }
  }

  static AgentErreur traduireErreur(DioException erreur) {
    switch (erreur.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return AgentErreur.horsLigne;
      case DioExceptionType.receiveTimeout:
        return AgentErreur.indisponible;
      default:
        break;
    }
    final detail = erreur.response?.data is Map ? (erreur.response!.data as Map)['detail'] : null;
    return switch (erreur.response?.statusCode) {
      401 => AgentErreur.sessionExpiree,
      403 => AgentErreur.consentementRequis,
      // Une question invalide est filtrée par l'écran : un 422 vient de l'historique.
      422 when detail is String => AgentErreur.historiqueInvalide,
      429 => AgentErreur.quotaAtteint,
      503 => AgentErreur.indisponible,
      _ => AgentErreur.inconnue,
    };
  }
}

final agentRemoteDatasourceProvider = Provider<AgentRemoteDatasource>(
  (ref) => AgentRemoteDatasource(ref.watch(dioClientProvider)),
);
