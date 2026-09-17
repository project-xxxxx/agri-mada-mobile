// Détail d'un scan passé, ouvert depuis le journal ou la fiche d'une parcelle.
//
// Mêmes règles que l'écran de résultat : rien n'est présenté comme un
// diagnostic tant qu'il n'est pas « probable », et les autres pistes du modèle
// ne s'affichent que si l'app a su nommer quelque chose (ADR-006).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/ai/diagnosis_certainty.dart';
import '../../../../core/ai/disease_catalog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../knowledge/presentation/providers/fiches_provider.dart';
import '../../../knowledge/presentation/widgets/fiche_card.dart';
import '../../../scan/presentation/diagnosis_labels.dart';
import '../../../scan/presentation/organ_labels.dart';
import '../../../scan/presentation/providers/session_scan_provider.dart'
    show sessionRepositoryProvider;
import '../../../scan/presentation/technician_message.dart';
import '../../domain/entities/detail_scan.dart';
import '../providers/journal_provider.dart';
import '../resultat_labels.dart';

class ScanDetailScreen extends ConsumerWidget {
  const ScanDetailScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final detailAsync = ref.watch(detailScanProvider(sessionId));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: loc.commonClose,
          onPressed: () => _retour(context),
        ),
        title: Text(loc.scanDetailTitle, style: AppTypography.headlineMedium),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text(loc.journalError('$e'))),
        data: (detail) => detail == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(loc.scanDetailNotFound, textAlign: TextAlign.center),
                ),
              )
            : _Contenu(detail: detail),
      ),
    );
  }
}

void _retour(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.journal);
  }
}

class _Contenu extends ConsumerWidget {
  const _Contenu({required this.detail});

  final DetailScan detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final resume = detail.resume;
    final parcelles = ref.watch(parcellesProvider).valueOrNull ?? const [];
    final nomParcelle = resume.parcelleLocalId == null
        ? null
        : parcelles.where((p) => p.id == resume.parcelleLocalId).firstOrNull?.nomParcelle;

