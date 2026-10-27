// Libellés du contexte de parcelle (tâche P2.5).

import '../../../l10n/app_localizations.dart';
import '../domain/entities/contexte_parcelle.dart';
import '../domain/entities/varietes_riz.dart';

String ecosystemeLabel(Ecosysteme ecosysteme, AppLocalizations loc) =>
    switch (ecosysteme) {
      Ecosysteme.irrigue => loc.ecosystemIrrigated,
      Ecosysteme.basFond => loc.ecosystemLowland,
      Ecosysteme.tanetyPluvial => loc.ecosystemUpland,
    };

String altitudeLabel(TrancheAltitude tranche, AppLocalizations loc) =>
    switch (tranche) {
      TrancheAltitude.moins800 => loc.altitudeUnder800,
      TrancheAltitude.de800a1200 => loc.altitude800to1200,
      TrancheAltitude.de1200a1500 => loc.altitude1200to1500,
      TrancheAltitude.plus1500 => loc.altitudeOver1500,
    };

String saisonLabel(SaisonRiz saison, AppLocalizations loc) => switch (saison) {
      SaisonRiz.varyAloha => loc.seasonVaryAloha,
      SaisonRiz.saisonPrincipale => loc.seasonMain,
      SaisonRiz.contreSaison => loc.seasonOffSeason,
    };

String stadeLabel(StadeCulture stade, AppLocalizations loc) => switch (stade) {
      StadeCulture.reprise => loc.stageRecovery,
      StadeCulture.tallage => loc.stageTillering,
      StadeCulture.montaison => loc.stageStemElongation,
      StadeCulture.epiaison => loc.stageHeading,
      StadeCulture.maturation => loc.stageMaturity,
    };

/// Nom affiché d'une variété enregistrée ; « locale ou inconnue » par défaut.
String varieteLabel(String? code, AppLocalizations loc) =>
    (code == null || code == varieteLocaleOuInconnue)
        ? loc.varietyLocalUnknown
        : code;
