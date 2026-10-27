// Contexte d'une parcelle : écosystème, altitude, saison et stade (tâche P2.5).
//
// Ces informations servent au technicien et, plus tard, à l'a priori de la
// fusion (P2.4) : une bactériose des gaines n'a pas le même poids au-dessus de
// 1600 m qu'en bas-fond côtier.

/// Écosystème rizicole, au sens des fiches FOFIFA.
enum Ecosysteme {
  irrigue('irrigue'),
  basFond('bas_fond'),
  tanetyPluvial('tanety_pluvial');

  const Ecosysteme(this.code);
  final String code;

  static Ecosysteme? fromCode(String? code) {
    for (final valeur in values) {
      if (valeur.code == code) return valeur;
    }
    return null;
  }
}

/// Tranche d'altitude, choisie quand le GPS ne donne rien d'exploitable.
/// Les bornes reprennent celles des catalogues variétaux FOFIFA (basse
/// altitude, moyenne altitude, hautes terres, très hautes terres).
enum TrancheAltitude {
  moins800('moins_800'),
  de800a1200('800_1200'),
  de1200a1500('1200_1500'),
  plus1500('plus_1500');

  const TrancheAltitude(this.code);
  final String code;

  static TrancheAltitude? fromCode(String? code) {
    for (final valeur in values) {
      if (valeur.code == code) return valeur;
    }
    return null;
  }

  /// Tranche déduite d'une altitude GPS, en mètres.
  static TrancheAltitude depuisMetres(double metres) => switch (metres) {
        < 800 => TrancheAltitude.moins800,
        < 1200 => TrancheAltitude.de800a1200,
        < 1500 => TrancheAltitude.de1200a1500,
        _ => TrancheAltitude.plus1500,
      };
}

/// Saison de culture. Les trois noms sont ceux employés couramment ;
/// l'agronome doit confirmer les usages régionaux.
enum SaisonRiz {
  varyAloha('vary_aloha'),
  saisonPrincipale('saison_principale'),
  contreSaison('contre_saison');

  const SaisonRiz(this.code);
  final String code;

  static SaisonRiz? fromCode(String? code) {
    for (final valeur in values) {
      if (valeur.code == code) return valeur;
    }
    return null;
  }
}

/// Stade de culture déduit de la date de repiquage.
enum StadeCulture {
  reprise('reprise'),
  tallage('tallage'),
  montaison('montaison'),
  epiaison('epiaison'),
  maturation('maturation');

  const StadeCulture(this.code);
  final String code;

  static StadeCulture? fromCode(String? code) {
    for (final valeur in values) {
      if (valeur.code == code) return valeur;
    }
    return null;
  }
}

/// Stade atteint depuis le repiquage. Les durées sont celles d'un cycle
/// courant ; le cours de pathologie signale que la période sensible va de la
/// montaison à l'épiaison (docs/connaissances/cours-pathologie-riz.md).
StadeCulture? stadeDepuisRepiquage(DateTime? repiquage, {DateTime? maintenant}) {
  if (repiquage == null) return null;

  final jours = (maintenant ?? DateTime.now()).difference(repiquage).inDays;
  if (jours < 0) return null; // repiquage annoncé dans le futur

  return switch (jours) {
    < 15 => StadeCulture.reprise,
    < 45 => StadeCulture.tallage,
    < 70 => StadeCulture.montaison,
    < 95 => StadeCulture.epiaison,
    _ => StadeCulture.maturation,
  };
}
