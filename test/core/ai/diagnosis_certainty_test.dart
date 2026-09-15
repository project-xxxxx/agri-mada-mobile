import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/ai/diagnosis_certainty.dart';

void main() {
  group('rankScores', () {
    test('classe du plus élevé au plus faible et garde les k premiers', () {
      final ranked = rankScores([0.1, 0.7, 0.2], ['A', 'B', 'C'], k: 2);

      expect(ranked, const [ScoredLabel('B', 0.7), ScoredLabel('C', 0.2)]);
    });

    test('ignore les scores sans étiquette', () {
      final ranked = rankScores([0.5, 0.3, 0.2], ['A', 'B']);

      expect(ranked.map((scored) => scored.label), ['A', 'B']);
    });
  });

  group('certaintyOf', () {
    test('probable au-dessus de 0,70 avec un écart de 0,20 sur le second', () {
      expect(
        certaintyOf(const [ScoredLabel('A', 0.80), ScoredLabel('B', 0.15)]),
        DiagnosisCertainty.probable,
      );
    });

    test('possible quand le premier est élevé mais proche du second', () {
      expect(
        certaintyOf(const [ScoredLabel('A', 0.72), ScoredLabel('B', 0.60)]),
        DiagnosisCertainty.possible,
      );
    });

    test('possible entre 0,50 et 0,70', () {
      expect(
        certaintyOf(const [ScoredLabel('A', 0.55), ScoredLabel('B', 0.20)]),
        DiagnosisCertainty.possible,
      );
    });

    test('incertain sous 0,50', () {
      expect(
        certaintyOf(const [ScoredLabel('A', 0.45), ScoredLabel('B', 0.35)]),
        DiagnosisCertainty.incertain,
      );
    });

    test('incertain sans aucun score', () {
      expect(certaintyOf(const []), DiagnosisCertainty.incertain);
    });
  });
}
