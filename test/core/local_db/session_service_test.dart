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
      final args = call.arguments as Map<String, dynamic>;
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

    test('clearSession() supprime toutes les cles', () async {
      // Arrange
      await SessionService.instance.saveSession(
        token: 'jwt-token',
        tokenType: 'Bearer',
      );
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
      expect(storage, isEmpty);
    });
  });
}
