// Filtres de l'historique des analyses (tâche P1.10, adapté aux sessions P2.3).
//
// « Plus d'un tiers touché » s'appuie sur la part de parcelle déclarée par
// l'agriculteur, jamais sur la confiance du modèle (tâche P1.3).

import '../../knowledge/domain/fiche_search.dart';
import '../../scan/domain/entities/declared_severity.dart';
import '../../scan/domain/entities/organe.dart';
import '../domain/entities/resultat_scan.dart';

enum DiagnosticFilter { all, lastSevenDays, severe, healthy }

enum TriJournal { plusRecents, plusAnciens, gravite }

/// Valeur de [rechercherDansJournal.parcelleId] pour les scans sans parcelle.
const int sansParcelle = -1;

/// Recherche, parcelle, organe et tri du journal, après le filtre rapide.
///
/// [nomDe] donne le texte cherché d'un résultat (nom affiché, nom scientifique) :
/// il dépend de la langue de l'écran. [parcelleId] null garde toutes les
/// parcelles. Le tri par gravité suit la part de parcelle déclarée (P1.3) ;
/// à gravité égale, le plus récent d'abord.
List<ResultatScan> rechercherDansJournal(
  List<ResultatScan> resultats, {
  required String Function(ResultatScan resultat) nomDe,
  String texte = '',
  int? parcelleId,
  Organe? organe,
  TriJournal tri = TriJournal.plusRecents,
}) {
  final motsClefs = normaliserRecherche(texte.trim());

  bool garder(ResultatScan resultat) {
    if (parcelleId == sansParcelle && resultat.parcelleLocalId != null) return false;
    if (parcelleId != null && parcelleId != sansParcelle && resultat.parcelleLocalId != parcelleId) {
      return false;
    }
    if (organe != null && !resultat.organes.contains(organe)) return false;
    return motsClefs.isEmpty || normaliserRecherche(nomDe(resultat)).contains(motsClefs);
  }

  int rangGravite(ResultatScan resultat) {
    if (resultat.estSain) return -1;
    return switch (DeclaredSeverity.fromCode(resultat.graviteDeclaree)) {
      DeclaredSeverity.plusDunTiers => 3,
      DeclaredSeverity.moinsDunTiers => 2,
      DeclaredSeverity.quelquesPlants => 1,
      null => 0,
    };
  }

  final retenus = resultats.where(garder).toList();
  retenus.sort((a, b) => switch (tri) {
        TriJournal.plusRecents => b.date.compareTo(a.date),
        TriJournal.plusAnciens => a.date.compareTo(b.date),
        TriJournal.gravite => rangGravite(b) != rangGravite(a)
            ? rangGravite(b).compareTo(rangGravite(a))
            : b.date.compareTo(a.date),
      });
  return retenus;
}

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
