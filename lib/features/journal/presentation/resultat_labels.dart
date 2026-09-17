// Libellés d'un résultat de scan dans le journal (tâche P2.3).

import '../../../core/ai/disease_catalog.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/resultat_scan.dart';

/// Nom affiché : la fiche quand l'app sait la nommer, sinon un libellé honnête.
String nomResultat(ResultatScan resultat, AppLocalizations loc) =>
    resultat.ficheId == null
        ? loc.journalUnnamedResult
        : DiseaseCatalog.displayName(resultat.ficheId!, loc);
