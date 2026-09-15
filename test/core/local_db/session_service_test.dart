import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/local_db/session_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final storage = <String, String>{};

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      final args = Map<String, dynamic>.from(call.arguments as Map);
      switch (call.method) {
        case 'write':
          storage[args['key'] as String] =
              args['value'] as String;
          return null;
        case 'read':
          return storage[args['key'] as String];
        case 'delete':
          storage.remove(args['key'] as String);
          return null;
        case 'deleteAll':
          storage.clear();
          return null;
        default:
          return null;
      }
    });
  });

  setUp(() {
    storage.clear();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('SessionService', () {
    test('saveSession() ecrit token et tokenType', () async {
      // Act
      await SessionService.instance.saveSession(
        token: 'jwt-token',
        tokenType: 'Bearer',
      );

      // Assert
      expect(storage['auth_token'], 'jwt-token');
      expect(storage['auth_token_type'], 'Bearer');
    });

    test('getToken() apres save retourne le bon token', () async {
      // Arrange
      await SessionService.instance.saveSession(
        token: 'jwt-token',
        tokenType: 'Bearer',
      );

      // Act
      final token = await SessionService.instance.getToken();

      // Assert
      expect(token, 'jwt-token');
    });

    test('isLoggedIn() sans session retourne false', () async {
      final isLoggedIn = await SessionService.instance.isLoggedIn();

      expect(isLoggedIn, isFalse);
    });

    test('isLoggedIn() avec session retourne true', () async {
      await SessionService.instance.saveSession(
        token: 'jwt-token',
        tokenType: 'Bearer',
      );

      final isLoggedIn = await SessionService.instance.isLoggedIn();

      expect(isLoggedIn, isTrue);
    });

    test('saveSession() conserve le jeton de rafraîchissement', () async {
      await SessionService.instance.saveSession(
        token: 'jwt-token',
        tokenType: 'bearer',
        refreshToken: 'refresh-1',
      );

      expect(await SessionService.instance.getRefreshToken(), 'refresh-1');
    });

    test('une nouvelle connexion lève la demande de reconnexion', () async {
      await SessionService.instance.markReauthRequired();
      expect(await SessionService.instance.isReauthRequired(), isTrue);

      await SessionService.instance.saveSession(
        token: 'jwt-token',
        tokenType: 'bearer',
        refreshToken: 'refresh-2',
      );

      expect(await SessionService.instance.isReauthRequired(), isFalse);
    });

    test('clearSession() supprime jetons et profil, garde langue et onboarding',
        () async {
      // Arrange
      await SessionService.instance.saveLocaleCode('mg');
      await SessionService.instance.setOnboardingDone(true);
      await SessionService.instance.saveSession(
        token: 'jwt-token',
        tokenType: 'Bearer',
        refreshToken: 'refresh-1',
      );
      await SessionService.instance.markReauthRequired();
      await SessionService.instance.saveProfile(
        userId: 1,
        nom: 'Rakoto',
        prenom: 'Jean',
        tel: '0341234567',
        region: 'Analamanga',
      );

      // Act
      await SessionService.instance.clearSession();

      // Assert
      expect(storage, {'app_locale': 'mg', 'onboarding_done': 'true'});
      expect(await SessionService.instance.isLoggedIn(), isFalse);
    });
  });
}
