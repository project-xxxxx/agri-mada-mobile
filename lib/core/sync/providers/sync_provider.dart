import 'dart:async';

import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/failure.dart';
import '../../../core/local_db/models/diagnostic_local.dart';
import '../../../core/local_db/models/parcelle_local.dart';
import '../../../core/utils/logger.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart'
    show dioProvider;
import '../../../features/auth/presentation/providers/session_provider.dart'
    show sessionServiceProvider;
import '../../../features/journal/presentation/providers/journal_provider.dart'
    show parcelleRepositoryProvider;
import '../../../features/scan/presentation/providers/scan_provider.dart'
    show diagnosticRepositoryProvider;
import '../data/datasources/sync_remote_datasource.dart';

part 'sync_provider.g.dart';

/// Alias providers for sync layer readability
final parcelleLocalRepositoryProvider = parcelleRepositoryProvider;
final diagnosticLocalRepositoryProvider = diagnosticRepositoryProvider;

sealed class SyncState {
  const SyncState();

  const factory SyncState.idle() = SyncIdle;
  const factory SyncState.syncing() = SyncSyncing;
  const factory SyncState.success() = SyncSuccess;
  const factory SyncState.error(SyncErrorReason reason) = SyncError;
}

class SyncIdle extends SyncState {
  const SyncIdle();
}

class SyncSyncing extends SyncState {
  const SyncSyncing();
}

class SyncSuccess extends SyncState {
  const SyncSuccess();
}

class SyncError extends SyncState {
  const SyncError(this.reason);

  final SyncErrorReason reason;
}

/// Cause d'un échec de synchronisation, traduite par SyncStatusIndicator (P1.5).
enum SyncErrorReason {
  /// Le serveur a refusé la session : l'agriculteur doit se reconnecter (P1.8).
  reauthRequired,
  serverUnreachable,
  failed,
}

@riverpod
SyncRemoteDatasource syncRemoteDatasource(Ref ref) {
  return SyncRemoteDatasource(ref.watch(dioProvider));
}

/// Éléments d'une réponse de synchronisation, indexés par client_uuid.
Map<String, Map<String, dynamic>> _itemsByClientUuid(
  Map<String, dynamic> response,
  String key,
) {
  final raw = response[key];
  if (raw is! List) return const {};
  return {
    for (final item in raw.whereType<Map<dynamic, dynamic>>())
      if (item['client_uuid'] case final String clientUuid)
        clientUuid: Map<String, dynamic>.from(item),
  };
}

@Riverpod(keepAlive: true)
class SyncNotifier extends _$SyncNotifier {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  static const int _maxAttempts = 2;

  bool _isDnsLookupFailure(DioException exception) {
    final details =
        '${exception.message ?? ''} ${exception.error ?? ''}'.toLowerCase();
    return details.contains('failed host lookup') ||
        details.contains('name or service not known') ||
        details.contains('no address associated with hostname');
  }

  @override
  SyncState build() {
    _initConnectivityListener();
    _syncOnStartup();
    ref.onDispose(() => _connectivitySubscription?.cancel());
    return const SyncState.idle();
  }

