// Filtres de l'historique des analyses (tâche P1.10).
//
// « Grave » s'appuie sur la part de parcelle déclarée par l'agriculteur, jamais
// sur la confiance du modèle (tâche P1.3).

import '../../../core/ai/disease_catalog.dart';
import '../../../core/local_db/models/diagnostic_local.dart';
import '../../scan/domain/entities/declared_severity.dart';

enum DiagnosticFilter { all, lastSevenDays, severe, healthy }

List<DiagnosticLocal> applyDiagnosticFilter(
  List<DiagnosticLocal> diagnostics,
  DiagnosticFilter filter, {
  DateTime? now,
}) {
  final weekAgo = (now ?? DateTime.now()).subtract(const Duration(days: 7));

  bool keep(DiagnosticLocal diagnostic) => switch (filter) {
        DiagnosticFilter.all => true,
        DiagnosticFilter.lastSevenDays =>
          !diagnostic.dateDiagnostic.isBefore(weekAgo),
        DiagnosticFilter.severe =>
          DeclaredSeverity.fromCode(diagnostic.niveauGravite) ==
              DeclaredSeverity.plusDunTiers,
        DiagnosticFilter.healthy =>
          DiseaseCatalog.isHealthy(diagnostic.maladieDetectee),
      };

  return diagnostics.where(keep).toList();
}
