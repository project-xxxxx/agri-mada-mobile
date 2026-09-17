import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:agri_mada/l10n/app_localizations.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/ai/disease_catalog.dart';
import '../../../../core/local_db/models/parcelle_local.dart';
import '../../../../core/widgets/app_sidebar.dart';
import '../../../scan/domain/entities/declared_severity.dart';
import '../../../scan/domain/entities/organe.dart';
import '../../../scan/presentation/diagnosis_labels.dart';
import '../../../scan/presentation/organ_labels.dart';
import '../../domain/entities/resultat_scan.dart';
import '../diagnostic_filter.dart';
import '../providers/journal_provider.dart';
import '../resultat_labels.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  DiagnosticFilter _filter = DiagnosticFilter.all;
  final _recherche = TextEditingController();
  int? _parcelleId;
  Organe? _organe;
  TriJournal _tri = TriJournal.plusRecents;

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  List<ResultatScan> _visibles(List<ResultatScan> resultats, AppLocalizations loc) =>
      rechercherDansJournal(
        applyDiagnosticFilter(resultats, _filter),
        nomDe: (resultat) {
          final info = resultat.ficheId == null ? null : DiseaseCatalog.of(resultat.ficheId!);
          return '${nomResultat(resultat, loc)} ${info?.scientificName ?? ''}';
        },
        texte: _recherche.text,
        parcelleId: _parcelleId,
        organe: _organe,
        tri: _tri,
      );

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final resultatsAsync = ref.watch(resultatsHistoryProvider);
    final parcelles = ref.watch(parcellesProvider).valueOrNull ?? const <ParcelleLocal>[];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, size: 28),
            tooltip: loc.homeMenuSemantics,
            onPressed: () => openAppMenu(context),
          ),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.homeServiceCropsTitle, style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
            Text(loc.journalHistorySubtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.cardRadius),
            topRight: Radius.circular(AppSpacing.cardRadius),
          ),
        ),
        child: resultatsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text(loc.journalError(e.toString()))),
          data: (resultats) {
            if (resultats.isEmpty) {
              return _EmptyHistory(onScan: () => context.go(AppRoutes.scanOrgane));
            }

            final visible = _visibles(resultats, loc);
            final organesPresents = [
              for (final organe in Organe.values)
                if (resultats.any((resultat) => resultat.organes.contains(organe))) organe,
            ];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BarreRecherche(
                  controleur: _recherche,
                  tri: _tri,
                  onChanged: () => setState(() {}),
                  onTri: (tri) => setState(() => _tri = tri),
                ),
                _FilterBar(
                  selected: _filter,
                  onSelected: (filter) => setState(() => _filter = filter),
                ),
                _FiltresParcelleOrgane(
                  parcelles: parcelles,
                  organes: organesPresents,
                  parcelleId: _parcelleId,
                  organe: _organe,
                  onParcelle: (id) => setState(() => _parcelleId = id),
                  onOrgane: (organe) => setState(() => _organe = organe),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Text(
                              loc.journalFilterEmpty,
                              style: AppTypography.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: visible.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) =>
                              _ResultatCard(resultat: visible[index]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.scanOrgane),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textOnPrimary),
      ),
    );
  }
}

class _BarreRecherche extends StatelessWidget {
  const _BarreRecherche({
    required this.controleur,
    required this.tri,
    required this.onChanged,
    required this.onTri,
  });

  final TextEditingController controleur;
  final TriJournal tri;
  final VoidCallback onChanged;
  final ValueChanged<TriJournal> onTri;

  String _libelleTri(TriJournal tri, AppLocalizations loc) => switch (tri) {
        TriJournal.plusRecents => loc.journalSortNewest,
        TriJournal.plusAnciens => loc.journalSortOldest,
        TriJournal.gravite => loc.journalSortSeverity,
      };

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.xs, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controleur,
              onChanged: (_) => onChanged(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: loc.journalSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controleur.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: loc.commonCancel,
                        onPressed: () {
                          controleur.clear();
                          onChanged();
                        },
                      ),
                isDense: true,
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          PopupMenuButton<TriJournal>(
            icon: const Icon(Icons.sort),
            tooltip: loc.journalSortTooltip,
            initialValue: tri,
            onSelected: onTri,
            itemBuilder: (context) => [
              for (final option in TriJournal.values)
                CheckedPopupMenuItem(
                  value: option,
                  checked: option == tri,
                  child: Text(_libelleTri(option, loc)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Parcelle et organe : des menus plutôt que des puces, la liste des
/// parcelles pouvant être longue.
class _FiltresParcelleOrgane extends StatelessWidget {
  const _FiltresParcelleOrgane({
    required this.parcelles,
    required this.organes,
    required this.parcelleId,
    required this.organe,
    required this.onParcelle,
    required this.onOrgane,
  });

  final List<ParcelleLocal> parcelles;
  final List<Organe> organes;
  final int? parcelleId;
  final Organe? organe;
  final ValueChanged<int?> onParcelle;
  final ValueChanged<Organe?> onOrgane;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final nomParcelle = switch (parcelleId) {
      null => loc.journalPlotAll,
      sansParcelle => loc.journalPlotNone,
      final id => parcelles.where((p) => p.id == id).firstOrNull?.nomParcelle ?? loc.journalPlotAll,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          if (parcelles.isNotEmpty)
            _MenuFiltre<int?>(
              icone: Icons.map_outlined,
              libelle: nomParcelle,
              actif: parcelleId != null,
              onSelected: onParcelle,
              options: [
                (null, loc.journalPlotAll),
                for (final parcelle in parcelles) (parcelle.id, parcelle.nomParcelle),
                (sansParcelle, loc.journalPlotNone),
              ],
            ),
          if (organes.length > 1)
            _MenuFiltre<Organe?>(
              icone: Icons.eco_outlined,
              libelle: organe?.label(loc) ?? loc.journalOrganAll,
              actif: organe != null,
              onSelected: onOrgane,
              options: [
                (null, loc.journalOrganAll),
                for (final option in organes) (option, option.label(loc)),
              ],
            ),
        ],
      ),
    );
  }
}

class _MenuFiltre<T> extends StatelessWidget {
  const _MenuFiltre({
    required this.icone,
    required this.libelle,
    required this.actif,
    required this.options,
    required this.onSelected,
  });

  final IconData icone;
  final String libelle;
  final bool actif;
  final List<(T, String)> options;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    // Un PopupMenuButton ne sait pas renvoyer null : on passe par l'index.
    return PopupMenuButton<int>(
      onSelected: (index) => onSelected(options[index].$1),
      itemBuilder: (context) => [
        for (var i = 0; i < options.length; i++)
          PopupMenuItem(value: i, child: Text(options[i].$2)),
      ],
      child: Chip(
        avatar: Icon(icone, size: 18, color: actif ? AppColors.primary : AppColors.textSecondary),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(libelle, overflow: TextOverflow.ellipsis),
            ),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
        backgroundColor: actif ? AppColors.primaryLight : null,
      ),
    );
  }
}

