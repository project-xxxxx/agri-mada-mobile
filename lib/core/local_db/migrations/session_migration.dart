// Migration des anciens diagnostics vers les sessions (tâche P2.3).
//
// Chaque DiagnosticLocal devient une session portant une seule observation,
// rattachée à l'organe « feuille » : c'est le seul organe que l'ancienne
// version savait analyser. Les anciens enregistrements ne sont pas supprimés,
// pour que rien ne soit perdu si la migration doit être rejouée.

import 'dart:convert';

import 'package:isar/isar.dart';

import '../../utils/client_uuid.dart';
import '../../utils/logger.dart';
import '../../../features/scan/domain/entities/organe.dart';
import '../models/diagnostic_local.dart';
import '../models/diagnostic_session_local.dart';
import '../models/observation_local.dart';

/// Crée les sessions manquantes. Rejouable : un diagnostic déjà migré est
/// reconnu par `origineDiagnosticId`. Retourne le nombre de sessions créées.
Future<int> migrerDiagnosticsVersSessions(Isar db) async {
  final diagnostics = await db.diagnosticLocals.where().findAll();
  if (diagnostics.isEmpty) return 0;

  final dejaMigres = <int>{
    for (final session in await db.diagnosticSessionLocals.where().findAll())
      if (session.origineDiagnosticId != null) session.origineDiagnosticId!,
  };

  final aMigrer = diagnostics.where((d) => !dejaMigres.contains(d.id)).toList();
  if (aMigrer.isEmpty) return 0;

  await db.writeTxn(() async {
    for (final diagnostic in aMigrer) {
      final session = DiagnosticSessionLocal()
        ..clientUuid = diagnostic.clientUuid ?? generateClientUuid()
        ..parcelleLocalId = diagnostic.parcelleLocalId
        ..createdAt = diagnostic.dateDiagnostic
        ..resultatFicheId = diagnostic.maladieDetectee
        ..certitude = diagnostic.certitude
        ..graviteDeclaree = diagnostic.niveauGravite
        ..classement = _classementJson(
          diagnostic.maladieDetectee,
          diagnostic.confiance,
        )
        ..origineDiagnosticId = diagnostic.id
        ..isSynced = diagnostic.isSynced
        ..serverId = diagnostic.serverId;
      final sessionId = await db.diagnosticSessionLocals.put(session);

      final observation = ObservationLocal()
        ..clientUuid = generateClientUuid()
        ..sessionId = sessionId
        ..organeCode = Organe.feuille.code
        ..imagePath = diagnostic.imagePath ?? ''
        ..topK = _classementJson(diagnostic.maladieDetectee, diagnostic.confiance)
        ..createdAt = diagnostic.dateDiagnostic
        ..isSynced = diagnostic.isSynced;
      await db.observationLocals.put(observation);
    }
  });

  AppLogger.info('Migration P2.3 : ${aMigrer.length} diagnostic(s) devenus sessions');
  return aMigrer.length;
}

String _classementJson(String label, double? confiance) => jsonEncode([
      {'label': label, 'p': confiance ?? 0},
    ]);
