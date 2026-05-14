import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/core/local_db/models/diagnostic_local.dart';
import 'package:agri_mada/features/scan/data/repositories/diagnostic_local_repository.dart';
import 'package:agri_mada/features/scan/domain/entities/diagnostic_result.dart'
    as domain;
import 'package:agri_mada/features/scan/domain/repositories/scan_repository.dart';
import 'package:agri_mada/features/scan/domain/usecases/analyze_image_usecase.dart';
import 'package:agri_mada/features/scan/presentation/providers/scan_provider.dart';
import 'package:agri_mada/features/scan/presentation/screens/scan_result_screen.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

class _StubScanRepository implements ScanRepository {
  @override
  Future<fpdart.Either<Failure, domain.DiagnosticResult>> analyze(
    String imagePath,
  ) async {
    return const fpdart.Left(UnknownFailure('unused'));
  }

  @override
  Future<fpdart.Either<Failure, List<domain.DiagnosticResult>>> getAll() async {
    return const fpdart.Right(<domain.DiagnosticResult>[]);
  }

  @override
  Future<fpdart.Either<Failure, fpdart.Unit>> save(
    domain.DiagnosticResult result,
  ) async {
    return const fpdart.Right(fpdart.unit);
  }
}

class _MockDiagnosticLocalRepository extends Mock
    implements DiagnosticLocalRepository {}

class _TestScanNotifier extends ScanNotifier {
  _TestScanNotifier({
    required domain.DiagnosticResult result,
    required DiagnosticLocal? persistReturn,
    DiagnosticLocal? lastSavedDiagnostic,
  })  : _persistReturn = persistReturn,
        _lastSavedDiagnostic = lastSavedDiagnostic,
        super(
          AnalyzeImageUseCase(_StubScanRepository()),
          _StubScanRepository(),
          _MockDiagnosticLocalRepository(),
        ) {
    state = ScanState.success(result);
  }

  final DiagnosticLocal? _persistReturn;
  final DiagnosticLocal? _lastSavedDiagnostic;
  bool persistCalled = false;

  @override
  DiagnosticLocal? get lastSavedDiagnostic => _lastSavedDiagnostic;

  @override
  Future<DiagnosticLocal?> persistLastDiagnostic({String? imagePath}) async {
    persistCalled = true;
    return _persistReturn;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');

  DiagnosticLocal buildDiagnosticLocal(DateTime date) {
    return DiagnosticLocal()
      ..parcelleLocalId = 1
      ..maladieDetectee = 'Leaf smut'
      ..confiance = 0.88
      ..niveauGravite = 'severe'
      ..recommandations = 'Traiter les semences'
      ..dateDiagnostic = date;
  }

  final tResult = domain.DiagnosticResult(
    createdAt: DateTime(2026, 5, 13),
    maladieDetectee: 'Leaf smut',
    confiance: 0.88,
    niveauGravite: 'severe',
    recommandations: ['Traiter les semences'],
  );

  Future<void> pumpScreen(
    WidgetTester tester,
    _TestScanNotifier notifier,
  ) async {
    final router = GoRouter(
      initialLocation: '/scan-result',
      routes: [
        GoRoute(
          path: '/scan-result',
          builder: (context, state) => const ScanResultScreen(),
        ),
        GoRoute(
          path: '/journal',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Journal Screen')),
          ),
        ),
        GoRoute(
          path: '/scanning',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Scanning Screen')),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Home Screen')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scanNotifierProvider.overrideWith((ref) => notifier),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('fr'),
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

  group('ScanResultScreen', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(shareChannel, null);
    });

    testWidgets(
      'bouton Partager appelle Share.share avec le texte attendu',
      (tester) async {
        // Arrange
        MethodCall? shareCall;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(shareChannel, (call) async {
          shareCall = call;
          return null;
        });

        final notifier = _TestScanNotifier(
          result: tResult,
          persistReturn: buildDiagnosticLocal(DateTime(2026, 5, 13)),
          lastSavedDiagnostic: buildDiagnosticLocal(DateTime(2026, 5, 13)),
        );

        await pumpScreen(tester, notifier);

        // Act
        await tester.ensureVisible(find.byIcon(Icons.share_outlined));
        await tester.tap(find.byIcon(Icons.share_outlined));
        await tester.pumpAndSettle();

        // Assert
        expect(shareCall, isNotNull);
        expect(shareCall!.method, 'share');

        final arguments = shareCall!.arguments;
        final sharedText = arguments is Map<String, dynamic>
            ? (arguments['text'] as String? ?? '')
            : arguments.toString();

        expect(sharedText, contains('Diagnostic AgriMada'));
        expect(sharedText, contains('Culture'));
        expect(sharedText, contains('Maladie'));
        expect(sharedText, contains('88'));
        expect(sharedText, contains('13/05/2026'));
      },
    );

    testWidgets(
      'bouton Enregistrer appelle la sauvegarde puis navigue vers le journal',
      (tester) async {
        // Arrange
        final notifier = _TestScanNotifier(
          result: tResult,
          persistReturn: buildDiagnosticLocal(DateTime(2026, 5, 13)),
        );

        await pumpScreen(tester, notifier);

        // Act
        await tester.ensureVisible(find.text('Enregistrer'));
        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();

        // Assert
        expect(notifier.persistCalled, isTrue);
        expect(find.text('Journal Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'echec de sauvegarde affiche une snackbar erreur',
      (tester) async {
        // Arrange
        final notifier = _TestScanNotifier(
          result: tResult,
          persistReturn: null,
        );

        await pumpScreen(tester, notifier);

        // Act
        await tester.ensureVisible(find.text('Enregistrer'));
        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();

        // Assert
        expect(notifier.persistCalled, isTrue);
        expect(
          find.text('Impossible d\'enregistrer le diagnostic'),
          findsOneWidget,
        );
      },
    );
  });
}