/// Filtres réellement appliqués à l'historique (tâche P1.10).
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final DiagnosticFilter selected;
  final ValueChanged<DiagnosticFilter> onSelected;

  String _label(DiagnosticFilter filter, AppLocalizations loc) => switch (filter) {
        DiagnosticFilter.all => loc.journalFilterAll,
        DiagnosticFilter.lastSevenDays => loc.journalFilterLastSevenDays,
        DiagnosticFilter.severe => loc.journalFilterSevere,
        DiagnosticFilter.healthy => loc.journalFilterHealthy,
      };

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    // Wrap plutôt qu'un défilement horizontal : aucun filtre n'est caché hors écran.
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          for (final filter in DiagnosticFilter.values)
            ChoiceChip(
              label: Text(_label(filter, loc)),
              selected: filter == selected,
              onSelected: (_) => onSelected(filter),
            ),
        ],
      ),
    );
  }
}

class _ResultatCard extends StatelessWidget {
  const _ResultatCard({required this.resultat});

  final ResultatScan resultat;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final info = resultat.ficheId == null ? null : DiseaseCatalog.of(resultat.ficheId!);
    final severity = DeclaredSeverity.fromCode(resultat.graviteDeclaree);

    // La couleur suit la part de parcelle déclarée par l'agriculteur,
    // jamais la confiance du modèle (tâche P1.3).
    final Color statusColor = resultat.estSain
        ? AppColors.severityLow
        : switch (severity) {
            DeclaredSeverity.quelquesPlants => AppColors.severityLow,
            DeclaredSeverity.moinsDunTiers => AppColors.severityMedium,
            DeclaredSeverity.plusDunTiers => AppColors.severityHigh,
            null => AppColors.textSecondary,
          };
    final String statusText = resultat.estSain
        ? loc.journalStatusHealthy
        : declaredSeverityLabel(resultat.graviteDeclaree, loc);
    final IconData statusIcon = resultat.estSain
        ? Icons.check_circle_outline
        : (severity == null ? Icons.help_outline : Icons.warning_amber_outlined);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
        onTap: () => context.push(AppRoutes.scanDetailPath(resultat.sessionId)),
        child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              clipBehavior: Clip.antiAlias,
              child: resultat.imagePath != null && File(resultat.imagePath!).existsSync()
                  ? Image.file(File(resultat.imagePath!), fit: BoxFit.cover)
                  : const Icon(Icons.image_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomResultat(resultat, loc),
                    style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (info != null && info.scientificName.isNotEmpty)
                    Text(
                      info.scientificName,
                      style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                    ),
                  if (resultat.organes.isNotEmpty)
                    Text(
                      resultat.organes.map((organe) => organe.label(loc)).join(' · '),
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  // Une piste du modèle n'est pas un diagnostic (P1.2).
                  if (!resultat.estSain && !resultat.estConfirme)
                    Text(
                      loc.journalStatusToConfirm,
                      style: AppTypography.caption.copyWith(
                          color: AppColors.severityMedium, fontWeight: FontWeight.w600),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 12),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            statusText,
                            style: AppTypography.caption
                                .copyWith(color: statusColor, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('dd MMM').format(resultat.date),
                  style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                Text(
                  DateFormat('yyyy').format(resultat.date),
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary.withAlpha(150)),
                ),
                if (resultat.nbPhotos > 1)
                  Text(
                    loc.journalPhotoCount(resultat.nbPhotos),
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
      ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 80, color: AppColors.primaryLight),
          const SizedBox(height: AppSpacing.md),
          Text(loc.journalHistoryEmptyTitle, style: AppTypography.headlineMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text(loc.journalHistoryEmptyDescription, style: AppTypography.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(loc.journalStartDiagnosis),
          ),
        ],
      ),
    );
  }
}
