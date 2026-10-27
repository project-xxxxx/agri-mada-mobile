import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/core/constants/api_constants.dart';
import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/core/local_db/session_service.dart';
import 'package:agri_mada/core/network/auth_interceptor.dart';

class _MockSessionService extends Mock implements SessionService {}

typedef _Route = Future<(int, Object?)> Function(RequestOptions options);

/// Serveur scripté : répond selon la requête et garde la trace des appels.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.route);

  final _Route route;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = await route(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _MockSessionService session;
  String? accessToken;
  String? refreshToken;
  late bool reauthRequired;

  setUp(() {
    session = _MockSessionService();
    accessToken = 'ancien';
    refreshToken = 'refresh-1';
    reauthRequired = false;

    when(() => session.getToken()).thenAnswer((_) async => accessToken);
    when(() => session.getRefreshToken()).thenAnswer((_) async => refreshToken);
    when(() => session.markReauthRequired()).thenAnswer((_) async {
      reauthRequired = true;
    });
    when(
      () => session.saveSession(
        token: any(named: 'token'),
        tokenType: any(named: 'tokenType'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((invocation) async {
      accessToken = invocation.namedArguments[#token] as String;
      refreshToken = invocation.namedArguments[#refreshToken] as String?;
    });
  });

  (Dio, _ScriptedAdapter) buildClient(_Route route) {
    final adapter = _ScriptedAdapter(route);
    final options = BaseOptions(baseUrl: 'https://api.test');
    final plainClient = Dio(options.copyWith())..httpClientAdapter = adapter;
    final dio = Dio(options)
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(sessionService: session, plainClient: plainClient),
      );
    return (dio, adapter);
  }

  _Route server({int refreshStatus = 200, bool refreshOffline = false}) {
    return (options) async {
      if (options.path == ApiConstants.refreshToken) {
        if (refreshOffline) {
          throw DioException.connectionError(
            requestOptions: options,
            reason: 'hors ligne',
          );
        }
        return refreshStatus == 200
            ? (
                200,
                {
                  'access_token': 'nouveau',
                  'token_type': 'bearer',
                  'refresh_token': 'refresh-2',
                },
              )
            : (refreshStatus, {'detail': 'refusé'});
      }
      return options.headers['Authorization'] == 'Bearer nouveau'
          ? (200, {'ok': true})
          : (401, {'detail': 'expiré'});
    };
  }

  int refreshCalls(_ScriptedAdapter adapter) => adapter.requests
      .where((request) => request.path == ApiConstants.refreshToken)
      .length;

  test('401 : renouvelle le jeton une fois puis rejoue la requête', () async {
    final (dio, adapter) = buildClient(server());

    final response = await dio.post<Object?>('/sync/parcelles', data: {});

    expect(response.statusCode, 200);
    expect(accessToken, 'nouveau');
    expect(refreshToken, 'refresh-2');
    expect(refreshCalls(adapter), 1);
    expect(reauthRequired, isFalse);
    verifyNever(() => session.clearSession());
  });

  test('jeton de rafraîchissement refusé : reconnexion requise, session conservée',
      () async {
    final (dio, _) = buildClient(server(refreshStatus: 401));

    await expectLater(
      dio.post<Object?>('/sync/parcelles'),
      throwsA(
        isA<DioException>().having((e) => e.error, 'error', isA<AuthFailure>()),
      ),
    );

    expect(reauthRequired, isTrue);
    expect(accessToken, 'ancien');
    verifyNever(() => session.clearSession());
  });

  test('hors ligne pendant le renouvellement : rien n\'est modifié', () async {
    final (dio, _) = buildClient(server(refreshOffline: true));

    await expectLater(
      dio.post<Object?>('/sync/parcelles'),
      throwsA(
        isA<DioException>()
            .having((e) => e.response?.statusCode, 'statusCode', 401),
      ),
    );

    expect(reauthRequired, isFalse);
    expect(accessToken, 'ancien');
    verifyNever(() => session.clearSession());
  });

  test('deux 401 simultanés : un seul renouvellement', () async {
    final (dio, adapter) = buildClient(server());

    final responses = await Future.wait([
      dio.get<Object?>('/journal/'),
      dio.get<Object?>(ApiConstants.me),
    ]);

    expect(responses.map((r) => r.statusCode), everyElement(200));
    expect(refreshCalls(adapter), 1);
  });

  test('401 sur la connexion : aucun renouvellement tenté', () async {
    final (dio, adapter) = buildClient((_) async => (401, {'detail': 'incorrect'}));

    await expectLater(
      dio.post<Object?>(ApiConstants.login),
      throwsA(isA<DioException>()),
    );

    expect(adapter.requests, hasLength(1));
    expect(reauthRequired, isFalse);
  });

  test('sans jeton de rafraîchissement : reconnexion requise sans appel réseau',
      () async {
    refreshToken = null;
    final (dio, adapter) = buildClient(server());

    await expectLater(
      dio.get<Object?>('/journal/'),
      throwsA(
        isA<DioException>().having((e) => e.error, 'error', isA<AuthFailure>()),
      ),
    );

    expect(refreshCalls(adapter), 0);
    expect(reauthRequired, isTrue);
  });
}
