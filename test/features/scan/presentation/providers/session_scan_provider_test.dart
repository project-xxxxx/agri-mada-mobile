import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agri_mada/core/ai/diagnosis_certainty.dart';
import 'package:agri_mada/core/ai/image_quality.dart';
import 'package:agri_mada/core/ai/tflite_service.dart';
import 'package:agri_mada/core/local_db/isar_service.dart';
import 'package:agri_mada/core/local_db/models/diagnostic_session_local.dart';
import 'package:agri_mada/core/local_db/models/observation_local.dart';
import 'package:agri_mada/core/providers/tflite_provider.dart';
import 'package:agri_mada/features/scan/data/repositories/session_local_repository.dart';
import 'package:agri_mada/features/scan/domain/entities/organe.dart';
import 'package:agri_mada/features/scan/presentation/providers/session_scan_provider.dart';

import '../../../../helpers/isar_test_core.dart';

class _MockTFLiteService extends Mock implements TFLiteService {}

const _photoNette = ImageQualityReport(
  nettete: 320,
  luminosite: 0.45,
  partBrulee: 0.01,
  probleme: null,
);

const _photoFloue = ImageQualityReport(
  nettete: 40,
  luminosite: 0.45,
  partBrulee: 0.01,
  probleme: ImageQualityIssue.flou,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
  late _MockTFLiteService tflite;
  late SessionLocalRepository repository;

  setUpAll(() async {
    await initIsarCoreForTests();
    registerFallbackValue(File('fallback.jpg'));
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return (await Directory.systemTemp.createTemp('agri_mada_flux_')).path;
      }
      return null;
    });
  });

  setUp(() async {
    await IsarService.instance.init();
    repository = SessionLocalRepository();
    tflite = _MockTFLiteService();
    when(() => tflite.isReady).thenReturn(true);
    when(() => tflite.analyzeImage(any())).thenAnswer(
      (_) async => const TFLiteInferenceResult(
        maladieDetectee: 'Brown spot',
        confiance: 0.62,
        classement: [ScoredLabel('Brown spot', 0.62), ScoredLabel('Leaf smut', 0.38)],
        certitude: DiagnosisCertainty.possible,
      ),
    );
  });

  tearDown(() async {
    final db = IsarService.instance.db;
    await db.writeTxn(() async {
      await db.diagnosticSessionLocals.clear();
      await db.observationLocals.clear();
    });
    await IsarService.instance.close();
  });

  ProviderContainer conteneur({ImageQualityReport? qualite = _photoNette}) {
    final container = ProviderContainer(overrides: [
      tfliteServiceProvider.overrideWithValue(tflite),
      photoCheckerProvider.overrideWithValue((_) async => qualite),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  test('le scan démarre sans parcelle (P2.6)', () async {
    final container = conteneur();
    final notifier = container.read(scanSessionProvider.notifier);

    await notifier.demarrer(organe: Organe.feuille);
    final etat = container.read(scanSessionProvider);

    expect(etat.etape, EtapeScan.capture);
    expect(etat.organe, Organe.feuille);
    expect(etat.sessionId, isNotNull);
    expect((await repository.session(etat.sessionId!))!.parcelleLocalId, isNull);
  });

  test('une photo floue est refusée et rien n\'est enregistré (P2.2)', () async {
    final container = conteneur(qualite: _photoFloue);
    final notifier = container.read(scanSessionProvider.notifier);
    await notifier.demarrer(organe: Organe.feuille);

    final acceptee = await notifier.ajouterPhoto(File('floue.jpg'));
    final etat = container.read(scanSessionProvider);

    expect(acceptee, isFalse);
    expect(etat.dernierRefus, ImageQualityIssue.flou);
    expect(etat.photos, isEmpty);
    expect(await repository.observations(etat.sessionId!), isEmpty);
  });

  test('une photo nette est analysée et enregistrée comme observation', () async {
    final container = conteneur();
    final notifier = container.read(scanSessionProvider.notifier);
    await notifier.demarrer(organe: Organe.feuille, parcelleLocalId: 3);

    final acceptee = await notifier.ajouterPhoto(File('feuille.jpg'));
    final etat = container.read(scanSessionProvider);

    expect(acceptee, isTrue);
    expect(etat.photos.single.scores.first.label, 'Brown spot');
    final observations = await repository.observations(etat.sessionId!);
    expect(observations, hasLength(1));
    expect(decoderClassement(observations.single.topK).first.label, 'Brown spot');
    expect(observations.single.qualiteNettete, _photoNette.nettete);
  });

  test('une session accepte au plus trois photos par organe', () async {
    final container = conteneur();
    final notifier = container.read(scanSessionProvider.notifier);
    await notifier.demarrer(organe: Organe.feuille);

    for (var i = 0; i < photosMaxParOrgane; i++) {
      expect(await notifier.ajouterPhoto(File('photo$i.jpg')), isTrue);
    }

    expect(container.read(scanSessionProvider).peutAjouterPhoto, isFalse);
    expect(await notifier.ajouterPhoto(File('photo4.jpg')), isFalse);
    expect(container.read(scanSessionProvider).photos, hasLength(photosMaxParOrgane));
  });

  test('trois photos dans une session ne donnent qu\'un seul résultat (P1.7)', () async {
    final container = conteneur();
    final notifier = container.read(scanSessionProvider.notifier);
    await notifier.demarrer(organe: Organe.feuille, parcelleLocalId: 2);

    for (var i = 0; i < 3; i++) {
      await notifier.ajouterPhoto(File('photo$i.jpg'));
    }
    notifier.passerAuxQuestions();
    await notifier.validerQuestions();

    final db = IsarService.instance.db;
    expect(await db.diagnosticSessionLocals.count(), 1);
    expect(await db.observationLocals.count(), 3);
    final resultats = await repository.resultats(parcelleLocalId: 2);
    expect(resultats, hasLength(1), reason: 'un seul résultat dans le journal');
    expect(resultats.single.nbPhotos, 3);
  });

  test('les réponses au questionnaire pèsent sur le résultat et sont enregistrées', () async {
    final container = conteneur();
    final notifier = container.read(scanSessionProvider.notifier);
    await notifier.demarrer(organe: Organe.feuille);
    await notifier.ajouterPhoto(File('feuille.jpg'));

    notifier.passerAuxQuestions();
    notifier.repondre('feuille_taches', 'bandes_bord');
    notifier.repondre('feuille_exsudat', 'oui');
    await notifier.validerQuestions(graviteDeclaree: 'moins_tiers');

    final etat = container.read(scanSessionProvider);
    expect(etat.etape, EtapeScan.resultat);
    expect(etat.fusion!.nommable, isTrue);
    expect(etat.fusion!.classement.first.label, 'Bacterial leaf blight',
        reason: 'les réponses désignent le flétrissement bactérien');

    final session = await repository.session(etat.sessionId!);
    expect(session!.resultatFicheId, 'Bacterial leaf blight');
    expect(session.graviteDeclaree, 'moins_tiers');

    final observation = (await repository.observations(etat.sessionId!)).single;
    expect(decoderReponses(observation.reponses)['feuille_exsudat'], 'oui');
  });

  test('« Je ne sais pas » enchaîne les trois organes de la séquence guidée (P2.1)', () async {
    final container = conteneur();
    final notifier = container.read(scanSessionProvider.notifier);

    await notifier.demarrer(guidee: true);
    expect(container.read(scanSessionProvider).organe, Organe.planteEntiere);

    for (final attendu in [Organe.feuille, Organe.collet]) {
      await notifier.ajouterPhoto(File('${attendu.code}.jpg'));
      notifier.passerAuxQuestions();
      await notifier.validerQuestions();
      expect(container.read(scanSessionProvider).organe, attendu);
      expect(container.read(scanSessionProvider).etape, EtapeScan.capture);
    }

    await notifier.ajouterPhoto(File('collet.jpg'));
    notifier.passerAuxQuestions();
    await notifier.validerQuestions();

    final etat = container.read(scanSessionProvider);
    expect(etat.etape, EtapeScan.resultat);
    expect(etat.photos.map((p) => p.organe).toSet(), guidedOrganSequence.toSet());
  });

  test('un organe sans modèle ne nomme aucune maladie', () async {
    final container = conteneur();
    final notifier = container.read(scanSessionProvider.notifier);
    await notifier.demarrer(organe: Organe.racines);

    await notifier.ajouterPhoto(File('racines.jpg'));
    notifier.passerAuxQuestions();
    notifier.repondre('racines_aspect', 'rouillees');
    await notifier.validerQuestions();

    final etat = container.read(scanSessionProvider);
    expect(etat.fusion!.nommable, isFalse);
    expect(etat.photos.single.scores, isEmpty, reason: 'le modèle ne traite que la feuille');
    expect((await repository.session(etat.sessionId!))!.resultatFicheId, isNull);
  });

  test('une session sans parcelle peut être rattachée après coup (P2.6)', () async {
    final container = conteneur();
    final notifier = container.read(scanSessionProvider.notifier);
    await notifier.demarrer(organe: Organe.feuille);

    await notifier.rattacherParcelle(11);

    final etat = container.read(scanSessionProvider);
    expect((await repository.session(etat.sessionId!))!.parcelleLocalId, 11);
  });
}
