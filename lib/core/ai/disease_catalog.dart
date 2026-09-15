// Catalogue des classes du modèle : nom traduit, nom scientifique, gestes de
// prévention (tâche P1.1) et textes de la fiche du guide des maladies (P1.5).
//
// Aucun produit ni dosage : les conseils reprennent la fiche FOFIFA « Les
// maladies bactériennes du riz » (CRR Antsirabe, 2020) et des bonnes pratiques
// générales. Tout traitement passe par un technicien agricole.

import '../../l10n/app_localizations.dart';

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
}

abstract final class DiseaseCatalog {
  static final List<DiseaseInfo> _entries = [
    DiseaseInfo(
      label: 'Bacterial leaf blight',
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

  /// Fiches du guide, une par classe (« normal » double « healthy »).
  static List<DiseaseInfo> get guides => [
        for (final info in _entries)
          if (info.label != 'normal' && info.description != null) info,
      ];
}
