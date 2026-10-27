// Bulles de la conversation avec le conseiller (ADR-012).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/agent_remote_datasource.dart';
import '../../domain/entities/agent_echange.dart';

/// Avertissement traduit par l'app à partir de son code ; le message du
/// serveur sert de repli pour un code que l'app ne connaît pas encore.
String avertissementLocalise(AvertissementAgent avertissement, AppLocalizations loc) {
  return switch (avertissement.code) {
    'reponse_automatique' => loc.agentWarningAutomatic,
    'fiches_brouillon' => loc.agentWarningDraft,
    'modele_experimental' => loc.agentWarningExperimental,
    'malgache_non_relu' => loc.agentWarningMalagasy,
    _ => avertissement.message,
  };
}

/// Motifs d'orientation vers un technicien, du plus au moins pressant.
String? motifPrincipal(List<String> motifs, AppLocalizations loc) {
  const ordre = [
    'maladie_a_signaler',
    'gravite_elevee',
    'demande_traitement',
    'scan_sans_nom',
    'piste_a_confirmer',
    'hors_fiches',
  ];
  for (final code in ordre) {
    if (!motifs.contains(code)) continue;
    return switch (code) {
      'maladie_a_signaler' => loc.agentReasonReport,
      'gravite_elevee' => loc.agentReasonSevere,
      'demande_traitement' => loc.agentReasonTreatment,
      'scan_sans_nom' => loc.agentReasonUnnamedScan,
      'piste_a_confirmer' => loc.agentReasonScanToConfirm,
      _ => loc.agentReasonOutOfScope,
    };
  }
  return null;
}

String messageErreur(AgentErreur erreur, AppLocalizations loc) {
  return switch (erreur) {
    AgentErreur.horsLigne => loc.agentErrorOffline,
    AgentErreur.quotaAtteint => loc.agentErrorQuota,
    AgentErreur.indisponible => loc.agentErrorUnavailable,
    AgentErreur.sessionExpiree => loc.agentErrorSession,
    AgentErreur.consentementRequis => loc.agentErrorConsent,
    AgentErreur.historiqueInvalide => loc.agentErrorHistoryReset,
    AgentErreur.inconnue => loc.agentErrorGeneric,
  };
}

class BulleQuestion extends StatelessWidget {
  const BulleQuestion({super.key, required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xl),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Text(texte, style: AppTypography.bodyMedium),
      ),
    );
  }
}

class BulleReponse extends StatelessWidget {
  const BulleReponse({super.key, required this.reponse, required this.question});

  final ReponseAgent reponse;
  final String question;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final enMalgache = loc.localeName.startsWith('mg');
    final urgence = reponse.issue == IssueAgent.urgenceSante;
    final motif = motifPrincipal(reponse.motifsTechnicien, loc);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.88),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm, right: AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: urgence ? AppColors.severityHigh.withAlpha(30) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: urgence ? AppColors.severityHigh : AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (urgence)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.severityHigh),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      loc.agentUrgentTitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.severityHigh,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            Text(reponse.reponse, style: AppTypography.bodyMedium),
            if (reponse.fiches.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                loc.agentFichesTitle,
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final fiche in reponse.fiches)
                    Chip(
                      avatar: const Icon(Icons.menu_book_outlined, size: 16, color: AppColors.primary),
                      label: Text(fiche.nom(enMalgache: enMalgache), style: AppTypography.caption),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: AppColors.primaryLight,
                      side: BorderSide.none,
                    ),
                ],
              ),
            ],
            for (final avertissement in reponse.avertissements)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: AppColors.severityMedium),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        avertissementLocalise(avertissement, loc),
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            if (reponse.orienterTechnicien) ...[
              const SizedBox(height: AppSpacing.sm),
              if (motif != null)
                Text(
                  motif,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.severityMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: AppSpacing.xs),
              OutlinedButton.icon(
                onPressed: () => _partager(loc, enMalgache),
                icon: const Icon(Icons.support_agent),
                label: Text(loc.agentAskTechnician),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _partager(AppLocalizations loc, bool enMalgache) {
    final texte = [
      loc.agentTechnicianShareIntro,
      loc.agentShareQuestion(question),
      loc.agentShareAnswer(reponse.reponse),
      if (reponse.fiches.isNotEmpty)
        loc.scanAskTechnicianCandidates(
          reponse.fiches.map((fiche) => fiche.nom(enMalgache: enMalgache)).join(', '),
        ),
      loc.scanShareDate(DateFormat('dd/MM/yyyy').format(DateTime.now())),
    ].join('\n');
    return Share.share(texte);
  }
}

class BulleAttente extends StatelessWidget {
  const BulleAttente({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              loc.agentThinking,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
