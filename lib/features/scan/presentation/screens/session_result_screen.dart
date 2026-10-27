// Résultat d'une session de scan (tâches P2.4 et P2.6).
//
// Deux cas seulement :
//   - l'app sait nommer une fiche : elle l'affiche comme une piste à confirmer,
//     avec les gestes de prévention du catalogue (aucun produit, aucune dose) ;
//   - elle ne sait pas : elle le dit et renvoie au technicien, avec les photos
//     et les réponses.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/ai/diagnosis_certainty.dart';
import '../../../../core/ai/disease_catalog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../journal/presentation/providers/journal_provider.dart';
import '../../domain/entities/declared_severity.dart';
import '../../domain/entities/organe.dart';
import '../../domain/questionnaire.dart';
import '../diagnosis_labels.dart';
import '../organ_labels.dart';
import '../providers/session_scan_provider.dart';

class SessionResultScreen extends ConsumerStatefulWidget {
  const SessionResultScreen({super.key});

  @override
  ConsumerState<SessionResultScreen> createState() => _SessionResultScreenState();
}

class _SessionResultScreenState extends ConsumerState<SessionResultScreen> {
  DeclaredSeverity? _gravite;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final etat = ref.watch(scanSessionProvider);
    final fusion = etat.fusion;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(loc.scanSessionResultTitle, style: AppTypography.headlineMedium),
      ),
      body: fusion == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(loc.scanNoResult, textAlign: TextAlign.center),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (fusion.nommable && fusion.classement.isNotEmpty)
                  ..._resultatNomme(loc, etat, fusion.classement.first.label)
                else
                  _CarteNonNomme(loc: loc, analyseParModele: fusion.analyseParModele),
                const SizedBox(height: AppSpacing.md),
                Text(
                  loc.scanSessionPhotosSaved(etat.photos.length),
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                if (etat.parcelleLocalId == null) ..._rattachementParcelle(loc),
                const SizedBox(height: AppSpacing.sm),
                _BoutonPrincipal(
                  icone: Icons.support_agent,
                  libelle: loc.scanAskTechnician,
                  onPressed: () => _demanderTechnicien(loc, etat),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(scanSessionProvider.notifier).reset();
                    context.go(AppRoutes.journal);
                  },
                  icon: const Icon(Icons.check),
                  label: Text(loc.scanSessionFinish),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
    );
  }

  List<Widget> _resultatNomme(
    AppLocalizations loc,
    ScanSessionState etat,
    String label,
  ) {
    final info = DiseaseCatalog.of(label);
    final certitude = etat.fusion!.certitude;
    final autres = etat.fusion!.classement
        .skip(1)
        .map((candidat) => DiseaseCatalog.displayName(candidat.label, loc))
        .toList();

    return [
      Text(
        DiseaseCatalog.displayName(label, loc),
        style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
      ),
      if (info != null && info.scientificName.isNotEmpty)
        Text(
          info.scientificName,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      const SizedBox(height: AppSpacing.sm),
      _Bandeau(
        titre: certitude.label(loc),
        texte: certitude == DiagnosisCertainty.probable
            ? loc.scanCertaintyExplainProbable
            : loc.scanCertaintyExplainPossible,
        couleur: certitude == DiagnosisCertainty.probable
            ? AppColors.primary
            : AppColors.severityMedium,
        icone: certitude == DiagnosisCertainty.probable
            ? Icons.check_circle_outline
            : Icons.help_outline,
      ),
      if (autres.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.sm),
        Text(
          loc.scanOtherCandidates(autres.join(', ')),
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
      if (info == null || !info.isHealthy) ...[
        const SizedBox(height: AppSpacing.lg),
        Text(loc.scanSeverityQuestion,
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final gravite in DeclaredSeverity.values)
              ChoiceChip(
                label: Text(gravite.label(loc)),
                selected: _gravite == gravite,
                onSelected: (choisie) {
                  setState(() => _gravite = choisie ? gravite : null);
                  if (choisie) {
                    ref.read(scanSessionProvider.notifier).declarerGravite(gravite.code);
                  }
                },
              ),
          ],
        ),
      ],
      if (info != null && info.advice.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.lg),
        Text(loc.scanAdviceTitle,
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final conseil in info.advice)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check, size: 18, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(conseil(loc), style: AppTypography.bodySmall)),
                    ],
                  ),
                ),
              Text(
                loc.scanAdviceNoChemical,
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    ];
  }

  List<Widget> _rattachementParcelle(AppLocalizations loc) => [
        Text(
          loc.scanSessionAttachPlotHint,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        OutlinedButton.icon(
          onPressed: _choisirParcelle,
          icon: const Icon(Icons.map_outlined),
          label: Text(loc.scanSessionAttachPlot),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ];

  Future<void> _choisirParcelle() async {
    final loc = AppLocalizations.of(context);
    final parcelles = await ref.read(parcelleRepositoryProvider).getAllParcelles();
    if (!mounted) return;

    if (parcelles.isEmpty) {
      context.go(AppRoutes.myParcelles);
      return;
    }

    final choisie = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(loc.scanSelectPlot, style: AppTypography.headlineMedium),
            ),
            for (final parcelle in parcelles)
              ListTile(
                leading: const Icon(Icons.map_outlined, color: AppColors.primary),
                title: Text(parcelle.nomParcelle),
                onTap: () => Navigator.of(context).pop(parcelle.id),
              ),
          ],
        ),
      ),
    );

    if (choisie == null || !mounted) return;
    await ref.read(scanSessionProvider.notifier).rattacherParcelle(choisie);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(loc.scanSessionAttached)));
  }

  Future<void> _demanderTechnicien(AppLocalizations loc, ScanSessionState etat) async {
    final fusion = etat.fusion;
    final pistes = fusion != null && fusion.nommable
        ? fusion.classement
            .map((candidat) => DiseaseCatalog.displayName(candidat.label, loc))
            .join(', ')
        : '';

    final texte = [
      loc.scanAskTechnicianMessage,
      for (final organe in etat.photos.map((p) => p.organe).toSet())
        '${organeLabelBilingue(organe, loc)} : ${_reponsesLisibles(loc, etat, organe)}',
      if (pistes.isNotEmpty) loc.scanAskTechnicianCandidates(pistes),
      loc.scanShareDate(DateFormat('dd/MM/yyyy').format(DateTime.now())),
    ].join('\n');

    final fichiers = [
      for (final photo in etat.photos)
        if (File(photo.chemin).existsSync()) XFile(photo.chemin),
    ];

    if (fichiers.isEmpty) {
      await Share.share(texte);
    } else {
      await Share.shareXFiles(fichiers, text: texte);
    }
  }

  String _reponsesLisibles(
    AppLocalizations loc,
    ScanSessionState etat,
    Organe organe,
  ) {
    final reponses = etat.reponsesDe(organe);
    if (reponses.isEmpty) return loc.commonDontKnow;

    final libelles = <String>[];
    for (final question in ScanQuestionnaire.pour(organe)) {
      final option = question.optionById(reponses[question.id]);
      if (option != null) libelles.add(option.label(loc));
    }
    return libelles.isEmpty ? loc.commonDontKnow : libelles.join(' ; ');
  }
}

