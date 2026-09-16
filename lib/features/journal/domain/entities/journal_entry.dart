// Data class typée pour les entrées du journal agricole
// Remplace l'usage de Map<String, dynamic> non typé

import '../../../../core/local_db/models/parcelle_local.dart';
import 'resultat_scan.dart';

class JournalEntry {
  const JournalEntry({
    required this.parcelle,
    required this.nbDiagnostics,
    required this.statut,
    this.derniereMaladie,
    this.dernierResultat,
  });

  final ParcelleLocal parcelle;
  final int nbDiagnostics;
  final String? derniereMaladie;
  /// Dernier scan terminé de la parcelle (tâche P2.3).
  final ResultatScan? dernierResultat;

  /// Statut de santé de la parcelle : 'sain', 'malade' (diagnostic probable),
  /// 'a_confirmer' (piste non confirmée), 'aucun_diagnostic'
  final String statut;
}
