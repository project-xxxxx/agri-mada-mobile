// Service de session locale sécurisée
// Stocke les jetons et le profil utilisateur dans flutter_secure_storage
// (données chiffrées sur l'appareil — non accessible sans déverrouillage)
// Permet à l'agriculteur de rester connecté sans internet.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      accountName: 'agrimada_secure_storage',
    ),
  );

  // Clés de stockage
  static const _keyToken = 'auth_token';
  static const _keyTokenType = 'auth_token_type';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyReauthRequired = 'auth_reauth_required';
  static const _keyUserId = 'user_id';
  static const _keyNom = 'user_nom';
  static const _keyPrenom = 'user_prenom';
  static const _keyTel = 'user_tel';
  static const _keyRegion = 'user_region';
  static const _keyLocale = 'app_locale';
  static const _keyOnboardingDone = 'onboarding_done';

  // --- Sauvegarde (après connexion internet réussie) ---

  /// Enregistre les jetons reçus du serveur et lève l'éventuelle demande de
  /// reconnexion. Sans jeton de rafraîchissement, l'ancien est supprimé.
  Future<void> saveSession({
    required String token,
    required String tokenType,
    String? refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyToken, value: token),
      _storage.write(key: _keyTokenType, value: tokenType),
      if (refreshToken != null)
        _storage.write(key: _keyRefreshToken, value: refreshToken)
      else
        _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyReauthRequired),
    ]);
  }

  Future<void> saveProfile({
    required int userId,
    required String nom,
    required String prenom,
    required String tel,
    required String region,
  }) async {
    await Future.wait([
      _storage.write(key: _keyUserId, value: userId.toString()),
      _storage.write(key: _keyNom, value: nom),
      _storage.write(key: _keyPrenom, value: prenom),
      _storage.write(key: _keyTel, value: tel),
      _storage.write(key: _keyRegion, value: region),
    ]);
  }

  // --- Lecture ---

  Future<String?> getToken() => _storage.read(key: _keyToken);
  Future<String?> getTokenType() => _storage.read(key: _keyTokenType);
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);
  Future<int?> getUserId() async {
    final v = await _storage.read(key: _keyUserId);
    return v != null ? int.tryParse(v) : null;
  }

  Future<String?> getNom() => _storage.read(key: _keyNom);
  Future<String?> getPrenom() => _storage.read(key: _keyPrenom);
  Future<String?> getTel() => _storage.read(key: _keyTel);
  Future<String?> getRegion() => _storage.read(key: _keyRegion);
  Future<String?> getLocaleCode() => _storage.read(key: _keyLocale);

  Future<void> saveLocaleCode(String localeCode) {
    return _storage.write(key: _keyLocale, value: localeCode);
  }

  Future<bool> isOnboardingDone() async {
    final value = await _storage.read(key: _keyOnboardingDone);
    return value == 'true';
  }

  // --- Accord pour le conseiller (ADR-012) ---

  /// Par compte : un même téléphone sert parfois à plusieurs agriculteurs.
  Future<String> _cleAccordConseiller() async =>
      'agent_consent_${await getUserId() ?? 'anonyme'}';

  Future<bool> isAgentConsentGiven() async =>
      await _storage.read(key: await _cleAccordConseiller()) == 'true';

  Future<void> setAgentConsent(bool accepte) async {
    final cle = await _cleAccordConseiller();
    if (accepte) {
      await _storage.write(key: cle, value: 'true');
    } else {
      await _storage.delete(key: cle);
    }
  }

  Future<void> setOnboardingDone(bool done) {
    return _storage.write(
      key: _keyOnboardingDone,
      value: done ? 'true' : 'false',
    );
  }

  /// Retourne true si l'utilisateur a déjà une session enregistrée
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // --- Reconnexion requise (tâche P1.8) ---

  /// Le serveur a refusé le jeton de rafraîchissement. L'agriculteur garde
  /// l'accès à ses données locales ; seule la synchronisation attend qu'il se
  /// reconnecte.
  Future<void> markReauthRequired() {
    return _storage.write(key: _keyReauthRequired, value: 'true');
  }

  Future<bool> isReauthRequired() async {
    final value = await _storage.read(key: _keyReauthRequired);
    return value == 'true';
  }

  /// Retourne le profil complet de l'utilisateur en mémoire
  Future<Map<String, String?>> getProfile() async {
    return {
      'nom': await getNom(),
      'prenom': await getPrenom(),
      'tel': await getTel(),
      'region': await getRegion(),
    };
  }

  // --- Déconnexion ---

  /// Supprime les jetons et le profil. La langue choisie et l'onboarding déjà
  /// vu sont des préférences de l'appareil : ils sont conservés (tâche P1.8).
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyToken),
      _storage.delete(key: _keyTokenType),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyReauthRequired),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyNom),
      _storage.delete(key: _keyPrenom),
      _storage.delete(key: _keyTel),
      _storage.delete(key: _keyRegion),
    ]);
  }
}
