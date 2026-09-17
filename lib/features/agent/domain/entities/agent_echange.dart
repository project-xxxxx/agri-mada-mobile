// Échanges avec l'agent de conseil du serveur (ADR-012).

/// Un échange tel que le serveur l'a signé : il est renvoyé à l'identique au
/// tour suivant, sans quoi le serveur refuse l'historique.
class EchangeSigne {
  const EchangeSigne({
    required this.question,
    required this.reponse,
    required this.emisLe,
    required this.signature,
  });

  final String question;
  final String reponse;

  /// Horodatage renvoyé par le serveur, gardé tel quel : il est signé.
  final String emisLe;
  final String signature;

  factory EchangeSigne.fromJson(Map<String, dynamic> json) => EchangeSigne(
        question: json['question'] as String,
        reponse: json['reponse'] as String,
        emisLe: json['emis_le'] as String,
        signature: json['signature'] as String,
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        'reponse': reponse,
        'emis_le': emisLe,
        'signature': signature,
      };
}

class FicheAgent {
  const FicheAgent({
    required this.id,
    required this.nomFr,
    this.nomMg,
    required this.statutValidation,
  });

  final String id;
  final String nomFr;
  final String? nomMg;
  final String statutValidation;

  String nom({required bool enMalgache}) => enMalgache ? (nomMg ?? nomFr) : nomFr;

  factory FicheAgent.fromJson(Map<String, dynamic> json) => FicheAgent(
        id: json['id'] as String,
        nomFr: json['nom_fr'] as String,
        nomMg: json['nom_mg'] as String?,
        statutValidation: json['statut_validation'] as String,
      );
}

class AvertissementAgent {
  const AvertissementAgent({required this.code, required this.message});

  final String code;
  final String message;

  factory AvertissementAgent.fromJson(Map<String, dynamic> json) => AvertissementAgent(
        code: json['code'] as String,
        message: json['message'] as String,
      );
}

/// Ce qui a produit la réponse ; seul [repondu] vient librement du modèle.
enum IssueAgent {
  repondu('repondu'),
  horsFiches('hors_fiches'),
  refusProduit('refus_produit'),
  repliSecurite('repli_securite'),
  urgenceSante('urgence_sante'),
  refusInjection('refus_injection'),
  salutation('salutation'),
  inconnue('');

  const IssueAgent(this.code);

  final String code;

  static IssueAgent depuisCode(String code) =>
      values.firstWhere((issue) => issue.code == code, orElse: () => inconnue);
}

class ReponseAgent {
  const ReponseAgent({
    required this.issue,
    required this.reponse,
    required this.fiches,
    required this.sessionsConsultees,
    required this.avertissements,
    required this.orienterTechnicien,
    required this.motifsTechnicien,
    required this.echange,
    this.questionsRestantes,
  });

  final IssueAgent issue;
  final String reponse;
  final List<FicheAgent> fiches;
  final List<int> sessionsConsultees;
  final List<AvertissementAgent> avertissements;
  final bool orienterTechnicien;
  final List<String> motifsTechnicien;
  final EchangeSigne echange;

  /// null quand la réponse n'a pas consommé de question (réponse fixe).
  final int? questionsRestantes;

  factory ReponseAgent.fromJson(Map<String, dynamic> json) => ReponseAgent(
        issue: IssueAgent.depuisCode(json['issue'] as String),
        reponse: json['reponse'] as String,
        fiches: [
          for (final fiche in json['fiches'] as List<dynamic>)
            FicheAgent.fromJson(fiche as Map<String, dynamic>),
        ],
        sessionsConsultees: (json['sessions_consultees'] as List<dynamic>).cast<int>(),
        avertissements: [
          for (final avertissement in json['avertissements'] as List<dynamic>)
            AvertissementAgent.fromJson(avertissement as Map<String, dynamic>),
        ],
        orienterTechnicien: json['orienter_technicien'] as bool,
        motifsTechnicien: (json['motifs_technicien'] as List<dynamic>).cast<String>(),
        echange: EchangeSigne.fromJson(json['echange'] as Map<String, dynamic>),
        questionsRestantes: json['questions_restantes'] as int?,
      );
}
