import 'dart:async';

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
      final exception = NetworkException.fromDioError(e);
      AppLogger.error('Inscription échouée', error: exception, stackTrace: st);

      final status = e.response?.statusCode;
      if (status == 400 || status == 409) {
        // Le serveur refuse un numéro déjà enregistré.
        return Left(AuthFailure(exception.message, code: FailureCode.phoneAlreadyUsed));
      }
      return Left(NetworkFailure(exception.message, code: failureCodeForDio(e)));
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
      final exception = NetworkException.fromDioError(e);
      AppLogger.error(
        'Demande de reinitialisation echouee',
        error: exception,
        stackTrace: st,
      );

      return switch (e.response?.statusCode) {
        400 || 422 => Left(AuthFailure(exception.message, code: FailureCode.invalidData)),
        429 => Left(AuthFailure(exception.message, code: FailureCode.tooManyAttempts)),
        _ => Left(NetworkFailure(exception.message, code: failureCodeForDio(e))),
      };
    } catch (e, st) {
      AppLogger.error('Erreur inconnue', error: e, stackTrace: st);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String tel,
    required String password,
  }) async {
    try {
      final token = await _remote.login(tel, password);
      await _sessionService.saveSession(
        token: token.accessToken,
        tokenType: token.tokenType,
        refreshToken: token.refreshToken,
      );

      final profileJsonRaw = await _remote.getMe(
        '${token.tokenType} ${token.accessToken}',
      );
      final profileJson = Map<String, dynamic>.from(profileJsonRaw as Map);

      final userId = profileJson['id'] as int?;
      final nom = profileJson['nom'] as String? ?? '';
      final prenom = profileJson['prenom'] as String? ?? '';
      final profileTel = profileJson['tel'] as String? ?? '';
      final region = profileJson['region'] as String? ?? '';

      if (userId == null) {
        throw const ParseException('Réponse profil invalide');
      }

      await _sessionService.saveProfile(
        userId: userId,
        nom: nom,
        prenom: prenom,
        tel: profileTel,
        region: region,
      );

      final profile = UserProfile(
        userId: userId.toString(),
        email: profileJson['email'] as String? ?? '',
        phoneNumber: profileJson['phone_number'] as String? ?? profileTel,
      );

      AppLogger.debug('Login réussi: ${profile.userId}');
      return Right(profile);
    } on DioException catch (e, st) {
      AppLogger.error('Login échoué', error: e, stackTrace: st);
      return switch (e.response?.statusCode) {
        401 => const Left(
            AuthFailure('Identifiants incorrects', code: FailureCode.invalidCredentials),
          ),
        // Limitation des tentatives côté serveur (tâche P1.11).
        429 => const Left(
            AuthFailure('Trop de tentatives de connexion', code: FailureCode.tooManyAttempts),
          ),
        _ => Left(
            NetworkFailure(
              NetworkException.fromDioError(e).message,
              code: failureCodeForDio(e),
            ),
          ),
      };
    } on ParseException catch (e, st) {
      AppLogger.error('Erreur de parsing', error: e, stackTrace: st);
      return Left(ServerFailure(e.message, code: FailureCode.server));
    } catch (e, st) {
      AppLogger.error('Erreur inconnue', error: e, stackTrace: st);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    String? refreshToken;
    try {
      refreshToken = await _sessionService.getRefreshToken();
    } catch (e, st) {
      AppLogger.error('Lecture du jeton de rafraîchissement impossible',
          error: e, stackTrace: st);
    }

    await _sessionService.clearSession();

    if (refreshToken != null && refreshToken.isNotEmpty) {
      // Révocation côté serveur au mieux : hors ligne, la déconnexion locale
      // suffit et ne doit pas attendre le délai réseau.
      unawaited(
        _remote.logout({'refresh_token': refreshToken}).catchError(
          (Object e, StackTrace st) => AppLogger.error(
            'Révocation serveur de la session impossible',
            error: e,
            stackTrace: st,
          ),
        ),
      );
    }
    return const Right(unit);
  }
}
