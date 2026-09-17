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

/// Seuils mesurés le 2026-09-16 sur 50 photos hors sujet et 600 feuilles de riz
/// prises au champ (ml/reports/eval_hors_sujet_2026-09-16.json).
///
/// Avec l'ancien seuil de 0,70, 21 photos hors sujet et 105 feuilles saines
/// étaient présentées comme malades « probables », et la tache brune n'était
/// jamais reconnue. Aucun « probable » faux ne subsiste à partir de 0,997 ;
/// 0,999 garde une marge. Le modèle actuel n'atteint donc pas « probable » :
/// ses résultats restent des pistes à confirmer. À recalibrer en P4.4.
abstract final class CertaintyThresholds {
  static const double probableMinScore = 0.999;
  static const double probableMinMargin = 0.20;
  static const double possibleMinScore = 0.50;

  /// En dessous de cette part de pixels végétaux (sol, mains, écran…), la
  /// photo n'est pas analysée comme une plante : résultat incertain.
  static const double minVegetationRatio = 0.10;
}

/// Classe de rejet du modèle feuille : la photo n'est pas du riz (porte, P4.2).
/// Jamais affichée comme une maladie.
const String etiquettePasRiz = 'pas_riz';

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

/// Certitude affichée pour un classement du modèle. [vegetationRatio] est la
/// part de pixels végétaux de la photo (voir image_checks.dart).
DiagnosisCertainty certaintyOf(
  List<ScoredLabel> ranked, {
  double? vegetationRatio,
}) {
  if (ranked.isEmpty) return DiagnosisCertainty.incertain;
  if (vegetationRatio != null &&
      vegetationRatio < CertaintyThresholds.minVegetationRatio) {
    return DiagnosisCertainty.incertain;
  }

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
