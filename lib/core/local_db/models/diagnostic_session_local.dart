// Modèle Isar — session de diagnostic (tâche P2.3).
//
// Une session regroupe une à trois observations, chacune rattachée à un organe.
// Elle remplace l'ancien DiagnosticLocal, conservé le temps de la migration.

import 'package:isar/isar.dart';

part 'diagnostic_session_local.g.dart';

@collection
class DiagnosticSessionLocal {
  Id id = Isar.autoIncrement;

  /// Identifiant généré sur le téléphone : un renvoi ne crée pas de doublon (P1.9).
  @Index(unique: true, replace: false)
  late String clientUuid;

  /// null tant que la session n'est rattachée à aucune parcelle (P2.6).
  int? parcelleLocalId;

  late DateTime createdAt;

  /// Contexte au moment du scan, recopié depuis la parcelle quand elle existe.
  String? stade;
  String? ecosysteme;

  /// Fiche retenue après fusion, ou null quand l'app ne nomme rien (P2.4).
  String? resultatFicheId;

  /// probable | possible | incertain (voir DiagnosisCertainty).
  String? certitude;

  /// Classement complet au format JSON : [{"label": ..., "p": ...}].
  String? classement;

  /// Part de parcelle déclarée par l'agriculteur (voir DeclaredSeverity).
  String? graviteDeclaree;

  /// non_valide | valide_technicien | corrige : renseigné par la boucle
  /// technicien (P5.6).
  String statutValidation = 'non_valide';

  /// Identifiant de l'ancien diagnostic dont la session est issue : rend la
  /// migration rejouable sans créer de doublon.
  int? origineDiagnosticId;

  bool isSynced = false;
  int? serverId;
}