class _CarteNonNomme extends StatelessWidget {
  const _CarteNonNomme({required this.loc, required this.analyseParModele});

  final AppLocalizations loc;

  /// true : le modèle a vu une photo mais n'a rien reconnu de sûr (pas du riz,
  /// trop peu de végétation, résultat incertain). false : aucune photo d'un
  /// organe analysé par le modèle.
  final bool analyseParModele;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.severityMedium.withAlpha(25),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.severityMedium.withAlpha(90)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, color: AppColors.severityMedium),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  analyseParModele ? loc.scanUncertainTitle : loc.scanSessionNoName,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.severityMedium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            analyseParModele ? loc.scanSessionNotRecognizedBody : loc.scanSessionNoNameBody,
            style: AppTypography.bodySmall,
          ),
          if (analyseParModele) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(loc.scanRetakeTips, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class _Bandeau extends StatelessWidget {
  const _Bandeau({
    required this.titre,
    required this.texte,
    required this.couleur,
    required this.icone,
  });

  final String titre;
  final String texte;
  final Color couleur;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: couleur.withAlpha(25),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: couleur.withAlpha(90)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: couleur),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: AppTypography.bodyMedium
                      .copyWith(color: couleur, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(texte, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BoutonPrincipal extends StatelessWidget {
  const _BoutonPrincipal({
    required this.icone,
    required this.libelle,
    required this.onPressed,
  });

  final IconData icone;
  final String libelle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icone),
      label: Text(libelle),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
    );
  }
}