  Future<void> _syncOnStartup() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        syncData();
      }
    } catch (_) {
    }
  }

  void _initConnectivityListener() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        syncData();
      }
    });
  }

  Future<bool> _isReauthRequired() async {
    try {
      return await ref.read(sessionServiceProvider).isReauthRequired();
    } catch (_) {
      return false;
    }
  }

  Future<void> syncData() async {
    if (state is SyncSyncing) return;
    if (await _isReauthRequired()) {
      state = const SyncState.error(SyncErrorReason.reauthRequired);
      return;
    }
    state = const SyncState.syncing();

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        await _syncParcellesAndDiagnostics();
        state = const SyncState.success();
        return;
      } on DioException catch (e, st) {
        final isUnauthorized =
            e.response?.statusCode == 401 || e.error is AuthFailure;
        if (isUnauthorized) {
          // Plus de déconnexion forcée : l'agriculteur continue hors ligne.
          AppLogger.error(
            'Synchronisation suspendue : reconnexion requise',
            error: e.error ?? e,
            stackTrace: st,
          );
          state = const SyncState.error(SyncErrorReason.reauthRequired);
          return;
        }

        AppLogger.error(
          'Tentative de synchronisation échouée',
          error: e,
          stackTrace: st,
        );

        if (attempt == _maxAttempts) {
          if (_isDnsLookupFailure(e)) {
            state = const SyncState.error(SyncErrorReason.serverUnreachable);
            return;
          }

          state = const SyncState.error(SyncErrorReason.failed);
          return;
        }
      } catch (e, st) {
        AppLogger.error(
          'Erreur inattendue de synchronisation',
          error: e,
          stackTrace: st,
        );

        if (attempt == _maxAttempts) {
          state = const SyncState.error(SyncErrorReason.failed);
          return;
        }
      }
    }
  }

  /// Envoie parcelles puis diagnostics. Chaque élément porte un client_uuid :
  /// un renvoi après une réponse perdue ne crée pas de doublon, et la réponse
  /// est associée par identifiant, jamais par position (tâche P1.9).
  Future<void> _syncParcellesAndDiagnostics() async {
    final parcelleRepo = ref.read(parcelleLocalRepositoryProvider);
    final diagnosticRepo = ref.read(diagnosticLocalRepositoryProvider);
    final remoteDataSource = ref.read(syncRemoteDatasourceProvider);

    final unsyncedParcelles = await parcelleRepo.getUnsyncedParcelles();
    if (unsyncedParcelles.isNotEmpty) {
      final localByUuid = <String, ParcelleLocal>{};
      final payload = <Map<String, dynamic>>[];
      for (final parcelle in unsyncedParcelles) {
        final clientUuid = await parcelleRepo.ensureClientUuid(parcelle);
        localByUuid[clientUuid] = parcelle;
        payload.add({
          'client_uuid': clientUuid,
          'nom_parcelle': parcelle.nomParcelle,
          'description': parcelle.description,
          'surface': parcelle.surface,
          'latitude': parcelle.latitude,
          'longitude': parcelle.longitude,
        });
      }

      final response = Map<String, dynamic>.from(
        await remoteDataSource.syncParcelles({'parcelles': payload}) as Map,
      );
      final synced = _itemsByClientUuid(response, 'parcelles');
      for (final MapEntry(key: clientUuid, value: local) in localByUuid.entries) {
        if (synced[clientUuid]?['id'] case final int serverId) {
          await parcelleRepo.markAsSynced(local.id, serverId);
        }
      }
    }

    final unsyncedDiagnostics = await diagnosticRepo.getUnsyncedDiagnostics();
    if (unsyncedDiagnostics.isEmpty) {
      return;
    }

    final localByUuid = <String, DiagnosticLocal>{};
    final payload = <Map<String, dynamic>>[];
    for (final diag in unsyncedDiagnostics) {
      final parcelle = await parcelleRepo.getParcelleById(diag.parcelleLocalId);
      // Parcelle pas encore connue du serveur : le diagnostic attend la prochaine fois.
      if (parcelle == null || parcelle.serverId == null) continue;

      final clientUuid = await diagnosticRepo.ensureClientUuid(diag);
      localByUuid[clientUuid] = diag;
      payload.add({
        'client_uuid': clientUuid,
        'parcelle_client_uuid': await parcelleRepo.ensureClientUuid(parcelle),
        'parcelle_id': parcelle.serverId,
        'maladie_detectee': diag.maladieDetectee,
        'confiance': diag.confiance,
        'certitude': diag.certitude,
        'niveau_gravite': diag.niveauGravite,
        'recommandations': diag.recommandations,
        'date_diagnostic': diag.dateDiagnostic.toUtc().toIso8601String(),
      });
    }

    if (payload.isEmpty) {
      return;
    }

    final response = Map<String, dynamic>.from(
      await remoteDataSource.syncDiagnostics({'diagnostics': payload}) as Map,
    );
    final synced = _itemsByClientUuid(response, 'diagnostics');
    for (final MapEntry(key: clientUuid, value: local) in localByUuid.entries) {
      if (synced[clientUuid]?['id'] case final int serverId) {
        await diagnosticRepo.markAsSynced(local.id, serverId);
      }
    }
  }
}
