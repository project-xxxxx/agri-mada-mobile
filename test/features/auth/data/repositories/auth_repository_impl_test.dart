import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/core/local_db/session_service.dart';
import 'package:agri_mada/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:agri_mada/features/auth/data/repositories/auth_repository_impl.dart';

class _MockRemote extends Mock implements AuthRemoteDatasource {}

class _MockSession extends Mock implements SessionService {}

DioException _status(int statusCode) => DioException(
      requestOptions: RequestOptions(path: '/auth'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/auth'),
        statusCode: statusCode,
        data: {'detail': 'refusé'},
      ),
    );

DioException _type(DioExceptionType type) =>
    DioException(requestOptions: RequestOptions(path: '/auth'), type: type);

void main() {
  late _MockRemote remote;
  late AuthRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  setUp(() {
    remote = _MockRemote();
    repository = AuthRepositoryImpl(remote, sessionService: _MockSession());
  });

  Future<FailureCode> loginFailureFor(Object error) async {
    when(() => remote.login(any(), any())).thenThrow(error);
    final result = await repository.login(tel: '0340000000', password: 'Password123');
    return result.fold((failure) => failure.code, (_) => fail('connexion inattendue'));
  }

  group('Connexion : cause de l\'échec (P1.5)', () {
    test('401 -> identifiants incorrects', () async {
      expect(await loginFailureFor(_status(401)), FailureCode.invalidCredentials);
    });

    test('429 -> trop de tentatives (limiteur du serveur, P1.11)', () async {
      expect(await loginFailureFor(_status(429)), FailureCode.tooManyAttempts);
    });

    test('pas de réseau -> hors ligne', () async {
      expect(await loginFailureFor(_type(DioExceptionType.connectionError)), FailureCode.offline);
    });

    test('délai dépassé -> délai', () async {
      expect(await loginFailureFor(_type(DioExceptionType.receiveTimeout)), FailureCode.timeout);
    });

    test('500 -> problème serveur', () async {
      expect(await loginFailureFor(_status(500)), FailureCode.server);
    });
  });

  test('inscription : numéro déjà enregistré', () async {
    when(() => remote.register(any())).thenThrow(_status(400));

    final result = await repository.register(
      nom: 'Rabe',
      prenom: 'Soa',
      region: 'Itasy',
      tel: '0340000000',
      password: 'Password123',
    );

    expect(
      result.fold((failure) => failure.code, (_) => fail('inscription inattendue')),
      FailureCode.phoneAlreadyUsed,
    );
  });

  test('mot de passe oublié : trop de demandes', () async {
    when(() => remote.forgotPassword(any())).thenThrow(_status(429));

    final result = await repository.forgotPassword(tel: '0340000000');

    expect(
      result.fold((failure) => failure.code, (_) => fail('succès inattendu')),
      FailureCode.tooManyAttempts,
    );
  });
}
