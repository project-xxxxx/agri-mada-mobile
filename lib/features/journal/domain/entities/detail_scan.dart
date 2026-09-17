// Scan passé tel que l'écran de détail l'affiche : résumé du journal, photos
// avec les réponses données, et pistes du modèle.

import '../../../../core/ai/diagnosis_certainty.dart';
import '../../../scan/domain/entities/organe.dart';
import 'resultat_scan.dart';

class PhotoDuScan {
  const PhotoDuScan({
    required this.organe,
    required this.imagePath,
    this.reponses = const {},
  });

  final Organe? organe;
  final String imagePath;

  /// Question du questionnaire → option choisie.
  final Map<String, String> reponses;
}

class DetailScan {
  const DetailScan({
    required this.resume,
    required this.photos,
    this.classement = const [],
    this.estSynchronise = false,
  });

  final ResultatScan resume;
  final List<PhotoDuScan> photos;

  /// Pistes fusionnées, la première en tête. À n'afficher que si le scan est
  /// nommé (ADR-006) : sinon ce ne sont pas des résultats.
  final List<ScoredLabel> classement;

  /// Déjà envoyé au serveur : le supprimer du téléphone ne l'efface pas là-bas.
  final bool estSynchronise;

  /// Réponses de chaque organe photographié, dans l'ordre des photos.
  Map<Organe, Map<String, String>> get reponsesParOrgane {
    final parOrgane = <Organe, Map<String, String>>{};
    for (final photo in photos) {
      final organe = photo.organe;
      if (organe == null) continue;
      parOrgane.putIfAbsent(organe, () => {}).addAll(photo.reponses);
    }
    return parOrgane;
  }
}
