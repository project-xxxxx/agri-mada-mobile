// Modèle Isar - Parcelle locale (journal agricole hors-ligne)

import 'package:isar/isar.dart';

part 'parcelle_local.g.dart';

@collection
class ParcelleLocal {
  Id id = Isar.autoIncrement;

  // Identifiant généré sur le téléphone ; le serveur ignore les renvois (P1.9).
  // Null pour les parcelles créées avant son ajout : attribué à la synchro.
  String? clientUuid;

  late String nomParcelle;

  // Emplacement saisi par l'agriculteur (village, fokontany, repère).
  String? description;

  // Culture déclarée ; null pour les parcelles créées avant son ajout (riz).
  String? culture;

  double? surface;
  double? latitude;
  double? longitude;
  String? photoPath;
  late DateTime createdAt;

  // Clé pour identifier la parcelle dans le serveur après synchro
  int? serverId;

  // false = créé hors-ligne, pas encore envoyé au serveur FastAPI
  bool isSynced = false;
}
