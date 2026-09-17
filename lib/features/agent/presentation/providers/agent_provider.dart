// État de la conversation avec le conseiller (ADR-012).

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../../core/sync/providers/sync_provider.dart';
import '../../../../core/utils/client_uuid.dart';
import '../../../auth/presentation/providers/session_provider.dart';
import '../../data/agent_remote_datasource.dart';
import '../../domain/entities/agent_echange.dart';

/// Même valeur que AGENT_CONSERVATION_JOURS côté serveur : c'est ce que
/// l'utilisateur accepte en donnant son accord.
const int dureeConservationJours = 90;

/// Nombre d'échanges renvoyés au serveur, qui en refuse davantage.
const int maxEchangesHistorique = 6;

class AccordConseillerNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.read(sessionServiceProvider).isAgentConsentGiven();

  Future<void> accepter() async {
    await ref.read(sessionServiceProvider).setAgentConsent(true);
    state = const AsyncData(true);
  }

  Future<void> retirer() async {
    await ref.read(sessionServiceProvider).setAgentConsent(false);
    state = const AsyncData(false);
  }
}

final accordConseillerProvider =
    AsyncNotifierProvider<AccordConseillerNotifier, bool>(AccordConseillerNotifier.new);

/// Le serveur ne voit que les scans synchronisés : on envoie ceux en attente
/// avant chaque question, sans jamais bloquer la question si l'envoi échoue.
final synchroniserAvantConseilProvider = Provider<Future<void> Function()>(
  (ref) => () async {
    try {
      await ref
          .read(syncNotifierProvider.notifier)
          .syncData()
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  },
);

sealed class ElementConversation {
  const ElementConversation();
}

class QuestionAgriculteur extends ElementConversation {
  const QuestionAgriculteur(this.texte);

  final String texte;
}

class ReponseConseiller extends ElementConversation {
  const ReponseConseiller(this.reponse);

  final ReponseAgent reponse;
}

class ConversationConseillerState {
  const ConversationConseillerState({
    required this.conversationId,
    this.elements = const [],
    this.envoiEnCours = false,
    this.erreur,
    this.questionNonEnvoyee,
    this.questionsRestantes,
  });

  final String conversationId;
  final List<ElementConversation> elements;
  final bool envoiEnCours;
  final AgentErreur? erreur;

  /// Question à remettre dans le champ de saisie après un échec d'envoi.
  final String? questionNonEnvoyee;
  final int? questionsRestantes;

  /// Échanges signés à renvoyer, du plus ancien au plus récent.
  List<EchangeSigne> get historique {
    final echanges = [
      for (final element in elements)
        if (element is ReponseConseiller) element.reponse.echange,
    ];
    return echanges.length <= maxEchangesHistorique
        ? echanges
        : echanges.sublist(echanges.length - maxEchangesHistorique);
  }

  ConversationConseillerState copyWith({
    List<ElementConversation>? elements,
    bool? envoiEnCours,
    AgentErreur? erreur,
    String? questionNonEnvoyee,
    int? questionsRestantes,
    bool effacerErreur = false,
  }) {
    return ConversationConseillerState(
      conversationId: conversationId,
      elements: elements ?? this.elements,
      envoiEnCours: envoiEnCours ?? this.envoiEnCours,
      erreur: effacerErreur ? null : (erreur ?? this.erreur),
      questionNonEnvoyee: effacerErreur ? null : (questionNonEnvoyee ?? this.questionNonEnvoyee),
      questionsRestantes: questionsRestantes ?? this.questionsRestantes,
    );
  }
}

class ConversationConseillerNotifier extends Notifier<ConversationConseillerState> {
  @override
  ConversationConseillerState build() =>
      ConversationConseillerState(conversationId: generateClientUuid());

  Future<void> envoyer(String question) async {
    final texte = question.trim();
    if (texte.length < 3 || state.envoiEnCours) return;

    final historique = state.historique;
    final langue = ref.read(localeProvider).languageCode == 'mg' ? 'mg' : 'fr';
    state = state.copyWith(
      elements: [...state.elements, QuestionAgriculteur(texte)],
      envoiEnCours: true,
      effacerErreur: true,
    );

    await ref.read(synchroniserAvantConseilProvider)();

    try {
      final reponse = await ref.read(agentRemoteDatasourceProvider).envoyer(
            question: texte,
            langue: langue,
            conversationId: state.conversationId,
            historique: historique,
          );
      state = state.copyWith(
        elements: [...state.elements, ReponseConseiller(reponse)],
        envoiEnCours: false,
        questionsRestantes: reponse.questionsRestantes,
      );
    } on AgentException catch (exception) {
      if (exception.erreur == AgentErreur.historiqueInvalide) {
        // Le serveur ne reconnaît plus l'historique : on repart de zéro.
        state = ConversationConseillerState(
          conversationId: generateClientUuid(),
          erreur: exception.erreur,
          questionNonEnvoyee: texte,
          questionsRestantes: state.questionsRestantes,
        );
        return;
      }
      state = state.copyWith(
        elements: [...state.elements]..removeLast(),
        envoiEnCours: false,
        erreur: exception.erreur,
        questionNonEnvoyee: texte,
      );
      if (exception.erreur == AgentErreur.consentementRequis) {
        unawaited(ref.read(accordConseillerProvider.notifier).retirer());
      }
    }
  }

  void nouvelleConversation() {
    state = ConversationConseillerState(
      conversationId: generateClientUuid(),
      questionsRestantes: state.questionsRestantes,
    );
  }

  void oublierErreur() {
    state = state.copyWith(effacerErreur: true);
  }
}

final conversationConseillerProvider =
    NotifierProvider<ConversationConseillerNotifier, ConversationConseillerState>(
  ConversationConseillerNotifier.new,
);
