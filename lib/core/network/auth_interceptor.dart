import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/failure.dart';
import '../local_db/session_service.dart';
import '../utils/logger.dart';

/// Joint le jeton d'accès aux requêtes et le renouvelle une seule fois quand
/// le serveur répond 401 (tâche P1.8).
///
/// Il ne supprime jamais la session : hors ligne, ou si le serveur refuse le
/// jeton de rafraîchissement, l'agriculteur garde l'accès à ses données
/// locales. Dans le second cas, la session est marquée « reconnexion
/// requise » et seule la synchronisation attend.
///
/// [QueuedInterceptor] traite les erreurs une par une : plusieurs 401
/// simultanés ne déclenchent qu'un renouvellement.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required SessionService sessionService,
    required Dio plainClient,
  })  : _session = sessionService,
        _plainClient = plainClient;

  final SessionService _session;

  /// Client sans intercepteur, pour le renouvellement et le rejeu : rejouer
  /// avec le client intercepté bloquerait la file d'erreurs.
  final Dio _plainClient;

  static const _retriedKey = 'agrimada_auth_retried';
  static const _authPaths = {
    ApiConstants.login,
    ApiConstants.refreshToken,
    ApiConstants.logout,
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.headers.containsKey('Authorization')) {
      final token = await _session.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 || _authPaths.contains(request.path)) {
      handler.next(err);
      return;
    }
    if (request.extra[_retriedKey] == true) {
      await _session.markReauthRequired();
      handler.next(_asAuthFailure(err));
      return;
    }

    // Une erreur précédente de la file a déjà renouvelé le jeton : on rejoue.
    final currentToken = await _session.getToken();
    if (currentToken != null &&
        currentToken.isNotEmpty &&
        request.headers['Authorization'] != 'Bearer $currentToken') {
      await _retry(request, currentToken, handler);
      return;
    }

    final refreshToken = await _session.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _session.markReauthRequired();
      handler.next(_asAuthFailure(err));
      return;
    }

    final String newAccessToken;
    try {
      final response = await _plainClient.post<Map<String, dynamic>>(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      final data = response.data ?? const <String, dynamic>{};
      final accessToken = data['access_token'];
      if (accessToken is! String || accessToken.isEmpty) {
        throw const FormatException('Réponse de renouvellement sans jeton');
      }
      newAccessToken = accessToken;
      await _session.saveSession(
        token: accessToken,
        tokenType: data['token_type'] as String? ?? 'bearer',
        refreshToken: data['refresh_token'] as String? ?? refreshToken,
      );
    } on DioException catch (refreshError, st) {
      final status = refreshError.response?.statusCode;
      if (status == 401 || status == 403) {
        AppLogger.error(
          'Jeton de rafraîchissement refusé : reconnexion requise',
          error: refreshError,
          stackTrace: st,
        );
        await _session.markReauthRequired();
        handler.next(_asAuthFailure(err));
        return;
      }
      // Réseau coupé pendant le renouvellement : la session reste intacte.
      handler.next(err);
      return;
    } on FormatException catch (e, st) {
      AppLogger.error('Renouvellement de session illisible', error: e, stackTrace: st);
      handler.next(err);
      return;
    }

    await _retry(request, newAccessToken, handler);
  }

  Future<void> _retry(
    RequestOptions request,
    String accessToken,
    ErrorInterceptorHandler handler,
  ) async {
    final options = request.copyWith(
      headers: {...request.headers, 'Authorization': 'Bearer $accessToken'},
      extra: {...request.extra, _retriedKey: true},
    );
    try {
      handler.resolve(await _plainClient.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      if (retryError.response?.statusCode == 401) {
        await _session.markReauthRequired();
        handler.next(_asAuthFailure(retryError));
      } else {
        handler.next(retryError);
      }
    }
  }

  DioException _asAuthFailure(DioException error) =>
      error.copyWith(error: const AuthFailure('Session expirée'));
}
