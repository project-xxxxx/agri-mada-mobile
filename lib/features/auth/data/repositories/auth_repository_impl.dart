import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/local_db/session_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, {SessionService? sessionService})
      : _sessionService = sessionService ?? SessionService.instance;

  final AuthRemoteDatasource _remote;
  final SessionService _sessionService;

  @override
  Future<Either<Failure, Unit>> register({
    required String nom,
    required String prenom,
    required String region,
    required String tel,
    required String password,
  }) async {
    try {
      await _remote.register({
        'nom': nom,
        'prenom': prenom,
        'region': region,
        'tel': tel,
        'password': password,
      });
      return const Right(unit);
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 409) {
        AppLogger.error('Inscription échouée', error: e, stackTrace: st);
        return Left(AuthFailure(NetworkException.fromDioError(e).message));
      }

      final exception = NetworkException.fromDioError(e);
      AppLogger.error('Inscription échouée', error: exception, stackTrace: st);
      return Left(NetworkFailure(exception.message));
    } catch (e, st) {
      AppLogger.error('Erreur inconnue', error: e, stackTrace: st);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword({
    required String tel,
  }) async {
    try {
      await _remote.forgotPassword({'tel': tel});
      return const Right(unit);
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 422 ||
          e.response?.statusCode == 429) {
        AppLogger.error(
          'Demande de reinitialisation echouee',
          error: e,
          stackTrace: st,
        );
        return Left(AuthFailure(NetworkException.fromDioError(e).message));
      }

      final exception = NetworkException.fromDioError(e);
      AppLogger.error(
        'Demande de reinitialisation echouee',
        error: exception,
        stackTrace: st,
      );
      return Left(NetworkFailure(exception.message));
    } catch (e, st) {
      AppLogger.error('Erreur inconnue', error: e, stackTrace: st);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final token = await _remote.login(email, password);
      await _sessionService.saveSession(
        token: token.accessToken,
        tokenType: token.tokenType,
      );

      final profileJsonRaw = await _remote.getMe(
        '${token.tokenType} ${token.accessToken}',
      );
      final profileJson = Map<String, dynamic>.from(
        profileJsonRaw as Map<dynamic, dynamic>,
      );

      final userId = profileJson['id'] as int?;
      final nom = profileJson['nom'] as String? ?? '';
      final prenom = profileJson['prenom'] as String? ?? '';
      final tel = profileJson['tel'] as String? ?? '';
      final region = profileJson['region'] as String? ?? '';

      if (userId == null) {
        throw const ParseException('Réponse profil invalide');
      }

      await _sessionService.saveProfile(
        userId: userId,
        nom: nom,
        prenom: prenom,
        tel: tel,
        region: region,
      );

      final profile = UserProfile(
        userId: userId.toString(),
        email: profileJson['email'] as String? ?? '',
        phoneNumber: profileJson['phone_number'] as String? ?? tel,
      );

      AppLogger.debug('Login réussi: ${profile.userId}');
      return Right(profile);
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 401) {
        AppLogger.error('Login échoué', error: e, stackTrace: st);
        return const Left(AuthFailure('Identifiants incorrects'));
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        AppLogger.error('Login échoué', error: e, stackTrace: st);
        return const Left(NetworkFailure('Délai de connexion dépassé'));
      }

      final exception = NetworkException.fromDioError(e);
      AppLogger.error('Login échoué', error: exception, stackTrace: st);
      return Left(NetworkFailure(exception.message));
    } on ParseException catch (e, st) {
      AppLogger.error('Erreur de parsing', error: e, stackTrace: st);
      return Left(ServerFailure(e.message));
    } catch (e, st) {
      AppLogger.error('Erreur inconnue', error: e, stackTrace: st);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    await _sessionService.clearSession();
    return const Right(unit);
  }
}
