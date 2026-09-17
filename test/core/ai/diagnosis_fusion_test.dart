import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/ai/diagnosis_certainty.dart';
import 'package:agri_mada/core/ai/diagnosis_fusion.dart';
import 'package:agri_mada/features/scan/domain/entities/organe.dart';

ObservationEvidence _feuille(List<ScoredLabel> scores, {Map<String, double> indices = const {}}) =>
    ObservationEvidence(organe: Organe.feuille, scores: scores, indices: indices);

double _probabilite(FusedDiagnosis fusion, String label) =>
    fusion.classement.firstWhere((candidat) => candidat.label == label).score;

void main() {
  group('fuseObservations', () {
    test('sans observation, rien n\'est nommé', () {
      final fusion = fuseObservations(const []);
      expect(fusion.classement, isEmpty);
      expect(fusion.nommable, isFalse);
      expect(fusion.certitude, DiagnosisCertainty.incertain);
    });

    test('deux photos qui disent la même chose renforcent la même piste', () {
      final une = fuseObservations([
        _feuille(const [ScoredLabel('Brown spot', 0.6), ScoredLabel('Leaf smut', 0.4)]),
      ]);
      final deux = fuseObservations([
        _feuille(const [ScoredLabel('Brown spot', 0.6), ScoredLabel('Leaf smut', 0.4)]),
        _feuille(const [ScoredLabel('Brown spot', 0.6), ScoredLabel('Leaf smut', 0.4)]),
      ]);

      expect(deux.classement.first.label, 'Brown spot');
      expect(_probabilite(deux, 'Brown spot'), greaterThan(_probabilite(une, 'Brown spot')));
    });

    test('deux photos qui se contredisent ne donnent pas de résultat tranché', () {
      final fusion = fuseObservations([
        _feuille(const [ScoredLabel('Brown spot', 0.7), ScoredLabel('Leaf smut', 0.3)]),
        _feuille(const [ScoredLabel('Leaf smut', 0.7), ScoredLabel('Brown spot', 0.3)]),
      ]);

      expect(_probabilite(fusion, 'Brown spot'), closeTo(_probabilite(fusion, 'Leaf smut'), 0.01));
      expect(fusion.certitude, isNot(DiagnosisCertainty.probable));
    });

    test('les réponses au questionnaire peuvent changer le classement', () {
      const scores = [
        ScoredLabel('Brown spot', 0.45),
        ScoredLabel('Bacterial leaf blight', 0.4),
        ScoredLabel('Leaf smut', 0.15),
      ];

      final sansReponses = fuseObservations([_feuille(scores)]);
      final avecReponses = fuseObservations([
        _feuille(scores, indices: const {'Bacterial leaf blight': 0.9, 'Brown spot': -0.5}),
      ]);

      expect(sansReponses.classement.first.label, 'Brown spot');
      expect(avecReponses.classement.first.label, 'Bacterial leaf blight');
    });

    test('le contexte de parcelle pèse sur le classement', () {
      const scores = [ScoredLabel('Brown spot', 0.5), ScoredLabel('Leaf smut', 0.5)];

      final fusion = fuseObservations(
        [_feuille(scores)],
        contexte: const {'Leaf smut': 0.6},
      );

      expect(fusion.classement.first.label, 'Leaf smut');
    });

    test('une session sans modèle ne nomme rien et n\'atteint jamais « probable »', () {
      final fusion = fuseObservations([
        const ObservationEvidence(
          organe: Organe.racines,
          indices: {'Brown spot': 5.0},
        ),
      ]);

      expect(fusion.nommable, isFalse);
      expect(fusion.certitude, isNot(DiagnosisCertainty.probable));
    });

    group('garde-fous ADR-006 rétablis pour les sessions (ADR-014)', () {
      test('pas_riz en tête : rien de nommé, mais la photo compte comme analysée', () {
        final fusion = fuseObservations([
          _feuille(const [ScoredLabel('pas_riz', 0.9), ScoredLabel('blb', 0.1)]),
        ]);

        expect(fusion.nommable, isFalse);
        expect(fusion.analyseParModele, isTrue);
        expect(fusion.classement, isEmpty);
      });

      test('pas_riz en tête : les réponses seules ne suffisent pas à nommer', () {
        final fusion = fuseObservations([
          _feuille(const [ScoredLabel('pas_riz', 0.9), ScoredLabel('blb', 0.1)], indices: const {'blb': 5.0}),
        ]);

        expect(fusion.nommable, isFalse);
        expect(fusion.certitude, DiagnosisCertainty.incertain,
            reason: 'enregistrée telle quelle et lue par l\'agent backend');
        expect(fusion.classement.map((c) => c.label), isNot(contains('pas_riz')));
      });

      test('pas_riz derrière une maladie n\'est jamais un candidat', () {
        final fusion = fuseObservations([
          _feuille(const [ScoredLabel('blb', 0.7), ScoredLabel('pas_riz', 0.2), ScoredLabel('bls', 0.1)]),
        ]);

        expect(fusion.classement.map((c) => c.label), isNot(contains('pas_riz')));
        expect(fusion.classement.first.label, 'blb');
      });

      test('moins de 10 % de végétation : rien de nommé', () {
        final fusion = fuseObservations([
          const ObservationEvidence(
            organe: Organe.feuille,
            scores: [ScoredLabel('blb', 0.95), ScoredLabel('bls', 0.05)],
            vegetationRatio: CertaintyThresholds.minVegetationRatio - 0.01,
          ),
        ]);

        expect(fusion.nommable, isFalse);
        expect(fusion.analyseParModele, isTrue);
      });

      test('assez de végétation : le contrôle ne bloque rien', () {
        final fusion = fuseObservations([
          const ObservationEvidence(
            organe: Organe.feuille,
            scores: [ScoredLabel('blb', 0.95), ScoredLabel('bls', 0.05)],
            vegetationRatio: 0.5,
          ),
        ]);

        expect(fusion.nommable, isTrue);
      });

      test('un résultat incertain ne nomme rien', () {
        final fusion = fuseObservations([
          _feuille(const [
            ScoredLabel('blb', 0.34),
            ScoredLabel('bls', 0.33),
            ScoredLabel('helminthosporiose', 0.33),
          ]),
        ]);

        expect(fusion.certitude, DiagnosisCertainty.incertain);
        expect(fusion.nommable, isFalse);
        expect(fusion.analyseParModele, isTrue);
      });
    });

    test('le classement est limité aux trois premiers candidats', () {
      final fusion = fuseObservations([
        _feuille(const [
          ScoredLabel('Brown spot', 0.4),
          ScoredLabel('Leaf smut', 0.3),
          ScoredLabel('Bacterial leaf blight', 0.2),
        ], indices: const {'healthy': 0.1}),
      ]);

      expect(fusion.classement, hasLength(3));
      expect(fusion.classement.map((c) => c.score).reduce((a, b) => a + b), lessThanOrEqualTo(1.0));
    });
  });
}
