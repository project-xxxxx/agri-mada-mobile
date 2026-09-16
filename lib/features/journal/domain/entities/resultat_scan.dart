// Résultat d'une session de scan, tel que le journal l'affiche (tâche P2.3).
//
// Les écrans ne manipulent plus les objets de la base : ils lisent ce résumé,
// qui dit aussi ce que l'app ne sait pas nommer.

import '../../../../core/ai/diagnosis_certainty.dart';
import '../../../../core/ai/disease_catalog.dart';
import '../../../scan/domain/entities/organe.dart';

class ResultatScan {
  const ResultatScan({
    required this.sessionId,
    required this.date,
    required this.organes,
    this.parcelleLocalId,
    this.ficheId,
    this.certitude,
    this.graviteDeclaree,
    this.imagePath,
    this.nbPhotos = 0,
  });

  final int sessionId;
  final DateTime date;
  final List<Organe> organes;
  final int? parcelleLocalId;

  /// Étiquette de la fiche retenue ; null quand l'app ne nomme rien (ADR-006).
  final String? ficheId;

  /// probable | possible | incertain.
  final String? certitude;
  final String? graviteDeclaree;

  /// Première photo de la session, pour la vignette.
  final String? imagePath;
  final int nbPhotos;

  bool get estNomme => ficheId != null;

  bool get estSain => ficheId != null && DiseaseCatalog.isHealthy(ficheId!);

  /// Seul un résultat « probable » vaut un diagnostic (ADR-006).
  bool get estConfirme => certitude == DiagnosisCertainty.probable.name;
}
