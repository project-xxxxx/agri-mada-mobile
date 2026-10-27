// Libellés affichés pour la certitude du modèle et la gravité déclarée.

import '../../../core/ai/diagnosis_certainty.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/declared_severity.dart';

extension DiagnosisCertaintyLabel on DiagnosisCertainty {
  String label(AppLocalizations loc) => switch (this) {
        DiagnosisCertainty.probable => loc.scanCertaintyProbable,
        DiagnosisCertainty.possible => loc.scanCertaintyPossible,
        DiagnosisCertainty.incertain => loc.scanCertaintyUncertain,
      };
}

extension DeclaredSeverityLabel on DeclaredSeverity {
  String label(AppLocalizations loc) => switch (this) {
        DeclaredSeverity.quelquesPlants => loc.scanSeverityFewPlants,
        DeclaredSeverity.moinsDunTiers => loc.scanSeverityUnderThird,
        DeclaredSeverity.plusDunTiers => loc.scanSeverityOverThird,
      };
}

/// Libellé d'une gravité stockée ; « non renseignée » pour une valeur absente
/// ou héritée de l'ancien calcul automatique.
String declaredSeverityLabel(String? code, AppLocalizations loc) =>
    DeclaredSeverity.fromCode(code)?.label(loc) ?? loc.scanSeverityUnknown;
