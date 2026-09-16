import 'dart:io';

import 'package:agri_mada/core/ai/tflite_service.dart';
import 'package:mocktail/mocktail.dart';

import 'test_data.dart';

class MockTFLiteService extends Mock implements TFLiteService {}

MockTFLiteService buildMockTfliteService({
  TFLiteInferenceResult? result,
  bool isReady = true,
}) {
  final mock = MockTFLiteService();

  when(() => mock.isReady).thenReturn(isReady);
  if (isReady) {
    when(() => mock.analyzeImage(any()))
        .thenAnswer((_) async => result ?? mockTfliteResult);
  }

  return mock;
}

void registerTfliteFallbacks() {
  registerFallbackValue(File('fallback.jpg'));
}
