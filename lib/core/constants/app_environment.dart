abstract final class AppEnvironment {
  static const String _appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://agri-mada-mobile-production.up.railway.app/api',
  );

  static bool get isProduction => _appEnv == 'prod';

  static bool get isStaging => _appEnv == 'staging';

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty && _apiBaseUrlOverride != 'https://agri-mada-mobile-production.up.railway.app/api') {
      return _apiBaseUrlOverride;
    }

    if (isProduction) {
      return 'https://agri-mada-mobile-production.up.railway.app/api';
    }

    if (isStaging) {
      return 'https://staging-api.agrimada.mg/api';
    }

    // Par défaut, on utilise maintenant l'URL de production Railway si rien n'est spécifié.
    return 'https://agri-mada-mobile-production.up.railway.app/api';
  }
}
