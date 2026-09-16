// Data class typée pour les entrées du journal agricole
// Remplace l'usage de Map<String, dynamic> non typé

import '../../../../core/local_db/models/diagnostic_local.dart';
import '../../../../core/local_db/models/parcelle_local.dart';

class JournalEntry {
  const JournalEntry({
    required this.parcelle,
    required this.nbDiagnostics,
    required this.statut,
    this.derniereMaladie,
    this.dernierDiagnostic,
  });

  final ParcelleLocal parcelle;
  final int nbDiagnostics;
  final String? derniereMaladie;
  final DiagnosticLocal? dernierDiagnostic;

  /// Statut de santé de la parcelle : 'sain', 'malade' (diagnostic probable),
  /// 'a_confirmer' (piste non confirmée), 'aucun_diagnostic'
  final String statut;
}
