// Modèle Isar - Parcelle locale (journal agricole hors-ligne)

import 'package:isar/isar.dart';

part 'parcelle_local.g.dart';

@collection
class ParcelleLocal {
  Id id = Isar.autoIncrement;

  late String nomParcelle;
  String? description;
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
