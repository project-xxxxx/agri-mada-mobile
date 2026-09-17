// Providers Riverpod pour la session locale et le profil utilisateur
// Partagés par tous les écrans de l'application

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ai/model_version_service.dart';
import '../../../../core/local_db/session_service.dart';
import '../../../../core/providers/tflite_provider.dart';

class AppBootstrapSnapshot {
  const AppBootstrapSnapshot({
    required this.isLoggedIn,
    required this.isOnboardingDone,
    required this.profile,
    required this.isAiReady,
    this.modelVersion,
  });

  final bool isLoggedIn;
  final bool isOnboardingDone;
  final Map<String, String?> profile;
  final bool isAiReady;
  final ModelVersionInfo? modelVersion;
}

/// Fournit le service de session (singleton)
final sessionServiceProvider = Provider<SessionService>(
  (_) => SessionService.instance,
);

/// État de la session : null = non connecté, Map = profil chargé
final sessionProvider = FutureProvider<Map<String, String?>>((ref) async {
  final service = ref.read(sessionServiceProvider);
  bool isLoggedIn;
  try {
    isLoggedIn = await service.isLoggedIn();
  } catch (_) {
    return {};
  }
  if (!isLoggedIn) return {};
  try {
    return service.getProfile();
  } catch (_) {
    return {};
  }
});

/// True si l'utilisateur a une session locale valide
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  try {
    return SessionService.instance.isLoggedIn();
  } catch (_) {
    return false;
  }
});

final appBootstrapProvider = FutureProvider<AppBootstrapSnapshot>((ref) async {
  final service = ref.read(sessionServiceProvider);
  bool isLoggedIn;
  bool isOnboardingDone;
  Map<String, String?> profile;

  try {
    isLoggedIn = await service.isLoggedIn();
    isOnboardingDone = await service.isOnboardingDone();
    profile = isLoggedIn ? await service.getProfile() : <String, String?>{};
  } catch (_) {
    isLoggedIn = false;
    isOnboardingDone = false;
    profile = <String, String?>{};
  }

  ModelVersionInfo? modelVersion;
  try {
    modelVersion = await ModelVersionService.instance.load();
  } catch (_) {
    modelVersion = null;
  }

  final isAiReady = ref.read(isTFLiteReadyProvider);

  return AppBootstrapSnapshot(
    isLoggedIn: isLoggedIn,
    isOnboardingDone: isOnboardingDone,
    profile: profile,
    isAiReady: isAiReady,
    modelVersion: modelVersion,
  );
});
