// Catalogue des classes du modèle : nom traduit, nom scientifique, gestes de
// prévention (tâche P1.1) et textes de la fiche du guide des maladies (P1.5).
//
// Aucun produit ni dosage : les conseils reprennent la fiche FOFIFA « Les
// maladies bactériennes du riz » (CRR Antsirabe, 2020) et des bonnes pratiques
// générales. Tout traitement passe par un technicien agricole.
//
// Deux vocabulaires cohabitent (ADR-014) : les ids de ml/taxonomy_v1.yaml du
// modèle feuille_v2 embarqué, et les étiquettes anglaises de l'ancien modèle,
// gardées pour les sessions et diagnostics déjà enregistrés.

import '../../l10n/app_localizations.dart';
import 'diagnosis_certainty.dart' show etiquettePasRiz;

typedef LocalizedText = String Function(AppLocalizations loc);

class DiseaseInfo {
  const DiseaseInfo({
    required this.label,
    required this.name,
    required this.scientificName,
    required this.advice,
    this.description,
    this.symptoms,
    this.causes,
    this.isHealthy = false,
    this.isRejection = false,
    this.ficheId,
  });

  /// Étiquette exacte produite par le modèle (assets/model/labels.txt).
  final String label;
  final LocalizedText name;
  final String scientificName;
  final List<LocalizedText> advice;

  /// Textes de la fiche affichée dans le guide des maladies.
  final LocalizedText? description;
  final LocalizedText? symptoms;
  final LocalizedText? causes;
  final bool isHealthy;

  /// Classe de rejet (pas_riz) : jamais présentée comme une maladie.
  final bool isRejection;

  /// Fiche de assets/knowledge/fiches.json consultable dans le guide complet
  /// (P5.3). Diffère parfois de l'étiquette : une fiche regroupe les organes.
  final String? ficheId;
}

/// Gestes communs aux maladies à champignons sans fiche FOFIFA dédiée.
final List<LocalizedText> _conseilsChampignon = [
  (loc) => loc.scanAdviceHealthySeeds,
  (loc) => loc.scanAdviceRemoveResidues,
  (loc) => loc.scanAdviceAlertTechnician,
];

/// Gestes d'une carence : se corrige par la fertilisation, pas un traitement.
final List<LocalizedText> _conseilsCarence = [
  (loc) => loc.scanRecHealthyFertilization,
  (loc) => loc.scanRecHealthyMonitoring,
  (loc) => loc.scanAdviceAlertTechnician,
];

