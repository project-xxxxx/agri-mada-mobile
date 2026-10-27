import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _networkTypes = {
  ConnectivityResult.mobile,
  ConnectivityResult.wifi,
  ConnectivityResult.ethernet,
  ConnectivityResult.vpn,
};

bool _hasNetwork(List<ConnectivityResult> results) =>
    results.any(_networkTypes.contains);

/// Présence d'un réseau (Wi-Fi, données mobiles…) sur l'appareil.
///
/// Reste en chargement tant que l'état est inconnu (plugin absent, tests) :
/// l'interface n'affiche alors aucun badge plutôt qu'un badge faux (P1.10).
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  final List<ConnectivityResult> initial;
  try {
    initial = await connectivity.checkConnectivity();
  } catch (_) {
    return;
  }
  yield _hasNetwork(initial);
  yield* connectivity.onConnectivityChanged.map(_hasNetwork);
});
