// Parcours P2 dans l'app : « Qu'observez-vous ? », capture contrôlée, questions,
// résultat fusionné. Le dépôt, l'appareil photo et le modèle sont doublés ; les
// écrans, le routeur et le notifier sont ceux de l'application.

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/app/router.dart';
import 'package:agri_mada/core/ai/diagnosis_certainty.dart';
import 'package:agri_mada/core/ai/image_quality.dart';
import 'package:agri_mada/core/ai/tflite_service.dart';
import 'package:agri_mada/core/local_db/models/diagnostic_session_local.dart';
import 'package:agri_mada/core/local_db/models/observation_local.dart';
import 'package:agri_mada/core/providers/tflite_provider.dart';
import 'package:agri_mada/features/scan/data/repositories/session_local_repository.dart';
import 'package:agri_mada/features/scan/domain/entities/organe.dart';
import 'package:agri_mada/features/scan/presentation/providers/session_scan_provider.dart';
import 'package:agri_mada/features/scan/presentation/screens/capture_screen.dart';
import 'package:agri_mada/features/scan/presentation/screens/organ_picker_screen.dart';
import 'package:agri_mada/features/scan/presentation/screens/scan_questions_screen.dart';
import 'package:agri_mada/features/scan/presentation/screens/session_result_screen.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

class _MockTFLiteService extends Mock implements TFLiteService {}

/// Dépôt en mémoire : les écrans n'ont pas besoin d'une vraie base pour ce test.
class _FakeSessionRepository extends SessionLocalRepository {
  int sessions = 0;
  final List<ObservationLocal> observationsAjoutees = [];
  int? parcelleRattachee;

  @override
  Future<DiagnosticSessionLocal> ouvrirSession({
    int? parcelleLocalId,
    String? ecosysteme,
    String? stade,
    DateTime? createdAt,
  }) async {
    sessions++;
    return DiagnosticSessionLocal()
      ..id = sessions
      ..clientUuid = 'session-$sessions'
      ..parcelleLocalId = parcelleLocalId
      ..createdAt = createdAt ?? DateTime(2026, 9, 16);
  }

  @override
  Future<ObservationLocal> ajouterObservation({
    required int sessionId,
    required Organe organe,
    required String imagePath,
    List<ScoredLabel> topK = const [],
    Map<String, String> reponses = const {},
    ImageQualityReport? qualite,
    DateTime? createdAt,
  }) async {
    final observation = ObservationLocal()
      ..clientUuid = 'obs-${observationsAjoutees.length + 1}'
      ..sessionId = sessionId
      ..organeCode = organe.code
      ..imagePath = imagePath
      ..createdAt = createdAt ?? DateTime(2026, 9, 16);
    observationsAjoutees.add(observation);
    return observation;
  }

  @override
  Future<int> enregistrerReponses({
    required int sessionId,
    required Organe organe,
    required Map<String, String> reponses,
  }) async =>
      0;

  @override
  Future<DiagnosticSessionLocal?> enregistrerResultat({
    required int sessionId,
    required dynamic fusion,
    String? graviteDeclaree,
  }) async =>
      null;

  @override
  Future<DiagnosticSessionLocal?> rattacherParcelle({
    required int sessionId,
    required int parcelleLocalId,
  }) async {
    parcelleRattachee = parcelleLocalId;
    return null;
  }
}

const _nette = ImageQualityReport(
  nettete: 300,
  luminosite: 0.5,
  partBrulee: 0.01,
  probleme: null,
);

