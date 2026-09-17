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

  /// Surface en hectares, quelle que soit l'unité saisie (tâche P2.5).
  double? surface;
  double? latitude;
  double? longitude;
  String? photoPath;
  late DateTime createdAt;

  // --- Contexte de culture (tâche P2.5) ---

  /// irrigue | bas_fond | tanety_pluvial (voir Ecosysteme).
  String? ecosysteme;

  /// Une des 23 régions de Madagascar.
  String? region;

  /// Tranche d'altitude choisie, ou déduite du GPS (voir TrancheAltitude).
  String? altitudeTranche;

  /// Altitude en mètres quand le GPS la donne.
  double? altitudeMetres;

  /// Nom de variété du catalogue FOFIFA, ou « locale_ou_inconnue ».
  String? variete;

  /// vary_aloha | saison_principale | contre_saison (voir SaisonRiz).
  String? saison;

  /// Date de repiquage : sert à situer le stade de culture.
  DateTime? dateRepiquage;

  // Clé pour identifier la parcelle dans le serveur après synchro
  int? serverId;

  // false = créé hors-ligne, pas encore envoyé au serveur FastAPI
  bool isSynced = false;
}
