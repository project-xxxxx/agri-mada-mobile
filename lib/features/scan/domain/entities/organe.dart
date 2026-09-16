// Organe observé pendant un scan (tâche P2.1).
//
// Un seul organe dispose d'un modèle embarqué : la feuille. Les autres sont
// décrits par le questionnaire et transmis à un technicien, jusqu'aux modèles
// multi-organes de P4.

enum Organe {
  feuille('feuille', usesModel: true),
  tigeGaine('tige_gaine'),
  collet('collet'),
  racines('racines'),
  paniculeGrains('panicule_grains'),
  planteEntiere('plante_entiere');

  const Organe(this.code, {this.usesModel = false});

  /// Code stocké en base et envoyé au serveur.
  final String code;

  /// true quand le modèle embarqué sait analyser cet organe.
  final bool usesModel;

  static Organe? fromCode(String? code) {
    for (final organe in values) {
      if (organe.code == code) return organe;
    }
    return null;
  }
}

/// Séquence proposée quand l'agriculteur ne sait pas quoi photographier (P2.1) :
/// on part de la vue d'ensemble, puis on descend vers les organes utiles.
const List<Organe> guidedOrganSequence = [
  Organe.planteEntiere,
  Organe.feuille,
  Organe.collet,
];
