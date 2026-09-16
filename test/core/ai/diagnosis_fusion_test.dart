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
