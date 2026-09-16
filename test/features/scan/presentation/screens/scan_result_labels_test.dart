// Tâche P1.1 : pour chaque classe du modèle, l'écran de résultat affiche le nom
// traduit et exactement les gestes du catalogue, sans produit ni dosage.

import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:go_router/go_router.dart';

import 'package:agri_mada/core/ai/diagnosis_certainty.dart';
import 'package:agri_mada/core/ai/disease_catalog.dart';
import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/features/scan/domain/entities/diagnostic_result.dart'
    as domain;
import 'package:agri_mada/features/scan/domain/repositories/scan_repository.dart';
import 'package:agri_mada/features/scan/domain/usecases/analyze_image_usecase.dart';
import 'package:agri_mada/features/scan/presentation/providers/scan_provider.dart';
import 'package:agri_mada/features/scan/presentation/screens/scan_result_screen.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

class _NoopScanRepository implements ScanRepository {
  @override
  Future<fpdart.Either<Failure, domain.DiagnosticResult>> analyze(String imagePath) async =>
      const fpdart.Left(UnknownFailure('unused'));

  @override
  Future<fpdart.Either<Failure, List<domain.DiagnosticResult>>> getAll() async =>
      const fpdart.Right(<domain.DiagnosticResult>[]);

  @override
  Future<fpdart.Either<Failure, fpdart.Unit>> save(domain.DiagnosticResult result) async =>
      const fpdart.Right(fpdart.unit);
}

class _SeededScanNotifier extends ScanNotifier {
  _SeededScanNotifier(_NoopScanRepository repository, domain.DiagnosticResult result)
      : super(AnalyzeImageUseCase(repository), repository) {
    state = ScanState.success(result);
  }
}

class _MgMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _MgMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mg';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('fr'));

  @override
  bool shouldReload(_MgMaterialLocalizationsDelegate old) => false;
}

class _MgCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _MgCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mg';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('fr'));

  @override
  bool shouldReload(_MgCupertinoLocalizationsDelegate old) => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final labels = [
    ...File('assets/model/labels.txt')
        .readAsLinesSync()
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty),
    'healthy',
  ];

  final productOrDose = RegExp(
    r'\d+(,\d+)?\s*(g|kg|l|ml|cl)\s*/|fongicide|cuivre|mancoz|tricyclazole|insecticide|pesticide|herbicide',
    caseSensitive: false,
  );

  Future<void> pumpResult(WidgetTester tester, domain.DiagnosticResult result, Locale locale) async {
    final router = GoRouter(
      initialLocation: '/scan-result',
      routes: [
        GoRoute(path: '/scan-result', builder: (context, state) => const ScanResultScreen()),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scanNotifierProvider.overrideWith(
            (ref) => _SeededScanNotifier(_NoopScanRepository(), result),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: locale,
          supportedLocales: const [Locale('fr'), Locale('mg')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            _MgMaterialLocalizationsDelegate(),
            _MgCupertinoLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final code in ['fr', 'mg']) {
    for (final label in labels) {
      testWidgets('$label ($code) : nom traduit et gestes du catalogue', (tester) async {
        final locale = Locale(code);
        final loc = lookupAppLocalizations(locale);
        final info = DiseaseCatalog.of(label)!;

        await pumpResult(
          tester,
          domain.DiagnosticResult(
            maladieDetectee: label,
            confiance: 0.92,
            createdAt: DateTime(2026, 9, 15),
            parcelleId: '1',
            certitude: DiagnosisCertainty.probable,
            classement: [ScoredLabel(label, 0.92)],
          ),
          locale,
        );

        expect(find.text(info.name(loc)), findsOneWidget);
        expect(info.advice, isNotEmpty);
        for (final advice in info.advice) {
          expect(find.text(advice(loc)), findsOneWidget, reason: advice(loc));
        }

        // Le rappel « pas de traitement chimique » peut nommer ce qu'il exclut.
        final shown = tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data ?? '')
            .where((text) => text != loc.scanAdviceNoChemical)
            .join('\n');
        expect(productOrDose.hasMatch(shown), isFalse, reason: shown);
      });
    }
  }
}
