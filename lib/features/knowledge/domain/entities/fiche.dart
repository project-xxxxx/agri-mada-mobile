// Fiche de connaissance (tâche P5.1/P5.3), chargée depuis
// assets/knowledge/fiches.json (généré par ml/scripts/generate_fiches.py).
//
// Toutes les fiches sont aujourd'hui au statut brouillon : voir
// knowledge/fiches/README.md et ADR-010. L'écran qui les affiche doit
// toujours le signaler (estBrouillon).

import '../../../scan/domain/entities/organe.dart';

class FicheNoms {
  const FicheNoms({
    required this.fr,
    this.mg,
    this.sci,
    this.autresNomsMg = const [],
  });

  final String fr;
  final String? mg;
  final String? sci;
  final List<String> autresNomsMg;

  factory FicheNoms.fromJson(Map<String, dynamic> json) => FicheNoms(
        fr: json['fr'] as String,
        mg: json['mg'] as String?,
        sci: json['sci'] as String?,
        autresNomsMg: (json['autres_noms_mg'] as List<dynamic>? ?? [])
            .cast<String>(),
      );
}

class FicheConfusion {
  const FicheConfusion({required this.ficheId, required this.questionFr, this.questionMg});

  final String ficheId;
  final String questionFr;

  /// null tant qu'un locuteur malgache n'a pas traduit la question.
  final String? questionMg;

  /// Question à afficher : le français sert de repli, plutôt qu'un texte
  /// d'attente montré à l'agriculteur (P5.3).
  String question({required bool enMalgache}) =>
      enMalgache ? (questionMg ?? questionFr) : questionFr;

  factory FicheConfusion.fromJson(Map<String, dynamic> json) => FicheConfusion(
        ficheId: json['fiche'] as String,
        questionFr: (json['question'] as Map<String, dynamic>)['fr'] as String,
        questionMg: (json['question'] as Map<String, dynamic>)['mg'] as String?,
      );
}

class FicheConditions {
  const FicheConditions({
    this.ecosystemes = const [],
    this.altitudeM = const [],
    this.facteurs = const [],
  });

  /// Codes irrigue / bas_fond / tanety_pluvial.
  final List<String> ecosystemes;
  final List<num> altitudeM;
  final List<String> facteurs;

  factory FicheConditions.fromJson(Map<String, dynamic> json) => FicheConditions(
        ecosystemes: (json['ecosystemes'] as List<dynamic>? ?? []).cast<String>(),
        altitudeM: (json['altitude_m'] as List<dynamic>? ?? []).cast<num>(),
        facteurs: (json['facteurs'] as List<dynamic>? ?? []).cast<String>(),
      );
}

class FicheSource {
  const FicheSource({required this.titre, this.url, this.org, this.fichier});

  final String titre;
  final String? url;
  final String? org;
  final String? fichier;

  factory FicheSource.fromJson(Map<String, dynamic> json) => FicheSource(
        titre: json['titre'] as String,
        url: json['url'] as String?,
        org: json['org'] as String?,
        fichier: json['fichier'] as String?,
      );
}

class Fiche {
  const Fiche({
    required this.id,
    required this.noms,
    required this.organes,
    required this.confusions,
    required this.conditions,
    required this.prevention,
    required this.luttechimiqueStatut,
    required this.sources,
    required this.statutValidation,
  });

  final String id;
  final FicheNoms noms;

  /// Symptômes par organe touché (une maladie multi-organe a plusieurs clés).
  final Map<Organe, List<String>> organes;
  final List<FicheConfusion> confusions;
  final FicheConditions conditions;
  final List<String> prevention;

  /// `a_completer_liste_DPV` (maladie/ravageur, liste officielle à venir) ou
  /// `sans_objet` (trouble abiotique, se corrige par la fertilisation).
  final String luttechimiqueStatut;
  final List<FicheSource> sources;

  /// `brouillon` ou `valide` : voir ADR-010, toujours divulgué à l'écran.
  final String statutValidation;

  bool get estBrouillon => statutValidation != 'valide';

  factory Fiche.fromJson(Map<String, dynamic> json) {
    final organesJson = json['organes'] as Map<String, dynamic>;
    return Fiche(
      id: json['id'] as String,
      noms: FicheNoms.fromJson(json['noms'] as Map<String, dynamic>),
      organes: {
        for (final entry in organesJson.entries)
          if (Organe.fromCode(entry.key) case final organe?)
            organe: (entry.value as List<dynamic>).cast<String>(),
      },
      confusions: (json['confusions'] as List<dynamic>? ?? [])
          .map((e) => FicheConfusion.fromJson(e as Map<String, dynamic>))
          .toList(),
      conditions: FicheConditions.fromJson(json['conditions'] as Map<String, dynamic>? ?? const {}),
      prevention: (json['prevention'] as List<dynamic>? ?? []).cast<String>(),
      luttechimiqueStatut: (json['lutte_chimique'] as Map<String, dynamic>)['statut'] as String,
      sources: (json['sources'] as List<dynamic>? ?? [])
          .map((e) => FicheSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      statutValidation: (json['validation'] as Map<String, dynamic>)['statut'] as String,
    );
  }
}
