// Certitude d'un résultat du modèle, exprimée en mots pour l'agriculteur (tâche P1.2).

/// Classe du modèle et score associé.
class ScoredLabel {
  const ScoredLabel(this.label, this.score);

  final String label;
  final double score;

  @override
  bool operator ==(Object other) =>
      other is ScoredLabel && other.label == label && other.score == score;

  @override
  int get hashCode => Object.hash(label, score);

  @override
  String toString() => 'ScoredLabel($label, $score)';
}

enum DiagnosisCertainty {
  /// Classe nettement en tête : le résultat peut être présenté comme probable.
  probable,

  /// Classe en tête mais proche d'autres : résultat à faire confirmer.
  possible,

  /// Score trop faible : aucune maladie n'est retenue ni enregistrée.
  incertain;

  static DiagnosisCertainty? fromName(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

/// Seuils provisoires, à recalibrer sur des photos malgaches (tâche P4.4).
abstract final class CertaintyThresholds {
  static const double probableMinScore = 0.70;
  static const double probableMinMargin = 0.20;
  static const double possibleMinScore = 0.50;
}

/// Classe les scores du plus élevé au plus faible et garde les [k] premiers.
List<ScoredLabel> rankScores(
  List<double> scores,
  List<String> labels, {
  int k = 3,
}) {
  final count = scores.length < labels.length ? scores.length : labels.length;
  final ranked = [
    for (var i = 0; i < count; i++) ScoredLabel(labels[i], scores[i]),
  ]..sort((a, b) => b.score.compareTo(a.score));
  return ranked.take(k).toList();
}

DiagnosisCertainty certaintyOf(List<ScoredLabel> ranked) {
  if (ranked.isEmpty) return DiagnosisCertainty.incertain;

  final best = ranked.first.score;
  final second = ranked.length > 1 ? ranked[1].score : 0.0;

  if (best >= CertaintyThresholds.probableMinScore &&
      best - second >= CertaintyThresholds.probableMinMargin) {
    return DiagnosisCertainty.probable;
  }
  if (best >= CertaintyThresholds.possibleMinScore) {
    return DiagnosisCertainty.possible;
  }
  return DiagnosisCertainty.incertain;
}
