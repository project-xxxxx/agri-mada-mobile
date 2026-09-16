// Questionnaire d'observation, deux à quatre questions par organe (tâche P2).
//
// Deux rôles :
//   - décrire ce que l'agriculteur voit, y compris pour les organes sans modèle,
//     et transmettre cette description au technicien ;
//   - apporter des indices à la fusion (P2.4) pour les fiches que l'app sait
//     nommer, c'est-à-dire aujourd'hui les seules classes du modèle feuille.
//
// Les libellés reprennent les symptômes des fiches du guide, eux-mêmes tirés de
// la fiche FOFIFA des maladies bactériennes et des jeux de référence. Les poids
// sont provisoires et seront recalibrés en P4.

import '../../../core/ai/disease_catalog.dart' show LocalizedText;
import '../../../l10n/app_localizations.dart';
import 'entities/organe.dart';

class ScanAnswerOption {
  const ScanAnswerOption({
    required this.id,
    required this.label,
    this.indices = const <String, double>{},
  });

  final String id;
  final LocalizedText label;

  /// Étiquette de fiche → poids en log : positif pour, négatif contre.
  final Map<String, double> indices;
}

class ScanQuestion {
  const ScanQuestion({
    required this.id,
    required this.prompt,
    required this.options,
  });

  final String id;
  final LocalizedText prompt;
  final List<ScanAnswerOption> options;

  ScanAnswerOption? optionById(String? id) {
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }
}

abstract final class ScanQuestionnaire {
  /// Questions posées pour un organe, la dernière étant commune à tous.
  static List<ScanQuestion> pour(Organe organe) => [
        ...?_parOrgane[organe],
        _depuisQuand,
      ];

  /// Indices apportés par les réponses : identifiant de question → identifiant
  /// d'option. Les réponses inconnues sont ignorées.
  static Map<String, double> indices(
    Organe organe,
    Map<String, String> reponses,
  ) {
    final cumul = <String, double>{};
    for (final question in pour(organe)) {
      final option = question.optionById(reponses[question.id]);
      if (option == null) continue;
      option.indices.forEach((label, poids) {
        cumul[label] = (cumul[label] ?? 0) + poids;
      });
    }
    return cumul;
  }

  static const ScanAnswerOption _jeNeSaisPas = ScanAnswerOption(
    id: 'je_ne_sais_pas',
    label: _dontKnow,
  );

