import 'dart:io';

import 'package:agri_mada/core/ai/tflite_service.dart';
import 'package:agri_mada/features/scan/domain/entities/diagnostic_result.dart';
import 'package:mocktail/mocktail.dart';

import 'test_data.dart';

class MockTFLiteService extends Mock implements TFLiteService {}

MockTFLiteService buildMockTfliteService({
  DiagnosticResult? result,
  bool isReady = true,
}) {
  final mock = MockTFLiteService();

  when(() => mock.isReady).thenReturn(isReady);
  if (isReady) {
    when(() => mock.analyzeImage(any())).thenAnswer((_) async {
      final r = result ?? mockTfliteResult;
      return TFLiteInferenceResult(
        maladieDetectee: r.maladieDetectee,
        confiance: r.confiance,
        classement: r.classement,
        certitude: r.certitude,
      );
    });
  }

  return mock;
}

void registerTfliteFallbacks() {
  registerFallbackValue(File('fallback.jpg'));
}