abstract final class DiseaseCatalog {
  static final List<DiseaseInfo> _entries = [
    // --- Modèle feuille_v2 embarqué (ids de ml/taxonomy_v1.yaml, ADR-014) ---
    DiseaseInfo(
      label: 'blb',
      ficheId: 'blb',
      name: (loc) => loc.diseaseBacterialLeafBlight,
      scientificName: 'Xanthomonas oryzae pv. oryzae',
      advice: [
        (loc) => loc.scanAdviceHealthySeeds,
        (loc) => loc.scanAdviceRemoveResidues,
        (loc) => loc.scanAdviceRemoveHostWeeds,
        (loc) => loc.scanAdviceCleanTools,
        (loc) => loc.scanRecBlbAvoidNitrogen,
        (loc) => loc.scanRecBlbUseResistantVarieties,
        (loc) => loc.scanAdviceAlertTechnician,
      ],
    ),
    DiseaseInfo(
      label: 'bls',
      ficheId: 'bls',
      name: (loc) => loc.diseaseBacterialLeafStreak,
      scientificName: 'Xanthomonas oryzae pv. oryzicola',
      advice: [
        (loc) => loc.scanAdviceHealthySeeds,
        (loc) => loc.scanAdviceRemoveResidues,
        (loc) => loc.scanAdviceRemoveHostWeeds,
        (loc) => loc.scanAdviceCleanTools,
        (loc) => loc.scanAdviceAlertTechnician,
      ],
    ),
    DiseaseInfo(
      label: 'helminthosporiose',
      ficheId: 'helminthosporiose',
      name: (loc) => loc.diseaseBrownSpot,
      scientificName: 'Bipolaris oryzae',
      advice: [
        (loc) => loc.scanRecBrownSpotFertilize,
        (loc) => loc.scanRecBrownSpotAvoidStress,
        (loc) => loc.scanAdviceHealthySeeds,
        (loc) => loc.scanAdviceAlertTechnician,
      ],
    ),
    DiseaseInfo(
      label: 'pyriculariose_feuille',
      ficheId: 'pyriculariose',
      name: (loc) => loc.diseaseBlast,
      scientificName: 'Magnaporthe oryzae',
      advice: [
        (loc) => loc.scanRecBlbAvoidNitrogen,
        (loc) => loc.scanRecBlbUseResistantVarieties,
        (loc) => loc.scanAdviceHealthySeeds,
        (loc) => loc.scanAdviceRemoveResidues,
        (loc) => loc.scanAdviceAlertTechnician,
      ],
    ),
    DiseaseInfo(
      label: 'cercosporiose',
      ficheId: 'cercosporiose',
      name: (loc) => loc.diseaseNarrowBrownLeafSpot,
      scientificName: 'Cercospora janseana',
      advice: _conseilsChampignon,
    ),
    DiseaseInfo(
      label: 'echaudure',
      ficheId: 'echaudure',
      name: (loc) => loc.diseaseLeafScald,
      scientificName: 'Microdochium oryzae',
      advice: _conseilsChampignon,
    ),
    DiseaseInfo(
      label: 'mildiou',
      ficheId: 'mildiou',
      name: (loc) => loc.diseaseDownyMildew,
      scientificName: 'Sclerophthora macrospora',
      advice: _conseilsChampignon,
    ),
    DiseaseInfo(
      label: 'degats_hispa',
      ficheId: 'degats_hispa',
      name: (loc) => loc.diseaseHispaDamage,
      scientificName: 'Hispa gestroi, Trichispa sericea',
      advice: [
        (loc) => loc.scanRecHealthyMonitoring,
        (loc) => loc.scanAdviceAlertTechnician,
      ],
    ),
    DiseaseInfo(
      label: 'carence_azote',
      ficheId: 'carence_azote',
      name: (loc) => loc.diseaseNitrogenDeficiency,
      scientificName: '',
      advice: _conseilsCarence,
    ),
    DiseaseInfo(
      label: 'carence_phosphore',
      ficheId: 'carence_phosphore',
      name: (loc) => loc.diseasePhosphorusDeficiency,
      scientificName: '',
      advice: _conseilsCarence,
    ),
    DiseaseInfo(
      label: 'carence_potassium',
      ficheId: 'carence_potassium',
      name: (loc) => loc.diseasePotassiumDeficiency,
      scientificName: '',
      advice: [
        (loc) => loc.scanRecBrownSpotFertilize,
        ..._conseilsCarence,
      ],
    ),
    DiseaseInfo(
      label: 'feuille_saine',
      name: (loc) => loc.diseaseHealthy,
      scientificName: '',
      isHealthy: true,
      advice: [
        (loc) => loc.scanRecHealthyMonitoring,
        (loc) => loc.scanRecHealthyFertilization,
        (loc) => loc.scanRecHealthyWater,
      ],
    ),
    DiseaseInfo(
      label: etiquettePasRiz,
      name: (loc) => loc.diseaseNotRice,
      scientificName: '',
      isRejection: true,
      advice: [(loc) => loc.scanRetakeTips],
    ),

    // --- Ancien modèle (3 classes), pour les résultats déjà enregistrés ---
    DiseaseInfo(
      label: 'Bacterial leaf blight',
      ficheId: 'blb',
      name: (loc) => loc.diseaseBacterialLeafBlight,
      scientificName: 'Xanthomonas oryzae pv. oryzae',
      description: (loc) => loc.guideDisease1Desc,
      symptoms: (loc) => loc.guideDisease1Symptoms,
      causes: (loc) => loc.guideDisease1Causes,
      advice: [
        (loc) => loc.scanAdviceHealthySeeds,
        (loc) => loc.scanAdviceRemoveResidues,
        (loc) => loc.scanAdviceRemoveHostWeeds,
        (loc) => loc.scanAdviceCleanTools,
        (loc) => loc.scanRecBlbAvoidNitrogen,
        (loc) => loc.scanRecBlbUseResistantVarieties,
        (loc) => loc.scanAdviceAlertTechnician,
      ],
    ),
    DiseaseInfo(
      label: 'Brown spot',
      ficheId: 'helminthosporiose',
      name: (loc) => loc.diseaseBrownSpot,
      scientificName: 'Bipolaris oryzae',
      description: (loc) => loc.guideDisease2Desc,
      symptoms: (loc) => loc.guideDisease2Symptoms,
      causes: (loc) => loc.guideDisease2Causes,
      advice: [
        (loc) => loc.scanRecBrownSpotFertilize,
        (loc) => loc.scanRecBrownSpotAvoidStress,
        (loc) => loc.scanAdviceHealthySeeds,
        (loc) => loc.scanAdviceAlertTechnician,
      ],
    ),
    DiseaseInfo(
      label: 'Leaf smut',
      name: (loc) => loc.diseaseLeafSmut,
      scientificName: 'Entyloma oryzae',
      description: (loc) => loc.guideDisease3Desc,
      symptoms: (loc) => loc.guideDisease3Symptoms,
      causes: (loc) => loc.guideDisease3Causes,
      advice: [
        (loc) => loc.scanAdviceHealthySeeds,
        (loc) => loc.scanAdviceRemoveResidues,
        (loc) => loc.scanAdviceAlertTechnician,
      ],
    ),
    for (final label in const ['healthy', 'normal'])
      DiseaseInfo(
        label: label,
        name: (loc) => loc.diseaseHealthy,
        scientificName: '',
        isHealthy: true,
        description: (loc) => loc.guideDisease4Desc,
        symptoms: (loc) => loc.guideDisease4Symptoms,
        advice: [
          (loc) => loc.scanRecHealthyMonitoring,
          (loc) => loc.scanRecHealthyFertilization,
          (loc) => loc.scanRecHealthyWater,
        ],
      ),
  ];

  static final Map<String, DiseaseInfo> _byLabel = {
    for (final info in _entries) info.label.toLowerCase(): info,
  };

  static DiseaseInfo? of(String label) => _byLabel[label.trim().toLowerCase()];

  /// Nom affiché ; l'étiquette brute du modèle si la classe est inconnue.
  static String displayName(String label, AppLocalizations loc) =>
      of(label)?.name(loc) ?? label;

  static bool isHealthy(String label) => of(label)?.isHealthy ?? false;

  /// Étiquettes d'un modèle qui désignent un problème à nommer : ni l'état
  /// sain ni le rejet pas_riz (liste « maladies reconnues » de l'accueil).
  static List<String> problemesReconnus(Iterable<String> labels) => [
        for (final label in labels)
          if (!(of(label)?.isHealthy ?? false) && !(of(label)?.isRejection ?? false)) label,
      ];

  /// Fiches du guide, une par classe (« normal » double « healthy »).
  static List<DiseaseInfo> get guides => [
        for (final info in _entries)
          if (info.label != 'normal' && info.description != null) info,
      ];
}
