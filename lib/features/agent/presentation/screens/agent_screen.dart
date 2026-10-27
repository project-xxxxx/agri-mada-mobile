// Écran du conseiller : conversation avec l'agent du serveur (ADR-012).
//
// L'agent consulte les fiches, les parcelles et les scans synchronisés. Rien
// n'est envoyé avant l'accord de l'utilisateur sur la conservation des échanges.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/agent_remote_datasource.dart';
import '../providers/agent_provider.dart';
import '../widgets/agent_bulles.dart';

class AgentScreen extends ConsumerWidget {
  const AgentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final accord = ref.watch(accordConseillerProvider);
    final accepte = accord.valueOrNull ?? false;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.go(AppRoutes.home),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.agentTitle,
              style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              loc.agentSubtitle,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          if (accepte) ...[
            IconButton(
              icon: const Icon(Icons.add_comment_outlined),
              tooltip: loc.agentNewConversation,
              onPressed: () => ref.read(conversationConseillerProvider.notifier).nouvelleConversation(),
            ),
            _MenuConfidentialite(),
          ],
        ],
      ),
      body: accord.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const _DemandeAccord(),
        data: (accepte) => accepte ? const _Conversation() : const _DemandeAccord(),
      ),
    );
  }
}

enum _ActionConfidentialite { effacer, retirer }

class _MenuConfidentialite extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    return PopupMenuButton<_ActionConfidentialite>(
      onSelected: (action) => _executer(context, ref, loc, action),
      itemBuilder: (_) => [
        PopupMenuItem(value: _ActionConfidentialite.effacer, child: Text(loc.agentDeleteHistory)),
        PopupMenuItem(value: _ActionConfidentialite.retirer, child: Text(loc.agentWithdrawConsent)),
      ],
    );
  }

  Future<void> _executer(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations loc,
    _ActionConfidentialite action,
  ) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogue) => AlertDialog(
        content: Text(loc.agentDeleteHistoryConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogue).pop(false), child: Text(loc.commonCancel)),
          TextButton(onPressed: () => Navigator.of(dialogue).pop(true), child: Text(loc.agentConfirmDelete)),
        ],
      ),
    );
    if (confirme != true || !context.mounted) return;

    final messager = ScaffoldMessenger.of(context);
    try {
      final supprimees = await ref.read(agentRemoteDatasourceProvider).effacerMesEchanges();
      messager.showSnackBar(SnackBar(content: Text(loc.agentDeleteHistoryDone(supprimees))));
    } on AgentException catch (exception) {
      messager.showSnackBar(SnackBar(content: Text(messageErreur(exception.erreur, loc))));
      return;
    }
    ref.read(conversationConseillerProvider.notifier).nouvelleConversation();
    if (action == _ActionConfidentialite.retirer) {
      await ref.read(accordConseillerProvider.notifier).retirer();
    }
  }
}

class _DemandeAccord extends ConsumerWidget {
  const _DemandeAccord();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const Icon(Icons.privacy_tip_outlined, size: 48, color: AppColors.primary),
        const SizedBox(height: AppSpacing.md),
        Text(loc.agentConsentTitle, style: AppTypography.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.md),
        Text(loc.agentConsentBody(dureeConservationJours), style: AppTypography.bodyMedium),
        const SizedBox(height: AppSpacing.md),
        Text(
          loc.agentDisclaimer,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () => ref.read(accordConseillerProvider.notifier).accepter(),
          child: Text(loc.agentConsentAccept),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => context.go(AppRoutes.home),
          child: Text(loc.agentConsentDecline),
        ),
      ],
    );
  }
}

class _Conversation extends ConsumerStatefulWidget {
  const _Conversation();

  @override
  ConsumerState<_Conversation> createState() => _ConversationState();
}

class _ConversationState extends ConsumerState<_Conversation> {
  final _saisie = TextEditingController();
  final _defilement = ScrollController();

