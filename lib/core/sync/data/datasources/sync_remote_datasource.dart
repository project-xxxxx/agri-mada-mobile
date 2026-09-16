import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'sync_remote_datasource.g.dart';

@RestApi()
abstract class SyncRemoteDatasource {
  // Le header Authorization est injecté automatiquement par l'intercepteur Dio.
  factory SyncRemoteDatasource(Dio dio, {String baseUrl}) =
      _SyncRemoteDatasource;

  @POST('/sync/parcelles')
  Future<dynamic> syncParcelles(@Body() Map<String, dynamic> body);

  @POST('/sync/diagnostics')
  Future<dynamic> syncDiagnostics(@Body() Map<String, dynamic> body);

  /// Sessions de scan multi-photos et leurs observations (tâche P2.3).
  @POST('/sync/sessions')
  Future<dynamic> syncSessions(@Body() Map<String, dynamic> body);
}
