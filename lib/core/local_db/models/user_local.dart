// Modèle Isar - Utilisateur local (session hors-ligne)
// Stocke les informations de profil après la première connexion internet

import 'package:isar/isar.dart';

part 'user_local.g.dart';

@collection
class UserLocal {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String tel;

  late String nom;
  late String prenom;
  late String region;
  int? serverId; // L'ID sur le serveur FastAPI
  late DateTime createdAt;
}
