// Service Isar - Initialisation et accès à la base de données locale
// Ce service est le point central qui ouvre la base Isar une seule fois
// au démarrage de l'application et fournit l'instance à tous les repositories.

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/user_local.dart';
import 'models/parcelle_local.dart';
import 'models/diagnostic_local.dart';
import 'models/diagnostic_session_local.dart';
import 'models/observation_local.dart';

class IsarService {
  IsarService._();
  static final IsarService instance = IsarService._();

  Isar? _isar;

  Isar get db {
    if (_isar == null || !_isar!.isOpen) {
      throw StateError(
        'IsarService non initialisé. Appelez init() au démarrage.',
      );
    }
    return _isar!;
  }

  /// À appeler une seule fois dans main() avant runApp()
  Future<void> init() async {
    if (_isar != null && _isar!.isOpen) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        UserLocalSchema,
        ParcelleLocalSchema,
        DiagnosticLocalSchema,
        DiagnosticSessionLocalSchema,
        ObservationLocalSchema,
      ],
      directory: dir.path,
      name: 'agrimada_local',
    );
  }

  Future<void> close() async {
    await _isar?.close();
  }
}