  static final Map<Organe, List<ScanQuestion>> _parOrgane = {
    Organe.feuille: [
      ScanQuestion(
        id: 'feuille_taches',
        prompt: (loc) => loc.questionLeafShape,
        options: [
          ScanAnswerOption(
            id: 'brunes_ovales',
            label: (loc) => loc.questionLeafShapeBrownOval,
            indices: const {
              'Brown spot': 0.8,
              'Bacterial leaf blight': -0.4,
              'Leaf smut': -0.3,
              'healthy': -0.6,
            },
          ),
          ScanAnswerOption(
            id: 'bandes_bord',
            label: (loc) => loc.questionLeafShapeYellowEdge,
            indices: const {
              'Bacterial leaf blight': 0.9,
              'Brown spot': -0.5,
              'Leaf smut': -0.4,
              'healthy': -0.6,
            },
          ),
          ScanAnswerOption(
            id: 'noires_anguleuses',
            label: (loc) => loc.questionLeafShapeBlackAngular,
            indices: const {
              'Leaf smut': 0.9,
              'Brown spot': -0.3,
              'Bacterial leaf blight': -0.4,
              'healthy': -0.6,
            },
          ),
          ScanAnswerOption(
            id: 'aucune',
            label: (loc) => loc.questionLeafShapeNone,
            indices: const {
              'healthy': 0.7,
              'Bacterial leaf blight': -0.4,
              'Brown spot': -0.4,
              'Leaf smut': -0.4,
            },
          ),
          _jeNeSaisPas,
        ],
      ),
      ScanQuestion(
        id: 'feuille_exsudat',
        prompt: (loc) => loc.questionLeafExudate,
        options: [
          const ScanAnswerOption(
            id: 'oui',
            label: _yes,
            indices: {'Bacterial leaf blight': 0.7, 'healthy': -0.4},
          ),
          const ScanAnswerOption(
            id: 'non',
            label: _no,
            indices: {'Bacterial leaf blight': -0.3},
          ),
          _jeNeSaisPas,
        ],
      ),
      ScanQuestion(
        id: 'feuille_propagation',
        prompt: (loc) => loc.questionLeafSpread,
        options: [
          ScanAnswerOption(
            id: 'rapide',
            label: (loc) => loc.questionLeafSpreadFast,
            indices: const {'Bacterial leaf blight': 0.4, 'healthy': -0.3},
          ),
          ScanAnswerOption(
            id: 'lente',
            label: (loc) => loc.questionLeafSpreadSlow,
            indices: const {'Brown spot': 0.3},
          ),
          _jeNeSaisPas,
        ],
      ),
    ],
    Organe.tigeGaine: [
      ScanQuestion(
        id: 'tige_aspect',
        prompt: (loc) => loc.questionStem,
        options: [
          ScanAnswerOption(id: 'taches_brunes', label: (loc) => loc.questionStemBrownPatches),
          ScanAnswerOption(id: 'tige_molle', label: (loc) => loc.questionStemSoft),
          ScanAnswerOption(id: 'galeries', label: (loc) => loc.questionStemHoles),
          _jeNeSaisPas,
        ],
      ),
    ],
    Organe.collet: [
      ScanQuestion(
        id: 'collet_aspect',
        prompt: (loc) => loc.questionCollar,
        options: [
          ScanAnswerOption(id: 'ronge', label: (loc) => loc.questionCollarChewed),
          ScanAnswerOption(id: 'pourriture', label: (loc) => loc.questionCollarRot),
          ScanAnswerOption(id: 'anneau_brun', label: (loc) => loc.questionCollarRing),
          _jeNeSaisPas,
        ],
      ),
    ],
    Organe.racines: [
      ScanQuestion(
        id: 'racines_aspect',
        prompt: (loc) => loc.questionRoots,
        options: [
          ScanAnswerOption(id: 'rouillees', label: (loc) => loc.questionRootsRusty),
          ScanAnswerOption(id: 'noires', label: (loc) => loc.questionRootsBlack),
          ScanAnswerOption(id: 'galles', label: (loc) => loc.questionRootsGalls),
          _jeNeSaisPas,
        ],
      ),
    ],
    Organe.paniculeGrains: [
      ScanQuestion(
        id: 'panicule_aspect',
        prompt: (loc) => loc.questionPanicle,
        options: [
          ScanAnswerOption(id: 'blanche', label: (loc) => loc.questionPanicleWhite),
          ScanAnswerOption(id: 'grains_taches', label: (loc) => loc.questionPanicleStained),
          ScanAnswerOption(id: 'cou_brun', label: (loc) => loc.questionPanicleNeck),
          _jeNeSaisPas,
        ],
      ),
    ],
    Organe.planteEntiere: [
      ScanQuestion(
        id: 'parcelle_aspect',
        prompt: (loc) => loc.questionWholePlant,
        options: [
          ScanAnswerOption(id: 'taches_jaunes', label: (loc) => loc.questionWholePlantYellowPatches),
          ScanAnswerOption(id: 'foyers_secs', label: (loc) => loc.questionWholePlantDriedSpots),
          ScanAnswerOption(id: 'jaunissement_general', label: (loc) => loc.questionWholePlantEvenYellow),
          _jeNeSaisPas,
        ],
      ),
    ],
  };

  static final ScanQuestion _depuisQuand = ScanQuestion(
    id: 'depuis_quand',
    prompt: (loc) => loc.questionSinceWhen,
    options: [
      ScanAnswerOption(id: 'jours', label: (loc) => loc.questionSinceWhenDays),
      ScanAnswerOption(id: 'semaines', label: (loc) => loc.questionSinceWhenWeeks),
      ScanAnswerOption(id: 'mois', label: (loc) => loc.questionSinceWhenMonth),
      _jeNeSaisPas,
    ],
  );
}

String _dontKnow(AppLocalizations loc) => loc.commonDontKnow;
String _yes(AppLocalizations loc) => loc.commonYes;
String _no(AppLocalizations loc) => loc.commonNo;
