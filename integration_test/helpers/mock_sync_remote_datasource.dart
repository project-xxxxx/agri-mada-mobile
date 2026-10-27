import 'package:agri_mada/core/sync/data/datasources/sync_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

class MockSyncRemoteDatasource extends Mock implements SyncRemoteDatasource {}

MockSyncRemoteDatasource buildSuccessfulSyncRemoteDatasource() {
  final mock = MockSyncRemoteDatasource();

  when(() => mock.syncParcelles(any())).thenAnswer(
    (_) async => <String, dynamic>{
      'parcelles_creees': <Map<String, dynamic>>[],
    },
  );

  when(() => mock.syncDiagnostics(any())).thenAnswer(
    (_) async => <String, dynamic>{
      'diagnostics_crees': <Map<String, dynamic>>[
        <String, dynamic>{'id': 901},
      ],
    },
  );

  return mock;
}

MockSyncRemoteDatasource buildUnauthorizedSyncRemoteDatasource() {
  final mock = MockSyncRemoteDatasource();

  when(() => mock.syncParcelles(any())).thenThrow(
    DioException(
      requestOptions: RequestOptions(path: '/sync/parcelles'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/sync/parcelles'),
        statusCode: 401,
      ),
    ),
  );

  when(() => mock.syncDiagnostics(any())).thenThrow(
    DioException(
      requestOptions: RequestOptions(path: '/sync/diagnostics'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/sync/diagnostics'),
        statusCode: 401,
      ),
    ),
  );

  return mock;
}
