// Message et photos envoyés au technicien, depuis le résultat d'un scan ou
// depuis un scan passé du journal.

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/entities/organe.dart';
import '../domain/questionnaire.dart';
import 'organ_labels.dart';

/// Réponses d'un organe en clair, « Je ne sais pas » quand il n'y en a aucune.
String reponsesLisibles(Organe organe, Map<String, String> reponses, AppLocalizations loc) {
  if (reponses.isEmpty) return loc.commonDontKnow;

  final libelles = <String>[];
  for (final question in ScanQuestionnaire.pour(organe)) {
    final option = question.optionById(reponses[question.id]);
    if (option != null) libelles.add(option.label(loc));
  }
  return libelles.isEmpty ? loc.commonDontKnow : libelles.join(' ; ');
}

/// [pistes] : noms à citer, vide quand l'app ne sait rien nommer (ADR-006).
String messageTechnicien({
  required AppLocalizations loc,
  required Map<Organe, Map<String, String>> reponsesParOrgane,
  required List<String> pistes,
  required DateTime date,
}) =>
    [
      loc.scanAskTechnicianMessage,
      for (final entree in reponsesParOrgane.entries)
        '${organeLabelBilingue(entree.key, loc)} : ${reponsesLisibles(entree.key, entree.value, loc)}',
      if (pistes.isNotEmpty) loc.scanAskTechnicianCandidates(pistes.join(', ')),
      loc.scanShareDate(DateFormat('dd/MM/yyyy').format(date)),
    ].join('\n');

/// Ouvre le partage du téléphone avec le message et les photos encore présentes.
Future<void> partagerAvecTechnicien({
  required String texte,
  required Iterable<String> cheminsPhotos,
}) async {
  final fichiers = [
    for (final chemin in cheminsPhotos)
      if (File(chemin).existsSync()) XFile(chemin),
  ];

  if (fichiers.isEmpty) {
    await Share.share(texte);
  } else {
    await Share.shareXFiles(fichiers, text: texte);
  }
}
