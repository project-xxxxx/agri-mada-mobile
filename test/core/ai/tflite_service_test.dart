import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/ai/tflite_service.dart';

void main() {
  group('hasValidTfliteModelHeader', () {
    test('retourne true quand le buffer contient TFL3 a l offset 4', () {
      // Arrange
      final buffer = Uint8List.fromList([
        0x20,
        0x00,
        0x00,
        0x00,
        0x54,
        0x46,
        0x4C,
        0x33,
      ]);

      // Act
      final result = hasValidTfliteModelHeader(buffer);

      // Assert
      expect(result, isTrue);
    });

    test('retourne false quand le buffer est trop court', () {
      // Arrange
      final buffer = Uint8List.fromList([0x54, 0x46, 0x4C, 0x33]);

      // Act
      final result = hasValidTfliteModelHeader(buffer);

      // Assert
      expect(result, isFalse);
    });

    test('retourne false quand TFL3 nest pas present a l offset 4', () {
      // Arrange
      final buffer = Uint8List.fromList([
        0x54,
        0x46,
        0x4C,
        0x33,
        0x00,
        0x00,
        0x00,
        0x00,
      ]);

      // Act
      final result = hasValidTfliteModelHeader(buffer);

      // Assert
      expect(result, isFalse);
    });
  });
}
