import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/core/ai/diagnosis_certainty.dart';
import 'package:agri_mada/core/ai/tflite_service.dart';
import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/core/providers/tflite_provider.dart';
import 'package:agri_mada/features/scan/data/repositories/diagnostic_local_repository.dart';
import 'package:agri_mada/features/scan/domain/entities/declared_severity.dart';
import 'package:agri_mada/features/scan/domain/entities/diagnostic_result.dart';
import 'package:agri_mada/features/scan/presentation/providers/scan_provider.dart';

class MockTFLiteService extends Mock implements TFLiteService {}

class MockDiagnosticLocalRepository extends Mock
    implements DiagnosticLocalRepository {}

class FakeFile extends Fake implements File {}

class FakeDiagnosticResult extends Fake implements DiagnosticResult {}

void main() {
  late ProviderContainer container;
  late MockTFLiteService mockTfliteService;
  late MockDiagnosticLocalRepository mockDiagnosticRepository;

  const probableResult = TFLiteInferenceResult(
    maladieDetectee: 'Brown spot',
    confiance: 0.88,
    classement: [
      ScoredLabel('Brown spot', 0.88),
      ScoredLabel('Leaf smut', 0.08),
    ],
    certitude: DiagnosisCertainty.probable,
  );

  const uncertainResult = TFLiteInferenceResult(
    maladieDetectee: 'Leaf smut',
    confiance: 0.41,
    classement: [
      ScoredLabel('Leaf smut', 0.41),
      ScoredLabel('Brown spot', 0.35),
    ],
    certitude: DiagnosisCertainty.incertain,
  );

  setUpAll(() {
    registerFallbackValue(FakeFile());
    registerFallbackValue(FakeDiagnosticResult());
  });

  setUp(() {
    mockTfliteService = MockTFLiteService();
    mockDiagnosticRepository = MockDiagnosticLocalRepository();
    when(() => mockTfliteService.isReady).thenReturn(true);

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

  ScanNotifier notifier() => container.read(scanNotifierProvider.notifier);

  group('ScanNotifier', () {
    test('etat initial -> ScanState.initial()', () {
      expect(container.read(scanNotifierProvider), isA<ScanInitial>());
    });

    test('analyse en cours -> ScanState.loading()', () async {
      when(() => mockTfliteService.analyzeImage(any())).thenAnswer(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return probableResult;
        },
      );

      final states = <ScanState>[];
      container.listen(scanNotifierProvider, (_, next) => states.add(next));

      final future = notifier().analyzeImage(File('img.jpg'));
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(states.whereType<ScanLoading>(), isNotEmpty);
      await future;
    });

    test('succes -> resultat affiche avec sa parcelle, sans enregistrement',
        () async {
      when(() => mockTfliteService.analyzeImage(any()))
          .thenAnswer((_) async => probableResult);

      final result =
          await notifier().analyzeImage(File('img.jpg'), parcelleLocalId: 7);

      expect(result, isNotNull);
      expect(result!.maladieDetectee, 'Brown spot');
      expect(result.parcelleId, '7');
      expect(result.certitude, DiagnosisCertainty.probable);
      expect(result.niveauGravite, isNull);
      expect(container.read(scanNotifierProvider), isA<ScanSuccess>());
      verifyNever(() => mockDiagnosticRepository.save(any()));
    });

    test('TFLite non pret -> ScanState.engineUnavailable', () async {
      when(() => mockTfliteService.isReady).thenReturn(false);

      final result = await notifier().analyzeImage(File('img.jpg'));

      expect(result, isNull);
      expect(container.read(scanNotifierProvider), isA<ScanEngineUnavailable>());
      verifyNever(() => mockTfliteService.analyzeImage(any()));
    });

    test('saveCurrent enregistre avec la part de parcelle declaree', () async {
      when(() => mockTfliteService.analyzeImage(any()))
          .thenAnswer((_) async => probableResult);
      when(() => mockDiagnosticRepository.save(any()))
          .thenAnswer((_) async => const Right<Failure, Unit>(unit));
      await notifier().analyzeImage(File('img.jpg'), parcelleLocalId: 7);

      final outcome =
          await notifier().saveCurrent(severity: DeclaredSeverity.moinsDunTiers);

      expect(outcome, SaveOutcome.saved);
      final saved = verify(() => mockDiagnosticRepository.save(captureAny()))
          .captured
          .single as DiagnosticResult;
      expect(saved.niveauGravite, 'moins_tiers');
      expect(saved.parcelleId, '7');
    });

    test('saveCurrent refuse un resultat incertain', () async {
      when(() => mockTfliteService.analyzeImage(any()))
          .thenAnswer((_) async => uncertainResult);
      await notifier().analyzeImage(File('img.jpg'), parcelleLocalId: 7);

      final outcome = await notifier().saveCurrent();

      expect(outcome, SaveOutcome.notAllowed);
      verifyNever(() => mockDiagnosticRepository.save(any()));
    });

    test('saveCurrent signale un echec de sauvegarde', () async {
      when(() => mockTfliteService.analyzeImage(any()))
          .thenAnswer((_) async => probableResult);
      when(() => mockDiagnosticRepository.save(any())).thenAnswer(
        (_) async => const Left<Failure, Unit>(CacheFailure('disque plein')),
      );
      await notifier().analyzeImage(File('img.jpg'), parcelleLocalId: 7);

      final outcome = await notifier().saveCurrent();

      expect(outcome, SaveOutcome.failed);
    });
  });
}
