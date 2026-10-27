import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../local_db/session_service.dart';
import '../utils/logger.dart';
import 'auth_interceptor.dart';

final apiBaseUrlProvider = Provider<String>((_) => ApiConstants.baseUrl);

/// Transport HTTP de remplacement, pour les tests de scénario ; null en
/// production, où Dio utilise son transport par défaut.
final httpClientAdapterProvider = Provider<HttpClientAdapter?>((_) => null);

final dioClientProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  final adapter = ref.watch(httpClientAdapterProvider);

  AppLogger.info('Dio baseUrl active: $baseUrl');

  final options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: ApiConstants.connectTimeout,
    receiveTimeout: ApiConstants.receiveTimeout,
  );

  final dio = Dio(options);
  final plainClient = Dio(options.copyWith());
  if (adapter != null) {
    dio.httpClientAdapter = adapter;
    plainClient.httpClientAdapter = adapter;
  }

  // Une réponse 401 ne vide plus la session (tâche P1.8) : le jeton est
  // renouvelé, ou la synchronisation attend une reconnexion.
  dio.interceptors.add(
    AuthInterceptor(
      sessionService: SessionService.instance,
      plainClient: plainClient,
    ),
  );

  return dio;
});
