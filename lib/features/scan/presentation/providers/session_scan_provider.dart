// Conduite d'une session de scan (tâches P2.1 à P2.4, P2.6).
//
// Le notifier enchaîne : choix de l'organe, photos contrôlées, questions, puis
// fusion. Chaque photo acceptée devient une observation enregistrée tout de
// suite : si l'app est fermée en route, rien n'est perdu.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ai/diagnosis_certainty.dart';
import '../../../../core/ai/diagnosis_fusion.dart';
import '../../../../core/ai/image_quality.dart';
import '../../../../core/ai/photo_check_service.dart';
import '../../../../core/providers/tflite_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/session_local_repository.dart';
import '../../domain/entities/organe.dart';
import '../../domain/questionnaire.dart';

/// Nombre de photos acceptées par organe (« 1 à 3 photos » du parcours P2).
const int photosMaxParOrgane = 3;

/// Contrôle de qualité utilisé par le notifier ; remplacé dans les tests.
final photoCheckerProvider = Provider<Future<ImageQualityReport?> Function(File)>(
  (ref) => verifierPhoto,
);

final sessionRepositoryProvider = Provider<SessionLocalRepository>(
  (ref) => SessionLocalRepository(),
);

class PhotoObservee {
  const PhotoObservee({
    required this.organe,
    required this.chemin,
    required this.qualite,
    this.scores = const <ScoredLabel>[],
  });

  final Organe organe;
  final String chemin;
  final ImageQualityReport qualite;
  final List<ScoredLabel> scores;
}

enum EtapeScan { choixOrgane, capture, questions, resultat }

class ScanSessionState {
  const ScanSessionState({
    this.etape = EtapeScan.choixOrgane,
    this.organe,
    this.sequence = const <Organe>[],
    this.indexSequence = 0,
    this.sessionId,
    this.parcelleLocalId,
    this.photos = const <PhotoObservee>[],
    this.reponsesParOrgane = const <String, Map<String, String>>{},
    this.fusion,
    this.enCours = false,
    this.dernierRefus,
  });

  final EtapeScan etape;
  final Organe? organe;

  /// Séquence guidée déclenchée par « Je ne sais pas » (P2.1).
  final List<Organe> sequence;
  final int indexSequence;

  final int? sessionId;

  /// null tant que la session n'est rattachée à aucune parcelle (P2.6).
  final int? parcelleLocalId;

  final List<PhotoObservee> photos;
  final Map<String, Map<String, String>> reponsesParOrgane;
  final FusedDiagnosis? fusion;
  final bool enCours;

  /// Renseigné quand la dernière photo a été refusée (P2.2).
  final ImageQualityIssue? dernierRefus;

  List<PhotoObservee> photosDe(Organe organe) =>
      photos.where((photo) => photo.organe == organe).toList();

  Map<String, String> reponsesDe(Organe organe) =>
      reponsesParOrgane[organe.code] ?? const {};

  bool get peutAjouterPhoto =>
      organe != null && photosDe(organe!).length < photosMaxParOrgane;

  bool get estDernierOrgane => sequence.isEmpty || indexSequence >= sequence.length - 1;

  ScanSessionState copyWith({
    EtapeScan? etape,
    Organe? organe,
    List<Organe>? sequence,
    int? indexSequence,
    int? sessionId,
    int? parcelleLocalId,
    List<PhotoObservee>? photos,
    Map<String, Map<String, String>>? reponsesParOrgane,
    FusedDiagnosis? fusion,
    bool? enCours,
    ImageQualityIssue? dernierRefus,
    bool effacerRefus = false,
  }) =>
      ScanSessionState(
        etape: etape ?? this.etape,
        organe: organe ?? this.organe,
        sequence: sequence ?? this.sequence,
        indexSequence: indexSequence ?? this.indexSequence,
        sessionId: sessionId ?? this.sessionId,
        parcelleLocalId: parcelleLocalId ?? this.parcelleLocalId,
        photos: photos ?? this.photos,
        reponsesParOrgane: reponsesParOrgane ?? this.reponsesParOrgane,
        fusion: fusion ?? this.fusion,
        enCours: enCours ?? this.enCours,
        dernierRefus: effacerRefus ? null : (dernierRefus ?? this.dernierRefus),
      );
}

class ScanSessionNotifier extends StateNotifier<ScanSessionState> {
  ScanSessionNotifier(this._ref) : super(const ScanSessionState());

  final Ref _ref;

  SessionLocalRepository get _repository => _ref.read(sessionRepositoryProvider);

  /// Ouvre une session. [guidee] déclenche la séquence plante entière, feuille,
  /// collet proposée quand l'agriculteur ne sait pas quoi regarder (P2.1).
  /// La parcelle est facultative (P2.6).
  Future<void> demarrer({
    Organe? organe,
    bool guidee = false,
    int? parcelleLocalId,
    String? ecosysteme,
    String? stade,
  }) async {
    final sequence = guidee ? guidedOrganSequence : const <Organe>[];
    final premier = guidee ? guidedOrganSequence.first : organe;
    if (premier == null) return;

    final session = await _repository.ouvrirSession(
      parcelleLocalId: parcelleLocalId,
      ecosysteme: ecosysteme,
      stade: stade,
    );

    state = ScanSessionState(
      etape: EtapeScan.capture,
      organe: premier,
      sequence: sequence,
      sessionId: session.id,
      parcelleLocalId: parcelleLocalId,
    );
  }

