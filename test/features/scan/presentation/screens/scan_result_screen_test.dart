import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:go_router/go_router.dart';

import 'package:agri_mada/core/ai/diagnosis_certainty.dart';
import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/features/scan/domain/entities/diagnostic_result.dart'
    as domain;
import 'package:agri_mada/features/scan/domain/repositories/scan_repository.dart';
import 'package:agri_mada/features/scan/domain/usecases/analyze_image_usecase.dart';
import 'package:agri_mada/features/scan/presentation/providers/scan_provider.dart';
import 'package:agri_mada/features/scan/presentation/screens/scan_result_screen.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

class _RecordingScanRepository implements ScanRepository {
  _RecordingScanRepository({this.failSave = false});

  final bool failSave;
  final saved = <domain.DiagnosticResult>[];

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
    saved.add(result);
    return failSave
        ? const fpdart.Left(CacheFailure('echec'))
        : const fpdart.Right(fpdart.unit);
  }
}

/// Notifier dont l'analyse est déjà terminée, sans moteur TFLite.
class _SeededScanNotifier extends ScanNotifier {
  _SeededScanNotifier(
    _RecordingScanRepository repository,
    domain.DiagnosticResult result,
  ) : super(AnalyzeImageUseCase(repository), repository) {
    state = ScanState.success(result);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');

  final probable = domain.DiagnosticResult(
    maladieDetectee: 'Brown spot',
    confiance: 0.88,
    createdAt: DateTime(2026, 5, 13),
    parcelleId: '1',
    certitude: DiagnosisCertainty.probable,
    classement: const [
      ScoredLabel('Brown spot', 0.88),
      ScoredLabel('Leaf smut', 0.08),
    ],
  );

  final uncertain = probable.copyWith(
    confiance: 0.41,
    certitude: DiagnosisCertainty.incertain,
  );

  Future<void> pumpScreen(
    WidgetTester tester,
    _RecordingScanRepository repository,
    domain.DiagnosticResult result,
  ) async {
    final router = GoRouter(
      initialLocation: '/scan-result',
      routes: [
        GoRoute(
          path: '/scan-result',
          builder: (context, state) => const ScanResultScreen(),
        ),
        for (final (path, label) in const [
          ('/journal', 'Journal Screen'),
          ('/scanning', 'Scanning Screen'),
          ('/home', 'Home Screen'),
        ])
          GoRoute(
            path: path,
            builder: (context, state) => Scaffold(body: Center(child: Text(label))),
          ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scanNotifierProvider.overrideWith(
            (ref) => _SeededScanNotifier(repository, result),
          ),
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

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  group('ScanResultScreen', () {
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(shareChannel, null);
    });

    testWidgets('affiche la maladie traduite et la certitude, sans produit ni badge « fiable »',
        (tester) async {
      await pumpScreen(tester, _RecordingScanRepository(), probable);

      expect(find.text('Helminthosporiose (tache brune)'), findsOneWidget);
      expect(find.text('Diagnostic probable'), findsOneWidget);
      expect(find.textContaining('fiable'), findsNothing);
      expect(find.textContaining('L/ha'), findsNothing);
      expect(find.textContaining('fongicide'), findsNothing);
    });

    testWidgets('un résultat incertain ne propose pas l\'enregistrement',
        (tester) async {
      await pumpScreen(tester, _RecordingScanRepository(), uncertain);

      expect(find.text('L\'application ne reconnaît pas cette photo'), findsOneWidget);
      expect(find.text('Enregistrer'), findsNothing);
      expect(find.text('Helminthosporiose (tache brune)'), findsNothing);
    });

    testWidgets('Enregistrer sauvegarde la part de parcelle choisie puis ouvre le journal',
        (tester) async {
      final repository = _RecordingScanRepository();
      await pumpScreen(tester, repository, probable);

      await tapText(tester, 'Moins d\'un tiers');
      await tapText(tester, 'Enregistrer');

      expect(repository.saved, hasLength(1));
      expect(repository.saved.single.niveauGravite, 'moins_tiers');
      expect(find.text('Journal Screen'), findsOneWidget);
    });

    testWidgets('un échec de sauvegarde affiche un message', (tester) async {
      await pumpScreen(tester, _RecordingScanRepository(failSave: true), probable);

      await tapText(tester, 'Enregistrer');

      expect(find.text('Impossible d\'enregistrer le diagnostic'), findsOneWidget);
    });

    testWidgets('« Ce résultat me semble faux » écarte le résultat sans enregistrer',
        (tester) async {
      final repository = _RecordingScanRepository();
      await pumpScreen(tester, repository, probable);

      await tapText(tester, 'Ce résultat me semble faux');

      expect(repository.saved, isEmpty);
      expect(find.text('Scanning Screen'), findsOneWidget);
    });

    testWidgets('résultat incertain : « Demander à un technicien » envoie le message et les pistes',
        (tester) async {
      MethodCall? shareCall;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(shareChannel, (call) async {
        shareCall = call;
        return null;
      });

      await pumpScreen(tester, _RecordingScanRepository(), uncertain);
      await tapText(tester, 'Demander à un technicien');

      expect(shareCall, isNotNull);
      final arguments = shareCall!.arguments;
      final sharedText = arguments is Map
          ? (arguments['text'] as String? ?? '')
          : arguments.toString();
      expect(sharedText, contains('identifier avec certitude'));
      expect(sharedText, contains('Helminthosporiose (tache brune)'));
      expect(sharedText, contains('13/05/2026'));
    });

    testWidgets('résultat possible : piste « modèle expérimental », technicien en premier',
        (tester) async {
      await pumpScreen(
        tester,
        _RecordingScanRepository(),
        probable.copyWith(confiance: 0.82, certitude: DiagnosisCertainty.possible),
      );

      expect(find.text('Piste à confirmer'), findsOneWidget);
      expect(find.textContaining('Modèle expérimental'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('Demander à un technicien'),
          matching: find.byWidgetPredicate((widget) => widget is ElevatedButton),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.text('Enregistrer'),
          matching: find.byWidgetPredicate((widget) => widget is OutlinedButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('résultat probable : pas de demande au technicien proposée',
        (tester) async {
      await pumpScreen(tester, _RecordingScanRepository(), probable);

      expect(find.text('Demander à un technicien'), findsNothing);
    });

    testWidgets('Partager envoie la maladie, la certitude et la date',
        (tester) async {
      MethodCall? shareCall;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(shareChannel, (call) async {
        shareCall = call;
        return null;
      });

      await pumpScreen(tester, _RecordingScanRepository(), probable);
      await tapText(tester, 'Partager le résultat');

      expect(shareCall, isNotNull);
      final arguments = shareCall!.arguments;
      final sharedText = arguments is Map
          ? (arguments['text'] as String? ?? '')
          : arguments.toString();
      expect(sharedText, contains('Helminthosporiose (tache brune)'));
      expect(sharedText, contains('Diagnostic probable'));
      expect(sharedText, contains('13/05/2026'));
    });
  });
}
