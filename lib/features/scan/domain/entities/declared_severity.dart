/// Part de la parcelle touchée, déclarée par l'agriculteur (tâche P1.3).
///
/// La gravité n'est plus déduite de la confiance du modèle : la certitude d'un
/// résultat ne dit rien de l'étendue des dégâts dans la parcelle.
enum DeclaredSeverity {
  quelquesPlants('quelques_plants'),
  moinsDunTiers('moins_tiers'),
  plusDunTiers('plus_tiers');

  const DeclaredSeverity(this.code);

  /// Valeur stockée dans `DiagnosticLocal.niveauGravite` et envoyée au serveur.
  final String code;

  /// Renvoie null pour une valeur absente ou héritée de l'ancien calcul
  /// (« faible », « modéré », « sévère »), affichée comme non renseignée.
  static DeclaredSeverity? fromCode(String? code) {
    for (final value in values) {
      if (value.code == code) return value;
    }
    return null;
  }
}