  /// Contrôle la photo, l'analyse si l'organe a un modèle, puis l'enregistre.
  /// Retourne false quand la photo est refusée : la consigne est dans
  /// [ScanSessionState.dernierRefus].
  Future<bool> ajouterPhoto(File photo) async {
    final organe = state.organe;
    final sessionId = state.sessionId;
    if (organe == null || sessionId == null || !state.peutAjouterPhoto) return false;

    state = state.copyWith(enCours: true, effacerRefus: true);

    final rapport = await _ref.read(photoCheckerProvider)(photo);
    if (rapport == null || !rapport.acceptable) {
      state = state.copyWith(
        enCours: false,
        dernierRefus: rapport?.probleme ?? ImageQualityIssue.flou,
      );
      return false;
    }

    final scores = await _analyser(photo, organe);
    await _repository.ajouterObservation(
      sessionId: sessionId,
      organe: organe,
      imagePath: photo.path,
      topK: scores,
      qualite: rapport,
    );

    state = state.copyWith(
      enCours: false,
      effacerRefus: true,
      photos: [
        ...state.photos,
        PhotoObservee(
          organe: organe,
          chemin: photo.path,
          qualite: rapport,
          scores: scores,
        ),
      ],
    );
    return true;
  }

  /// Passe aux questions de l'organe en cours.
  void passerAuxQuestions() {
    if (state.organe == null || state.photos.isEmpty) return;
    state = state.copyWith(etape: EtapeScan.questions, effacerRefus: true);
  }

  void repondre(String questionId, String optionId) {
    final organe = state.organe;
    if (organe == null) return;

    final reponses = {
      ...state.reponsesParOrgane,
      organe.code: {...state.reponsesDe(organe), questionId: optionId},
    };
    state = state.copyWith(reponsesParOrgane: reponses);
  }

  /// Termine l'organe en cours : enregistre ses réponses, puis passe à l'organe
  /// suivant de la séquence guidée, ou au résultat fusionné.
  Future<void> validerQuestions({String? graviteDeclaree}) async {
    final organe = state.organe;
    final sessionId = state.sessionId;
    if (organe == null || sessionId == null) return;

    await _repository.enregistrerReponses(
      sessionId: sessionId,
      organe: organe,
      reponses: state.reponsesDe(organe),
    );

    if (!state.estDernierOrgane) {
      final suivant = state.indexSequence + 1;
      state = state.copyWith(
        etape: EtapeScan.capture,
        organe: state.sequence[suivant],
        indexSequence: suivant,
        effacerRefus: true,
      );
      return;
    }

    await _fusionner(graviteDeclaree: graviteDeclaree);
  }

  /// Enregistre la part de parcelle déclarée après coup (P1.3).
  Future<void> declarerGravite(String code) async {
    final sessionId = state.sessionId;
    final fusion = state.fusion;
    if (sessionId == null || fusion == null) return;

    await _repository.enregistrerResultat(
      sessionId: sessionId,
      fusion: fusion,
      graviteDeclaree: code,
    );
  }

  /// Rattache une session ouverte sans parcelle (P2.6).
  Future<void> rattacherParcelle(int parcelleLocalId) async {
    final sessionId = state.sessionId;
    if (sessionId == null) return;
    await _repository.rattacherParcelle(
      sessionId: sessionId,
      parcelleLocalId: parcelleLocalId,
    );
    state = state.copyWith(parcelleLocalId: parcelleLocalId);
  }

  void reset() => state = const ScanSessionState();

  Future<void> _fusionner({String? graviteDeclaree}) async {
    final sessionId = state.sessionId;
    if (sessionId == null) return;

    state = state.copyWith(enCours: true);

    final observations = <ObservationEvidence>[
      for (final organe in _organesObserves())
        ObservationEvidence(
          organe: organe,
          scores: _meilleursScores(organe),
          indices: ScanQuestionnaire.indices(organe, state.reponsesDe(organe)),
        ),
    ];

    final fusion = fuseObservations(observations);
    await _repository.enregistrerResultat(
      sessionId: sessionId,
      fusion: fusion,
      graviteDeclaree: graviteDeclaree,
    );

    state = state.copyWith(
      etape: EtapeScan.resultat,
      fusion: fusion,
      enCours: false,
    );
  }

  List<Organe> _organesObserves() {
    final organes = <Organe>[];
    for (final photo in state.photos) {
      if (!organes.contains(photo.organe)) organes.add(photo.organe);
    }
    return organes;
  }

  /// Une seule entrée de modèle par organe : la photo la plus nette.
  List<ScoredLabel> _meilleursScores(Organe organe) {
    final photos = state.photosDe(organe).where((p) => p.scores.isNotEmpty).toList();
    if (photos.isEmpty) return const [];
    photos.sort((a, b) => b.qualite.nettete.compareTo(a.qualite.nettete));
    return photos.first.scores;
  }

  Future<List<ScoredLabel>> _analyser(File photo, Organe organe) async {
    if (!organe.usesModel) return const [];

    final tflite = _ref.read(tfliteServiceProvider);
    if (!tflite.isReady) return const [];

    try {
      final resultat = await tflite.analyzeImage(photo);
      return resultat.classement;
    } catch (e, st) {
      AppLogger.error('Analyse de la photo impossible', error: e, stackTrace: st);
      return const [];
    }
  }
}

final scanSessionProvider =
    StateNotifierProvider<ScanSessionNotifier, ScanSessionState>(
  (ref) => ScanSessionNotifier(ref),
);
