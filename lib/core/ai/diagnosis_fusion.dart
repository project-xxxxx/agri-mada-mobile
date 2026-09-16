// Fusion des observations d'une session de scan (tâche P2.4).
//
// Règles lisibles et testables, volontairement simples :
//   1. les scores du modèle de chaque observation sont additionnés en
//      log-probabilités ;
//   2. les réponses au questionnaire ajoutent des indices pour ou contre chaque
//      fiche ;
//   3. le contexte de parcelle ajoute un a priori.
// Les pondérations sont provisoires : elles seront recalibrées en P4 sur des
// diagnostics validés par des techniciens.
//
// Deux garde-fous repris de l'ADR-006 :
//   - une session sans observation analysée par un modèle ne nomme aucune
//     maladie : elle part au technicien ;
//   - une session qui ne repose que sur des réponses n'atteint jamais
//     « probable ».

import 'dart:math' as math;

import '../../features/scan/domain/entities/organe.dart';
import 'diagnosis_certainty.dart';

/// Ce qu'une photo et ses réponses apportent au diagnostic.
class ObservationEvidence {
  const ObservationEvidence({
    required this.organe,
    this.scores = const <ScoredLabel>[],
    this.indices = const <String, double>{},
  });

  final Organe organe;

  /// Sortie du modèle pour cette photo ; vide pour un organe sans modèle.
  final List<ScoredLabel> scores;

  /// Indices du questionnaire : étiquette de fiche → poids (positif = pour).
  final Map<String, double> indices;

  bool get analyseeParModele => organe.usesModel && scores.isNotEmpty;
}

class FusedDiagnosis {
  const FusedDiagnosis({
    required this.classement,
    required this.certitude,
    required this.nommable,
  });

  /// Jusqu'à trois candidats, du plus au moins probable.
  final List<ScoredLabel> classement;
  final DiagnosisCertainty certitude;

  /// false quand aucune observation n'a été analysée par un modèle : l'app
  /// n'affiche alors aucun nom de maladie et propose le technicien.
  final bool nommable;

  static const FusedDiagnosis aucun = FusedDiagnosis(
    classement: <ScoredLabel>[],
    certitude: DiagnosisCertainty.incertain,
    nommable: false,
  );
}

/// Le modèle embarqué se trompe souvent sur des photos de terrain (ADR-006) :
/// sa sortie pèse moitié moins qu'une observation directe de l'agriculteur.
const double poidsModele = 0.5;

/// Chaque probabilité du modèle est ramenée dans cet intervalle : une classe
/// absente de son top-3 reste possible, et une classe annoncée à 0,99 ne vaut
/// pas une certitude. Les deux bornes seront recalibrées en P4.
const double _probabiliteMin = 0.05;
const double _probabiliteMax = 0.95;

FusedDiagnosis fuseObservations(
  List<ObservationEvidence> observations, {
  Map<String, double> contexte = const <String, double>{},
  int k = 3,
}) {
  final candidats = <String>{
    for (final observation in observations) ...[
      for (final score in observation.scores) score.label,
      ...observation.indices.keys,
    ],
    ...contexte.keys,
  };
  if (candidats.isEmpty) return FusedDiagnosis.aucun;

  final logScores = <String, double>{
    for (final candidat in candidats) candidat: contexte[candidat] ?? 0,
  };

  for (final observation in observations) {
    if (observation.scores.isNotEmpty) {
      final parLabel = <String, double>{
        for (final score in observation.scores) score.label: score.score,
      };
      for (final candidat in candidats) {
        final probabilite =
            (parLabel[candidat] ?? 0).clamp(_probabiliteMin, _probabiliteMax);
        logScores[candidat] = logScores[candidat]! + poidsModele * math.log(probabilite);
      }
    }
    observation.indices.forEach((candidat, indice) {
      logScores[candidat] = (logScores[candidat] ?? 0) + indice;
    });
  }

  final classement = _softmax(logScores)..sort((a, b) => b.score.compareTo(a.score));
  final top = classement.take(k).toList();
  final avecModele = observations.any((observation) => observation.analyseeParModele);

  return FusedDiagnosis(
    classement: top,
    certitude: _certitude(top, avecModele),
    nommable: avecModele,
  );
}

DiagnosisCertainty _certitude(List<ScoredLabel> classement, bool avecModele) {
  if (classement.isEmpty) return DiagnosisCertainty.incertain;
  if (!avecModele) {
    // Des réponses seules ne valent pas un diagnostic : au mieux une piste.
    return classement.first.score >= CertaintyThresholds.possibleMinScore
        ? DiagnosisCertainty.possible
        : DiagnosisCertainty.incertain;
  }
  return certaintyOf(classement);
}

List<ScoredLabel> _softmax(Map<String, double> logScores) {
  final maximum = logScores.values.reduce(math.max);
  final exponentielles = <String, double>{
    for (final entree in logScores.entries)
      entree.key: math.exp(entree.value - maximum),
  };
  final total = exponentielles.values.fold<double>(0, (somme, v) => somme + v);
  return [
    for (final entree in exponentielles.entries)
      ScoredLabel(entree.key, total == 0 ? 0 : entree.value / total),
  ];
}
