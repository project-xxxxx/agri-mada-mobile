import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/core/ai/tflite_service.dart';

class ScanFailure {
  const ScanFailure(this.message);

  final String message;
}

class AnalyzeImageUseCase {
  const AnalyzeImageUseCase(this._tfliteService);

  final TFLiteService _tfliteService;

  Future<Either<Object, TFLiteInferenceResult>> call(File imageFile) async {
    try {
      final result = await _tfliteService.analyzeImage(imageFile);
      return Right(result);
    } on TFLiteNotInitializedException catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(ScanFailure('Image invalide'));
    }
  }
}

class MockTFLiteService extends Mock implements TFLiteService {}

class FakeFile extends Fake implements File {}

void main() {
  late MockTFLiteService mockTfliteService;
  late AnalyzeImageUseCase useCase;
  late File imageFile;

  const tResult = TFLiteInferenceResult(
    maladieDetectee: 'Brown spot',
    confiance: 0.93,
    niveauGravite: 'modere',
    recommandations: ['Ameliorer la fertilisation'],
  );

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    mockTfliteService = MockTFLiteService();
    useCase = AnalyzeImageUseCase(mockTfliteService);
    imageFile = File('test_image.jpg');
  });

  group('AnalyzeImageUseCase', () {
    test('retourne un DiagnosticResult quand l\'analyse reussit', () async {
      // Arrange
      when(() => mockTfliteService.analyzeImage(any())).thenAnswer(
        (_) async => tResult,
      );

      // Act
      final result = await useCase(imageFile);

      // Assert
      expect(result, const Right<Object, TFLiteInferenceResult>(tResult));
      verify(() => mockTfliteService.analyzeImage(imageFile)).called(1);
      verifyNoMoreInteractions(mockTfliteService);
    });

    test('retourne TFLiteNotInitializedException si moteur non initialise',
        () async {
      // Arrange
      when(() => mockTfliteService.analyzeImage(any())).thenThrow(
        const TFLiteNotInitializedException(),
      );

      // Act
      final result = await useCase(imageFile);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<TFLiteNotInitializedException>()),
        (_) => fail('Expected Left'),
      );
    });

    test('retourne un ScanFailure quand l\'image est invalide', () async {
      // Arrange
      when(() => mockTfliteService.analyzeImage(any())).thenThrow(
        Exception('Image invalide'),
      );

      // Act
      final result = await useCase(imageFile);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ScanFailure>());
          expect((failure as ScanFailure).message, 'Image invalide');
        },
        (_) => fail('Expected Left'),
      );
    });
  });
}
