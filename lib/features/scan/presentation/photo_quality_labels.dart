// Consignes affichées quand une photo est refusée (tâche P2.2).

import '../../../core/ai/image_quality.dart';
import '../../../l10n/app_localizations.dart';

String photoQualityMessage(ImageQualityIssue probleme, AppLocalizations loc) =>
    switch (probleme) {
      ImageQualityIssue.flou => loc.photoQualityBlurred,
      ImageQualityIssue.sousExpose => loc.photoQualityTooDark,
      ImageQualityIssue.surExpose => loc.photoQualityTooBright,
      ImageQualityIssue.contreJour => loc.photoQualityBacklit,
    };