const _floue = ImageQualityReport(
  nettete: 30,
  luminosite: 0.5,
  partBrulee: 0.01,
  probleme: ImageQualityIssue.flou,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockTFLiteService tflite;
  late _FakeSessionRepository repository;

  setUpAll(() => registerFallbackValue(File('fallback.jpg')));

  setUp(() {
    repository = _FakeSessionRepository();
    tflite = _MockTFLiteService();
    when(() => tflite.isReady).thenReturn(true);
    when(() => tflite.analyzeImage(any())).thenAnswer(
      (_) async => const TFLiteInferenceResult(
        maladieDetectee: 'Brown spot',
        confiance: 0.64,
        classement: [
          ScoredLabel('Brown spot', 0.64),
          ScoredLabel('Leaf smut', 0.21),
          ScoredLabel('Bacterial leaf blight', 0.15),
        ],
        certitude: DiagnosisCertainty.possible,
      ),
    );
  });

  /// Le bouton est en bas d'une liste construite à la demande : il faut
  /// l'amener à l'écran, puis le centrer, sinon le tap tombe à côté.
  Future<void> validerLesQuestions(WidgetTester tester) async {
    final bouton = find.widgetWithText(ElevatedButton, 'Continuer');
    await tester.scrollUntilVisible(bouton, 300);
    await tester.ensureVisible(bouton);
    await tester.pumpAndSettle();
    await tester.tap(bouton);
    await tester.pumpAndSettle();
  }

  Future<void> pumpParcours(
    WidgetTester tester, {
    ImageQualityReport qualite = _nette,
    Locale locale = const Locale('fr'),
  }) async {
    final router = GoRouter(
      initialLocation: AppRoutes.scanOrgane,
      routes: [
        GoRoute(
          path: AppRoutes.scanOrgane,
          builder: (context, state) => const OrganPickerScreen(),
        ),
        GoRoute(
          path: AppRoutes.scanCapture,
          builder: (context, state) => const CaptureScreen(),
        ),
        GoRoute(
          path: AppRoutes.scanQuestions,
          builder: (context, state) => const ScanQuestionsScreen(),
        ),
        GoRoute(
          path: AppRoutes.scanSessionResult,
          builder: (context, state) => const SessionResultScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const Scaffold(body: Text('Accueil')),
        ),
        GoRoute(
          path: AppRoutes.journal,
          builder: (context, state) => const Scaffold(body: Text('Journal')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionRepositoryProvider.overrideWithValue(repository),
          tfliteServiceProvider.overrideWithValue(tflite),
          photoCheckerProvider.overrideWithValue((_) async => qualite),
          camerasProvider.overrideWith((ref) async => <CameraDescription>[]),
          fallbackPhotoProvider.overrideWithValue(() async => XFile('photo.jpg')),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: locale,
          supportedLocales: const [Locale('fr'), Locale('mg')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Qu\'observez-vous ? (P2.1)', () {
    testWidgets('propose les six organes et « Je ne sais pas »', (tester) async {
      await pumpParcours(tester);

      expect(find.textContaining('Seules les feuilles sont analysées'), findsOneWidget);
      expect(find.text('Feuilles · Ravina'), findsOneWidget);
      expect(find.text('Racines · Faka'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Je ne sais pas'), 200);

      expect(find.text('Plante entière ou parcelle · Zavamaniry manontolo na tanimbary'),
          findsOneWidget);
      expect(find.text('Je ne sais pas'), findsOneWidget);
      expect(find.textContaining('la parcelle, puis une feuille, puis le collet'),
          findsOneWidget);
    });

    testWidgets('choisir un organe ouvre la prise de vue', (tester) async {
      await pumpParcours(tester);

      await tester.tap(find.text('Feuilles · Ravina'));
      await tester.pumpAndSettle();

      expect(find.byType(CaptureScreen), findsOneWidget);
      expect(find.textContaining('Approchez-vous d\'une feuille'), findsOneWidget);
      expect(repository.sessions, 1);
    });
  });

  group('Prise de vue (P2.2)', () {
    testWidgets('une photo floue est refusée avec une consigne précise', (tester) async {
      await pumpParcours(tester, qualite: _floue);
      await tester.tap(find.text('Feuilles · Ravina'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Prendre la photo'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Photo floue'), findsOneWidget);
      expect(repository.observationsAjoutees, isEmpty);
    });

    testWidgets('une photo nette est comptée et ouvre les questions', (tester) async {
      await pumpParcours(tester);
      await tester.tap(find.text('Feuilles · Ravina'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Prendre la photo'));
      await tester.pumpAndSettle();

      expect(find.text('1 photo(s) sur 3'), findsOneWidget);
      expect(repository.observationsAjoutees, hasLength(1));

      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      expect(find.byType(ScanQuestionsScreen), findsOneWidget);
    });
  });

  testWidgets('les questions mènent au résultat fusionné (P2.4)', (tester) async {
    await pumpParcours(tester);
    await tester.tap(find.text('Feuilles · Ravina'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prendre la photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('À quoi ressemblent les taches sur les feuilles ?'), findsOneWidget);
    await tester.tap(find.text('Taches brunes ovales, éparpillées sur la feuille'));
    await tester.pumpAndSettle();

    await validerLesQuestions(tester);

    expect(find.byType(SessionResultScreen), findsOneWidget);
    expect(find.text('Helminthosporiose (tache brune)'), findsOneWidget);
    expect(find.text('Piste à confirmer'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Demander à un technicien'), 300);
    expect(find.text('Demander à un technicien'), findsOneWidget);
  });

  testWidgets('un organe sans modèle ne nomme aucune maladie', (tester) async {
    await pumpParcours(tester);
    await tester.tap(find.text('Racines · Faka'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prendre la photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    await validerLesQuestions(tester);

    expect(find.text('L\'application ne nomme aucune maladie'), findsOneWidget);
    expect(find.textContaining('montrez-les à un technicien'), findsOneWidget);
    expect(find.text('Demander à un technicien'), findsOneWidget);
  });

  testWidgets('« Je ne sais pas » commence par la parcelle entière (P2.1)', (tester) async {
    await pumpParcours(tester);

    await tester.scrollUntilVisible(find.text('Je ne sais pas'), 200);
    await tester.tap(find.text('Je ne sais pas'));
    await tester.pumpAndSettle();

    expect(find.byType(CaptureScreen), findsOneWidget);
    expect(find.textContaining('Reculez pour montrer la parcelle'), findsOneWidget);
  });
}