    final info = resume.ficheId == null ? null : DiseaseCatalog.of(resume.ficheId!);
    final idFiche = resume.ficheId == null ? null : (info?.ficheId ?? resume.ficheId);
    final fiche = idFiche == null
        ? null
        : ref.watch(fichesProvider).valueOrNull?.where((f) => f.id == idFiche).firstOrNull;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          DateFormat('dd/MM/yyyy · HH:mm').format(resume.date),
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (detail.photos.isNotEmpty) _Photos(photos: detail.photos),
        const SizedBox(height: AppSpacing.md),
        ..._resultat(loc),
        if (!resume.estSain) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            loc.scanDetailDeclaredSeverity(declaredSeverityLabel(resume.graviteDeclaree, loc)),
            style: AppTypography.bodySmall,
          ),
        ],
        if (detail.reponsesParOrgane.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(loc.scanDetailAnswers,
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.xs),
          for (final entree in detail.reponsesParOrgane.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: '${organeLabelBilingue(entree.key, loc)} : ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: reponsesLisibles(entree.key, entree.value, loc)),
                ]),
                style: AppTypography.bodySmall,
              ),
            ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _Parcelle(
          nom: nomParcelle,
          rattache: resume.parcelleLocalId != null,
          onChoisir: () => _choisirParcelle(context, ref),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (fiche != null) ...[
          OutlinedButton.icon(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppColors.background,
              builder: (context) => DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.8,
                builder: (context, controleur) => ListView(
                  controller: controleur,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [FicheCard(fiche: fiche, initiallyExpanded: true)],
                ),
              ),
            ),
            icon: const Icon(Icons.menu_book_outlined),
            label: Text(loc.scanDetailOpenFiche),
            style: _styleSecondaire,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        ElevatedButton.icon(
          onPressed: () => _demanderTechnicien(loc),
          icon: const Icon(Icons.support_agent),
          label: Text(loc.scanAskTechnician),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => context.push(resume.parcelleLocalId == null
              ? AppRoutes.scanOrgane
              : '${AppRoutes.scanOrgane}?parcelleId=${resume.parcelleLocalId}'),
          icon: const Icon(Icons.camera_alt_outlined),
          label: Text(loc.scanDetailFollowUp),
          style: _styleSecondaire,
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.conseiller),
          icon: const Icon(Icons.chat_outlined),
          label: Text(loc.scanDetailAskAdvisor),
          style: _styleSecondaire,
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton.icon(
          onPressed: () => _supprimer(context, ref),
          icon: const Icon(Icons.delete_outline),
          label: Text(loc.scanDetailDelete),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.severityHigh,
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  static final _styleSecondaire = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    minimumSize: const Size.fromHeight(48),
    side: const BorderSide(color: AppColors.primary),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  );

  List<Widget> _resultat(AppLocalizations loc) {
    final resume = detail.resume;
    if (!resume.estNomme) {
      return [
        Text(loc.journalUnnamedResult,
            style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.xs),
        Text(loc.scanDetailUnnamedBody, style: AppTypography.bodySmall),
      ];
    }

    final info = DiseaseCatalog.of(resume.ficheId!);
    final certitude = DiagnosisCertainty.fromName(resume.certitude) ?? DiagnosisCertainty.possible;
    final probable = certitude == DiagnosisCertainty.probable;
    final autres = detail.classement
        .skip(1)
        .map((candidat) => DiseaseCatalog.displayName(candidat.label, loc))
        .toList();

    return [
      Text(nomResultat(resume, loc),
          style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
      if (info != null && info.scientificName.isNotEmpty)
        Text(
          info.scientificName,
          style: AppTypography.caption
              .copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
        ),
      const SizedBox(height: AppSpacing.sm),
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: (probable ? AppColors.primary : AppColors.severityMedium).withAlpha(25),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              certitude.label(loc),
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: probable ? AppColors.primary : AppColors.severityMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              probable ? loc.scanCertaintyExplainProbable : loc.scanCertaintyExplainPossible,
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
      if (autres.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.sm),
        Text(
          loc.scanOtherCandidates(autres.join(', ')),
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    ];
  }

  Future<void> _demanderTechnicien(AppLocalizations loc) async {
    final pistes = detail.resume.estNomme
        ? detail.classement
            .map((candidat) => DiseaseCatalog.displayName(candidat.label, loc))
            .toList()
        : const <String>[];

    await partagerAvecTechnicien(
      texte: messageTechnicien(
        loc: loc,
        reponsesParOrgane: detail.reponsesParOrgane,
        pistes: pistes,
        date: detail.resume.date,
      ),
      cheminsPhotos: detail.photos.map((photo) => photo.imagePath),
    );
  }

  Future<void> _choisirParcelle(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context);
    final parcelles = await ref.read(parcelleRepositoryProvider).getAllParcelles();
    if (!context.mounted) return;

    if (parcelles.isEmpty) {
      context.push(AppRoutes.myParcelles);
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
                selected: parcelle.id == detail.resume.parcelleLocalId,
                onTap: () => Navigator.of(context).pop(parcelle.id),
              ),
          ],
        ),
      ),
    );

    if (choisie == null || choisie == detail.resume.parcelleLocalId) return;
    await ref.read(sessionRepositoryProvider).rattacherParcelle(
          sessionId: detail.resume.sessionId,
          parcelleLocalId: choisie,
        );
    rafraichirScans(ref, sessionId: detail.resume.sessionId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.scanSessionAttached)));
  }

  Future<void> _supprimer(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context);
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.scanDetailDelete),
        content: Text(
          detail.estSynchronise
              ? '${loc.scanDetailDeleteConfirm}\n\n${loc.scanDetailDeleteSyncedWarning}'
              : loc.scanDetailDeleteConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.severityHigh),
            child: Text(loc.scanDetailDeleteAction),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    await ref.read(sessionRepositoryProvider).supprimerSession(detail.resume.sessionId);
    rafraichirScans(ref);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.scanDetailDeleted)));
    _retour(context);
  }
}

class _Photos extends StatelessWidget {
  const _Photos({required this.photos});

  final List<PhotoDuScan> photos;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final photo = photos[index];
          final fichier = File(photo.imagePath);
          final presente = photo.imagePath.isNotEmpty && fichier.existsSync();
          return Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                onTap: presente ? () => _agrandir(context, fichier) : null,
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: presente
                      ? Image.file(fichier, fit: BoxFit.cover)
                      : Tooltip(
                          message: loc.scanDetailPhotoMissing,
                          child: const Icon(Icons.image_not_supported_outlined,
                              color: AppColors.textSecondary),
                        ),
                ),
              ),
              if (photo.organe != null)
                SizedBox(
                  width: 104,
                  child: Text(
                    photo.organe!.label(loc),
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _agrandir(BuildContext context, File fichier) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(child: InteractiveViewer(child: Image.file(fichier))),
            SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: AppLocalizations.of(context).commonClose,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Parcelle extends StatelessWidget {
  const _Parcelle({required this.nom, required this.rattache, required this.onChoisir});

  final String? nom;
  final bool rattache;
  final VoidCallback onChoisir;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          const Icon(Icons.map_outlined, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              rattache && nom != null ? loc.scanDetailPlot(nom!) : loc.scanDetailNoPlot,
              style: AppTypography.bodySmall,
            ),
          ),
          TextButton(
            onPressed: onChoisir,
            child: Text(rattache ? loc.scanDetailChangePlot : loc.scanSessionAttachPlot),
          ),
        ],
      ),
    );
  }
}
