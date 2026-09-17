// Modèle Isar - Diagnostic local (résultat IA hors-ligne)
// Les maladies détectables correspondent aux labels du modèle
// (assets/model/labels.txt) :
//   - Bacterial leaf blight
//   - Brown spot
//   - Leaf smut

import 'package:isar/isar.dart';

part 'diagnostic_local.g.dart';

@collection
class DiagnosticLocal {
  Id id = Isar.autoIncrement;

  // Identifiant généré sur le téléphone ; le serveur ignore les renvois (P1.9).
  // Null pour les diagnostics créés avant son ajout : attribué à la synchro.
  String? clientUuid;

  // Lien vers la parcelle locale
  late int parcelleLocalId;

  late String maladieDetectee; // Label retourné par TFLite
  double? confiance; // Score entre 0.0 et 1.0

  // Part de la parcelle touchée, déclarée par l'agriculteur :
  // quelques_plants / moins_tiers / plus_tiers (voir DeclaredSeverity).
  // Les anciennes valeurs calculées (faible / modéré / sévère) sont affichées
  // comme « non renseignée ».
  String? niveauGravite;

  // Certitude du modèle au moment du diagnostic : probable / possible
  // (voir DiagnosisCertainty). Null pour les diagnostics antérieurs.
  String? certitude;

  String? recommandations;
  String? imagePath; // Chemin local de la photo prise
  int? inferenceTimeMs;

  late DateTime dateDiagnostic;

  // false = pas encore envoyé au serveur FastAPI
  bool isSynced = false;

  // Optionnel : ID serveur après synchro
  int? serverId;
}
