// Filtres de l'historique des analyses (tâche P1.10, adapté aux sessions P2.3).
//
// « Plus d'un tiers touché » s'appuie sur la part de parcelle déclarée par
// l'agriculteur, jamais sur la confiance du modèle (tâche P1.3).

import '../../scan/domain/entities/declared_severity.dart';
import '../domain/entities/resultat_scan.dart';

enum DiagnosticFilter { all, lastSevenDays, severe, healthy }

List<ResultatScan> applyDiagnosticFilter(
  List<ResultatScan> resultats,
  DiagnosticFilter filter, {
  DateTime? now,
}) {
  final weekAgo = (now ?? DateTime.now()).subtract(const Duration(days: 7));

  bool keep(ResultatScan resultat) => switch (filter) {
        DiagnosticFilter.all => true,
        DiagnosticFilter.lastSevenDays => !resultat.date.isBefore(weekAgo),
        DiagnosticFilter.severe =>
          DeclaredSeverity.fromCode(resultat.graviteDeclaree) ==
              DeclaredSeverity.plusDunTiers,
        DiagnosticFilter.healthy => resultat.estSain,
      };

  return resultats.where(keep).toList();
}
