// Tâche P1.7 : parcours de scan réel (écran de scan, choix de la parcelle,
// photo, résultat) répété trois fois avec « Reprendre la photo », puis
// « Enregistrer ». Un seul diagnostic doit être enregistré.
//
// Les écrans, le routeur et ScanNotifier sont ceux de l'app. Seuls l'appareil
// photo, le modèle et le stockage sont doublés ; l'écriture Isar d'un
// diagnostic est couverte par les tests du dépôt local.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:go_router/go_router.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'package:agri_mada/app/router.dart';
import 'package:agri_mada/core/ai/diagnosis_certainty.dart';
import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/core/local_db/models/parcelle_local.dart';
import 'package:agri_mada/core/providers/tflite_provider.dart';
import 'package:agri_mada/features/journal/data/repositories/parcelle_local_repository.dart';
import 'package:agri_mada/features/journal/presentation/providers/journal_provider.dart';
import 'package:agri_mada/features/scan/domain/entities/diagnostic_result.dart'
    as domain;
import 'package:agri_mada/features/scan/domain/repositories/scan_repository.dart';
import 'package:agri_mada/features/scan/presentation/providers/scan_provider.dart';
import 'package:agri_mada/features/scan/presentation/screens/scan_result_screen.dart';
import 'package:agri_mada/features/scan/presentation/screens/scanning_screen.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

const _plotName = 'Rizière du bas-fond';

class _CountingImagePicker extends ImagePickerPlatform {
  int picks = 0;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    picks++;
    return XFile('photo-$picks.jpg');
  }
}

class _RecordingScanRepository implements ScanRepository {
  int analyses = 0;
  final saved = <domain.DiagnosticResult>[];

  @override
  Future<fpdart.Either<Failure, domain.DiagnosticResult>> analyze(String imagePath) async {
    analyses++;
    return fpdart.Right(
      domain.DiagnosticResult(
        maladieDetectee: 'Brown spot',
        confiance: 0.9,
        imagePath: imagePath,
        createdAt: DateTime(2026, 9, 15),
        certitude: DiagnosisCertainty.probable,
        classement: const [ScoredLabel('Brown spot', 0.9)],
      ),
    );
  }

  @override
  Future<fpdart.Either<Failure, List<domain.DiagnosticResult>>> getAll() async =>
      fpdart.Right(saved);

  @override
  Future<fpdart.Either<Failure, fpdart.Unit>> save(domain.DiagnosticResult result) async {
    saved.add(result);
    return const fpdart.Right(fpdart.unit);
  }
}

class _SinglePlotRepository extends ParcelleLocalRepository {
  @override
  Future<List<ParcelleLocal>> getAllParcelles() async => [
        ParcelleLocal()
          ..id = 1
          ..nomParcelle = _plotName
          ..createdAt = DateTime(2026, 9, 1),
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ImagePickerPlatform previousPicker;

  setUp(() => previousPicker = ImagePickerPlatform.instance);
  tearDown(() => ImagePickerPlatform.instance = previousPicker);

  testWidgets('trois « Reprendre la photo » puis « Enregistrer » : un seul diagnostic',
      (tester) async {
    final fr = lookupAppLocalizations(const Locale('fr'));
    final picker = _CountingImagePicker();
    ImagePickerPlatform.instance = picker;
    final repository = _RecordingScanRepository();

    final router = GoRouter(
      initialLocation: AppRoutes.scanning,
      routes: [
        GoRoute(path: AppRoutes.scanning, builder: (context, state) => const ScanningScreen()),
        GoRoute(path: AppRoutes.scanResult, builder: (context, state) => const ScanResultScreen()),
        GoRoute(
          path: AppRoutes.journal,
          builder: (context, state) => const Scaffold(body: Text('Journal Screen')),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const Scaffold(body: Text('Home Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isTFLiteReadyProvider.overrideWithValue(true),
          scanRepositoryProvider.overrideWithValue(repository),
          parcelleRepositoryProvider.overrideWithValue(_SinglePlotRepository()),
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

    Future<void> photographPlot() async {
      await tester.pumpAndSettle();
      await tester.tap(find.text(_plotName));
      await tester.pumpAndSettle();
      expect(find.byType(ScanResultScreen), findsOneWidget);
    }

    Future<void> tapButton(String label) async {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    await photographPlot();
    for (var retake = 1; retake <= 3; retake++) {
      await tapButton(fr.scanRetakePhoto);
      expect(find.byType(ScanningScreen), findsOneWidget);
      await photographPlot();
    }

    expect(repository.saved, isEmpty, reason: 'rien ne doit être enregistré avant « Enregistrer »');

    await tapButton(fr.commonSave);

    expect(repository.analyses, 4);
    expect(picker.picks, 4);
    expect(repository.saved, hasLength(1));
    expect(repository.saved.single.parcelleId, '1');
    expect(find.text('Journal Screen'), findsOneWidget);
  });
}
