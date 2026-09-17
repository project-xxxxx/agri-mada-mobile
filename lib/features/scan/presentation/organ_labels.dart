// Libellés et repères visuels des organes (tâche P2.1).
//
// Le nom est affiché dans les deux langues : un agriculteur qui utilise l'app en
// malgache reconnaît aussi le mot français employé par les techniciens, et
// inversement.

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/entities/organe.dart';

extension OrganeLabel on Organe {
  String label(AppLocalizations loc) => switch (this) {
        Organe.feuille => loc.organLeaf,
        Organe.tigeGaine => loc.organStemSheath,
        Organe.collet => loc.organCollar,
        Organe.racines => loc.organRoots,
        Organe.paniculeGrains => loc.organPanicle,
        Organe.planteEntiere => loc.organWholePlant,
      };

  IconData get icone => switch (this) {
        Organe.feuille => Icons.eco_outlined,
        Organe.tigeGaine => Icons.grass_outlined,
        Organe.collet => Icons.park_outlined,
        Organe.racines => Icons.account_tree_outlined,
        Organe.paniculeGrains => Icons.grain_outlined,
        Organe.planteEntiere => Icons.landscape_outlined,
      };

  /// Cadre de prise de vue : la tige et les racines se photographient debout,
  /// la parcelle en paysage (tâche P2.2).
  double get ratioCadre => switch (this) {
        Organe.tigeGaine || Organe.racines || Organe.collet => 3 / 4,
        Organe.planteEntiere => 4 / 3,
        _ => 1,
      };
}

/// Consigne de prise de vue propre à l'organe (tâche P2.2).
String captureHint(Organe organe, AppLocalizations loc) => switch (organe) {
      Organe.feuille => loc.captureHintLeaf,
      Organe.tigeGaine => loc.captureHintStem,
      Organe.collet => loc.captureHintCollar,
      Organe.racines => loc.captureHintRoots,
      Organe.paniculeGrains => loc.captureHintPanicle,
      Organe.planteEntiere => loc.captureHintWholePlant,
    };

/// « Feuilles · Ravina » en français, « Ravina · Feuilles » en malgache.
String organeLabelBilingue(Organe organe, AppLocalizations loc) {
  final autreLangue = lookupAppLocalizations(
    Locale(loc.localeName.startsWith('mg') ? 'fr' : 'mg'),
  );
  final principal = organe.label(loc);
  final secondaire = organe.label(autreLangue);
  return principal == secondaire ? principal : '$principal · $secondaire';
}
