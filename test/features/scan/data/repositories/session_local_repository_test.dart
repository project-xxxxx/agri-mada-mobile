import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/ai/diagnosis_certainty.dart';
import 'package:agri_mada/core/ai/diagnosis_fusion.dart';
import 'package:agri_mada/core/local_db/isar_service.dart';
import 'package:agri_mada/core/local_db/models/diagnostic_session_local.dart';
import 'package:agri_mada/core/local_db/models/observation_local.dart';
import 'package:agri_mada/features/scan/data/repositories/session_local_repository.dart';
import 'package:agri_mada/features/scan/domain/entities/organe.dart';

import '../../../../helpers/isar_test_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
  late SessionLocalRepository repository;

  setUpAll(() async {
    await initIsarCoreForTests();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return (await Directory.systemTemp.createTemp('agri_mada_sessions_')).path;
      }
      return null;
    });
  });

  setUp(() async {
    await IsarService.instance.init();
    repository = SessionLocalRepository();
  });

  tearDown(() async {
    final db = IsarService.instance.db;
    await db.writeTxn(() async {
      await db.diagnosticSessionLocals.clear();
      await db.observationLocals.clear();
    });
    await IsarService.instance.close();
  });

  test('une session peut être ouverte sans parcelle (P2.6)', () async {
    final session = await repository.ouvrirSession();

    expect(session.parcelleLocalId, isNull);
    expect(session.clientUuid, isNotEmpty);
    expect(session.statutValidation, 'non_valide');
  });

  test('une session regroupe plusieurs observations d\'organes différents', () async {
    final session = await repository.ouvrirSession(parcelleLocalId: 4);

    await repository.ajouterObservation(
      sessionId: session.id,
      organe: Organe.feuille,
      imagePath: 'feuille.jpg',
      topK: const [ScoredLabel('Brown spot', 0.6), ScoredLabel('Leaf smut', 0.4)],
      reponses: const {'feuille_taches': 'brunes_ovales'},
    );
    await repository.ajouterObservation(
      sessionId: session.id,
      organe: Organe.collet,
      imagePath: 'collet.jpg',
      reponses: const {'collet_aspect': 'ronge'},
    );

    final observations = await repository.observations(session.id);
    expect(observations, hasLength(2));

    final feuille = observations.firstWhere((o) => o.organeCode == Organe.feuille.code);
    expect(feuille.organe, Organe.feuille);
    expect(decoderClassement(feuille.topK).first.label, 'Brown spot');
    expect(decoderReponses(feuille.reponses)['feuille_taches'], 'brunes_ovales');

    final collet = observations.firstWhere((o) => o.organeCode == Organe.collet.code);
    expect(collet.topK, isNull, reason: 'organe sans modèle : aucune sortie de modèle');
  });

  group('enregistrerResultat', () {
    test('retient la fiche quand l\'app sait la nommer', () async {
      final session = await repository.ouvrirSession(parcelleLocalId: 1);
      final fusion = fuseObservations([
        const ObservationEvidence(
          organe: Organe.feuille,
          scores: [ScoredLabel('Brown spot', 0.8), ScoredLabel('Leaf smut', 0.2)],
        ),
      ]);

      final enregistree = await repository.enregistrerResultat(
        sessionId: session.id,
        fusion: fusion,
        graviteDeclaree: 'moins_tiers',
      );

      expect(enregistree!.resultatFicheId, 'Brown spot');
      expect(enregistree.certitude, fusion.certitude.name);
      expect(enregistree.graviteDeclaree, 'moins_tiers');
      expect(decoderClassement(enregistree.classement).first.label, 'Brown spot');
    });

    test('ne retient aucune fiche pour une session sans modèle', () async {
      final session = await repository.ouvrirSession();
      final fusion = fuseObservations([
        const ObservationEvidence(organe: Organe.racines, indices: {'Brown spot': 1.0}),
      ]);

      final enregistree = await repository.enregistrerResultat(
        sessionId: session.id,
        fusion: fusion,
      );

      expect(enregistree!.resultatFicheId, isNull);
      expect(enregistree.classement, isNotNull, reason: 'gardé pour le technicien');
    });
  });

  test('une session sans parcelle peut être rattachée ensuite (P2.6)', () async {
    final session = await repository.ouvrirSession();

    final rattachee = await repository.rattacherParcelle(
      sessionId: session.id,
      parcelleLocalId: 7,
    );

    expect(rattachee!.parcelleLocalId, 7);
    expect(rattachee.isSynced, isFalse);
  });

  test('supprimer une session supprime ses observations', () async {
    final session = await repository.ouvrirSession(parcelleLocalId: 2);
    await repository.ajouterObservation(
      sessionId: session.id,
      organe: Organe.feuille,
      imagePath: 'a.jpg',
    );

    await repository.supprimerSession(session.id);

    expect(await repository.session(session.id), isNull);
    expect(await repository.observations(session.id), isEmpty);
  });

  test('supprimer une parcelle emporte ses sessions, pas les autres', () async {
    final aSupprimer = await repository.ouvrirSession(parcelleLocalId: 3);
    await repository.ajouterObservation(
      sessionId: aSupprimer.id,
      organe: Organe.feuille,
      imagePath: 'a.jpg',
    );
    final autre = await repository.ouvrirSession(parcelleLocalId: 9);

    final supprimees = await repository.supprimerSessionsDeParcelle(3);

    expect(supprimees, 1);
    expect(await repository.session(aSupprimer.id), isNull);
    expect(await repository.observations(aSupprimer.id), isEmpty);
    expect(await repository.session(autre.id), isNotNull);
  });

  test('l\'historique va de la session la plus récente à la plus ancienne', () async {
    await repository.ouvrirSession(
      parcelleLocalId: 5,
      createdAt: DateTime(2026, 9, 1),
    );
    await repository.ouvrirSession(
      parcelleLocalId: 5,
      createdAt: DateTime(2026, 9, 15),
    );

    final historique = await repository.historique(parcelleLocalId: 5);

    expect(historique.first.createdAt, DateTime(2026, 9, 15));
    expect(historique.last.createdAt, DateTime(2026, 9, 1));
  });
}
