import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/core/ai/tflite_service.dart';
import 'package:agri_mada/features/scan/data/repositories/diagnostic_local_repository.dart';
import 'package:agri_mada/features/scan/domain/entities/diagnostic_result.dart'
    as domain;
import 'package:agri_mada/features/scan/presentation/providers/scan_provider.dart';

class MockTFLiteService extends Mock implements TFLiteService {}

class MockDiagnosticLocalRepository extends Mock
    implements DiagnosticLocalRepository {}

class FakeFile extends Fake implements File {}

void main() {
  late ProviderContainer container;
  late MockTFLiteService mockTfliteService;
  late MockDiagnosticLocalRepository mockDiagnosticRepository;

  const tInferenceResult = TFLiteInferenceResult(
    maladieDetectee: 'Leaf smut',
    confiance: 0.88,
    niveauGravite: 'severe',
    recommandations: ['Traiter les semences'],
  );

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    mockTfliteService = MockTFLiteService();
    mockDiagnosticRepository = MockDiagnosticLocalRepository();

    container = ProviderContainer(
      overrides: [
        tfliteServiceProvider.overrideWithValue(mockTfliteService),
        diagnosticRepositoryProvider
            .overrideWithValue(mockDiagnosticRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ScanNotifier', () {
    test('etat initial -> ScanState.initial()', () {
      expect(container.read(scanNotifierProvider), const ScanState.initial());
    });

    test('analyse en cours -> ScanState.loading()', () async {
      when(() => mockTfliteService.isReady).thenReturn(true);
      when(() => mockTfliteService.analyzeImage(any())).thenAnswer(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return tInferenceResult;
        },
      );

      final states = <ScanState>[];
      container.listen(scanNotifierProvider, (_, next) => states.add(next));

      final future = container
          .read(scanNotifierProvider.notifier)
          .analyzeImage(File('img.jpg'));

      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(states, contains(const ScanState.loading()));
      await future;
    });

    test('succes -> ScanState.success(result)', () async {
      when(() => mockTfliteService.isReady).thenReturn(true);
      when(() => mockTfliteService.analyzeImage(any())).thenAnswer(
        (_) async => tInferenceResult,
      );

      final result = await container
          .read(scanNotifierProvider.notifier)
          .analyzeImage(File('img.jpg'));

      expect(result, isA<domain.DiagnosticResult>());
      expect(result?.maladieDetectee, tInferenceResult.maladieDetectee);
      expect(result?.confiance, tInferenceResult.confiance);
      expect(result?.niveauGravite, tInferenceResult.niveauGravite);
      expect(result?.recommandations, tInferenceResult.recommandations);
      expect(result?.createdAt, isNotNull);
      final state = container.read(scanNotifierProvider);
      expect(state, isA<ScanSuccess>());
      final successState = state as ScanSuccess;
      expect(
        successState.result.maladieDetectee,
        tInferenceResult.maladieDetectee,
      );
    });

    test(
        'TFLite non pret -> ScanState.engineUnavailable("Moteur IA non disponible")',
        () async {
      when(() => mockTfliteService.isReady).thenReturn(false);

      final result = await container
          .read(scanNotifierProvider.notifier)
          .analyzeImage(File('img.jpg'));

      expect(result, isNull);
      expect(
        container.read(scanNotifierProvider),
        const ScanState.engineUnavailable('Moteur IA non disponible'),
      );
      verifyNever(() => mockTfliteService.analyzeImage(any()));
    });
  });
}
