import 'package:dio/dio.dart';

import 'failure.dart';

/// Cause d'un échec réseau déduite de l'exception Dio (tâche P1.5).
FailureCode failureCodeForDio(DioException e) => switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        FailureCode.timeout,
      DioExceptionType.connectionError => FailureCode.offline,
      DioExceptionType.badResponse => switch (e.response?.statusCode) {
          401 || 403 => FailureCode.sessionExpired,
          422 => FailureCode.invalidData,
          429 => FailureCode.tooManyAttempts,
          _ => FailureCode.server,
        },
      _ => e.error is AuthFailure ? FailureCode.sessionExpired : FailureCode.unknown,
    };

sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends AppException {
  const NetworkException(super.message);

  factory NetworkException.fromDioError(DioException e) {
    final responseData = e.response?.data;
    final responseMap =
        responseData is Map<String, dynamic> ? responseData : null;

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const NetworkException('Délai de connexion dépassé'),
      DioExceptionType.connectionError =>
        const NetworkException('Impossible de se connecter au serveur'),
      DioExceptionType.badResponse => NetworkException(
          responseMap?['message'] as String? ??
              responseMap?['detail'] as String? ??
              'Erreur serveur',
        ),
      _ => NetworkException(e.message ?? 'Erreur réseau inconnue'),
    };
  }
}

final class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});
  final int? statusCode;
}

final class ParseException extends AppException {
  const ParseException(super.message);
}

final class AuthException extends AppException {
  const AuthException(super.message);
}
