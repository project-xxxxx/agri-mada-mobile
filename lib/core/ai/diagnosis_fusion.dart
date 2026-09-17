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
// Ces règles ne font que classer les fiches. La certitude est lue sur les
// scores bruts des photos acceptées, avec les seuils calibrés d'ADR-006
// (ADR-015) : les scores fusionnés sont écrasés par le poids et les bornes, et
// une photo à 0,61 contre 0,36 y tombait sous 0,5, donc « non reconnue ».
//
// Garde-fous repris de l'ADR-006 (rétablis pour les sessions en ADR-014) :
//   - une session sans observation analysée par un modèle ne nomme aucune
//     maladie : elle part au technicien ;
//   - une session qui ne repose que sur des réponses n'atteint jamais
//     « probable » ;
//   - une photo que le modèle rejette (moins de 10 % de végétation, ou classe
//     pas_riz en tête) n'apporte aucun score ;
//   - un résultat « incertain » ne nomme aucune maladie et n'est pas
//     enregistré comme tel ;
//   - une session appuyée sur le modèle n'atteint pas « probable » tant que le
//     modèle n'est pas validé sur des photos malgaches (P4.6).

import 'dart:math' as math;

import '../../features/scan/domain/entities/organe.dart';
import 'diagnosis_certainty.dart';

/// Ce qu'une photo et ses réponses apportent au diagnostic.
class ObservationEvidence {
  const ObservationEvidence({
    required this.organe,
    this.scores = const <ScoredLabel>[],
    this.indices = const <String, double>{},
    this.vegetationRatio,
  });

  final Organe organe;

  /// Sortie du modèle pour cette photo, triée par score décroissant ; vide
  /// pour un organe sans modèle.
  final List<ScoredLabel> scores;

  /// Indices du questionnaire : étiquette de fiche → poids (positif = pour).
  final Map<String, double> indices;

  /// Part de pixels végétaux de la photo analysée ; null si non mesurée.
  final double? vegetationRatio;

  bool get analyseeParModele => organe.usesModel && scores.isNotEmpty;

  /// Le modèle a vu la photo mais ne l'a pas reconnue comme du riz exploitable.
  bool get rejeteeParModele =>
      analyseeParModele &&
      ((vegetationRatio != null &&
              vegetationRatio! < CertaintyThresholds.minVegetationRatio) ||
          scores.first.label == etiquettePasRiz);

  bool get apporteDesScores => analyseeParModele && !rejeteeParModele;
}

class FusedDiagnosis {
  const FusedDiagnosis({
    required this.classement,
    required this.certitude,
    required this.nommable,
    this.analyseParModele = false,
    this.photoAcceptee = false,
  });

  /// Jusqu'à trois candidats, du plus au moins probable.
  final List<ScoredLabel> classement;
  final DiagnosisCertainty certitude;

  /// true seulement quand une photo acceptée par le modèle appuie le résultat
  /// et que la certitude n'est pas « incertain ». Sinon l'app n'affiche aucun
  /// nom de maladie et propose le technicien.
  final bool nommable;

  /// true quand au moins une photo est passée par le modèle, même rejetée :
  /// l'app dit alors « non reconnue » plutôt que « partie non analysée ».
  final bool analyseParModele;

  /// true quand au moins une photo a été acceptée par le modèle (ni pas_riz en
  /// tête, ni trop peu de végétation). Si rien n'est nommé, l'app dit alors
  /// que le modèle hésite, et non que la photo n'est peut-être pas du riz.
  final bool photoAcceptee;

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
  final avecModele = observations.any((observation) => observation.analyseeParModele);
  final avecScores = observations.any((observation) => observation.apporteDesScores);

  final candidats = <String>{
    for (final observation in observations) ...[
      if (observation.apporteDesScores)
        for (final score in observation.scores)
          if (score.label != etiquettePasRiz) score.label,
      ...observation.indices.keys,
    ],
    ...contexte.keys,
  };
  if (candidats.isEmpty) {
    return FusedDiagnosis(
      classement: const <ScoredLabel>[],
      certitude: DiagnosisCertainty.incertain,
      nommable: false,
      analyseParModele: avecModele,
      photoAcceptee: avecScores,
    );
  }

  final logScores = <String, double>{
    for (final candidat in candidats) candidat: contexte[candidat] ?? 0,
  };

  for (final observation in observations) {
    if (observation.apporteDesScores) {
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
  final certitude = avecModele ? _certitudeModele(observations) : _certitudeReponsesSeules(top);

  return FusedDiagnosis(
    classement: top,
    certitude: certitude,
    nommable: avecScores && certitude != DiagnosisCertainty.incertain,
    analyseParModele: avecModele,
    photoAcceptee: avecScores,
  );
}

/// Des réponses seules ne valent pas un diagnostic : au mieux une piste.
DiagnosisCertainty _certitudeReponsesSeules(List<ScoredLabel> classement) =>
    classement.isNotEmpty && classement.first.score >= CertaintyThresholds.possibleMinScore
        ? DiagnosisCertainty.possible
        : DiagnosisCertainty.incertain;

/// Certitude de la photo acceptée la plus sûre, lue sur ses scores bruts
/// (ADR-015).
///
/// Photos vues par le modèle mais toutes rejetées : « incertain », sinon les
/// réponses seules donneraient « possible » et l'agent backend (qui lit
/// certitude et top_k) nommerait ce que l'app tait.
DiagnosisCertainty _certitudeModele(List<ObservationEvidence> observations) {
  var certitude = DiagnosisCertainty.incertain;
  for (final observation in observations) {
    if (!observation.apporteDesScores) continue;
    final photo = certaintyOf(observation.scores, vegetationRatio: observation.vegetationRatio);
    if (photo != DiagnosisCertainty.incertain) {
      certitude = DiagnosisCertainty.possible;
    }
  }
  // Même à 0,999, une photo reste une piste tant que P4.6 n'a pas validé le
  // modèle : « probable » marquerait la parcelle comme confirmée.
  return certitude;
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
