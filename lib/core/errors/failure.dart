/// Cause d'un échec, traduite à l'écran par failureMessage (tâche P1.5).
/// Le message des échecs reste réservé aux journaux techniques.
enum FailureCode {
  invalidCredentials,
  tooManyAttempts,
  phoneAlreadyUsed,
  invalidData,
  offline,
  timeout,
  sessionExpired,
  server,
  unknown,
}

sealed class Failure {
  const Failure(this.message, {this.code = FailureCode.unknown});
  final String message;
  final FailureCode code;

  @override
  String toString() => '$runtimeType(${code.name}): $message';
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode, super.code});
  final int? statusCode;
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
