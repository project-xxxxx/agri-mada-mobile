// Modèle Isar — observation d'un organe dans une session de scan (tâche P2.3).
//
// L'organe est stocké sous forme de code (« feuille », « tige_gaine »…) comme
// les autres valeurs d'énumération de la base : la valeur reste lisible dans
// un export et ne dépend pas de l'ordre des constantes.

import 'package:isar/isar.dart';

import '../../../features/scan/domain/entities/organe.dart';

part 'observation_local.g.dart';

@collection
class ObservationLocal {
  Id id = Isar.autoIncrement;

  /// Identifiant généré sur le téléphone (P1.9).
  @Index(unique: true, replace: false)
  late String clientUuid;

  @Index()
  late int sessionId;

  /// Code de l'organe observé (voir Organe.code).
  late String organeCode;

  late String imagePath;

  /// Mesures du contrôle de qualité (P2.2), gardées pour le technicien.
  double? qualiteNettete;
  double? qualiteLuminosite;

  /// Sortie du modèle au format JSON : [{"label": ..., "p": ...}].
  /// null pour un organe sans modèle embarqué.
  String? topK;

  /// Réponses au questionnaire au format JSON : {"id_question": "id_option"}.
  String? reponses;

  late DateTime createdAt;

  bool isSynced = false;
  int? serverId;

  @ignore
  Organe? get organe => Organe.fromCode(organeCode);

  @ignore
  set organe(Organe? value) => organeCode = value?.code ?? Organe.feuille.code;
}