  @override
  void dispose() {
    _saisie.dispose();
    _defilement.dispose();
    super.dispose();
  }

  void _envoyer(String question) {
    if (question.trim().length < 3) return;
    _saisie.clear();
    ref.read(conversationConseillerProvider.notifier).envoyer(question);
  }

  void _descendre() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_defilement.hasClients) {
        _defilement.animateTo(
          _defilement.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final etat = ref.watch(conversationConseillerProvider);
    // Réseau inconnu (plugin absent, tests) : on laisse essayer plutôt que bloquer.
    final horsLigne = ref.watch(isOnlineProvider).valueOrNull == false;

    ref.listen(conversationConseillerProvider, (avant, apres) {
      if ((avant?.elements.length ?? 0) != apres.elements.length || apres.envoiEnCours) {
        _descendre();
      }
      final aRemettre = apres.questionNonEnvoyee;
      if (aRemettre != null && aRemettre != avant?.questionNonEnvoyee && _saisie.text.isEmpty) {
        _saisie.text = aRemettre;
      }
    });

    return Column(
      children: [
        _Bandeau(texte: loc.agentDisclaimer, icone: Icons.info_outline, couleur: AppColors.primary),
        if (horsLigne)
          _Bandeau(texte: loc.agentOffline, icone: Icons.wifi_off, couleur: AppColors.severityMedium),
        Expanded(
          child: etat.elements.isEmpty && !etat.envoiEnCours
              ? _Suggestions(onChoisir: horsLigne ? null : _envoyer)
              : ListView(
                  controller: _defilement,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    for (var i = 0; i < etat.elements.length; i++)
                      switch (etat.elements[i]) {
                        QuestionAgriculteur(:final texte) => BulleQuestion(texte: texte),
                        ReponseConseiller(:final reponse) => BulleReponse(
                            reponse: reponse,
                            question: reponse.echange.question,
                          ),
                      },
                    if (etat.envoiEnCours) const BulleAttente(),
                  ],
                ),
        ),
        if (etat.erreur != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              messageErreur(etat.erreur!, loc),
              style: AppTypography.bodySmall.copyWith(color: AppColors.severityHigh),
            ),
          ),
        if (etat.questionsRestantes != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              loc.agentQuotaRemaining(etat.questionsRestantes!),
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.xs, AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('agent_saisie'),
                    controller: _saisie,
                    enabled: !horsLigne,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 500,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _envoyer,
                    decoration: InputDecoration(
                      hintText: loc.agentInputHint,
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: _saisie,
                  builder: (context, valeur, _) => IconButton(
                    key: const Key('agent_envoyer'),
                    icon: const Icon(Icons.send),
                    color: AppColors.primary,
                    tooltip: loc.agentSend,
                    onPressed: horsLigne || etat.envoiEnCours || valeur.text.trim().length < 3
                        ? null
                        : () => _envoyer(_saisie.text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onChoisir});

  final void Function(String)? onChoisir;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final suggestions = [
      loc.agentSuggestionScan,
      loc.agentSuggestionPrevention,
      loc.agentSuggestionSymptoms,
    ];
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const SizedBox(height: AppSpacing.lg),
        const Icon(Icons.forum_outlined, size: 48, color: AppColors.primary),
        const SizedBox(height: AppSpacing.sm),
        Text(loc.agentEmptyTitle, style: AppTypography.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.md),
        for (final suggestion in suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: OutlinedButton(
              onPressed: onChoisir == null ? null : () => onChoisir!(suggestion),
              child: Text(suggestion, textAlign: TextAlign.center),
            ),
          ),
      ],
    );
  }
}

class _Bandeau extends StatelessWidget {
  const _Bandeau({required this.texte, required this.icone, required this.couleur});

  final String texte;
  final IconData icone;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      color: couleur.withAlpha(30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 18, color: couleur),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(texte, style: AppTypography.caption.copyWith(color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
