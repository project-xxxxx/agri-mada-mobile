// Dépôt local des sessions de scan et de leurs observations (tâche P2.3).

import 'dart:convert';

import 'package:isar/isar.dart';

import '../../../../core/ai/diagnosis_certainty.dart';
import '../../../../core/ai/diagnosis_fusion.dart';
import '../../../../core/ai/image_quality.dart';
import '../../../../core/local_db/isar_service.dart';
import '../../../../core/local_db/models/diagnostic_session_local.dart';
import '../../../../core/local_db/models/observation_local.dart';
import '../../../../core/utils/client_uuid.dart';
import '../../../journal/domain/entities/resultat_scan.dart';
import '../../domain/entities/organe.dart';

class SessionLocalRepository {
  SessionLocalRepository({Isar? db}) : _dbOverride = db;

  final Isar? _dbOverride;
  Isar get _db => _dbOverride ?? IsarService.instance.db;

  /// Ouvre une session. La parcelle est facultative : on peut scanner avant
  /// d'avoir créé sa première parcelle (tâche P2.6).
  Future<DiagnosticSessionLocal> ouvrirSession({
    int? parcelleLocalId,
    String? ecosysteme,
    String? stade,
    DateTime? createdAt,
  }) async {
    final session = DiagnosticSessionLocal()
      ..clientUuid = generateClientUuid()
      ..parcelleLocalId = parcelleLocalId
      ..ecosysteme = ecosysteme
      ..stade = stade
      ..createdAt = createdAt ?? DateTime.now();

    await _db.writeTxn(() => _db.diagnosticSessionLocals.put(session));
    return session;
  }

  Future<ObservationLocal> ajouterObservation({
    required int sessionId,
    required Organe organe,
    required String imagePath,
    List<ScoredLabel> topK = const [],
    Map<String, String> reponses = const {},
    ImageQualityReport? qualite,
    DateTime? createdAt,
  }) async {
    final observation = ObservationLocal()
      ..clientUuid = generateClientUuid()
      ..sessionId = sessionId
      ..organeCode = organe.code
      ..imagePath = imagePath
      ..topK = topK.isEmpty ? null : encoderClassement(topK)
      ..reponses = reponses.isEmpty ? null : jsonEncode(reponses)
      ..qualiteNettete = qualite?.nettete
      ..qualiteLuminosite = qualite?.luminosite
      ..createdAt = createdAt ?? DateTime.now();

    await _db.writeTxn(() => _db.observationLocals.put(observation));
    return observation;
  }

  /// Enregistre le résultat fusionné. La fiche n'est retenue que si l'app sait
  /// la nommer (ADR-006) ; sinon la session part au technicien sans nom.
  Future<DiagnosticSessionLocal?> enregistrerResultat({
    required int sessionId,
    required FusedDiagnosis fusion,
    String? graviteDeclaree,
  }) async {
    final session = await _db.diagnosticSessionLocals.get(sessionId);
    if (session == null) return null;

    session
      ..resultatFicheId =
          fusion.nommable && fusion.classement.isNotEmpty ? fusion.classement.first.label : null
      ..certitude = fusion.certitude.name
      ..classement = fusion.classement.isEmpty ? null : encoderClassement(fusion.classement)
      ..graviteDeclaree = graviteDeclaree ?? session.graviteDeclaree
      ..isSynced = false;

    await _db.writeTxn(() => _db.diagnosticSessionLocals.put(session));
    return session;
  }

  /// Rattache après coup une session créée sans parcelle (tâche P2.6).
  Future<DiagnosticSessionLocal?> rattacherParcelle({
    required int sessionId,
    required int parcelleLocalId,
  }) async {
    final session = await _db.diagnosticSessionLocals.get(sessionId);
    if (session == null) return null;

    session
      ..parcelleLocalId = parcelleLocalId
      ..isSynced = false;
    await _db.writeTxn(() => _db.diagnosticSessionLocals.put(session));
    return session;
  }

  /// Attache les réponses du questionnaire aux photos de cet organe.
  Future<int> enregistrerReponses({
    required int sessionId,
    required Organe organe,
    required Map<String, String> reponses,
  }) async {
    final concernees = (await observations(sessionId))
        .where((observation) => observation.organeCode == organe.code)
        .toList();
    if (concernees.isEmpty) return 0;

    final json = jsonEncode(reponses);
    await _db.writeTxn(() async {
      for (final observation in concernees) {
        observation.reponses = json;
        await _db.observationLocals.put(observation);
      }
    });
    return concernees.length;
  }

  Future<List<ObservationLocal>> observations(int sessionId) =>
      _db.observationLocals.filter().sessionIdEqualTo(sessionId).findAll();

  Future<DiagnosticSessionLocal?> session(int sessionId) =>
      _db.diagnosticSessionLocals.get(sessionId);

  /// Historique, de la plus récente à la plus ancienne.
  Future<List<DiagnosticSessionLocal>> historique({int? parcelleLocalId}) async {
    final sessions = parcelleLocalId == null
        ? await _db.diagnosticSessionLocals.where().findAll()
        : await _db.diagnosticSessionLocals
            .filter()
            .parcelleLocalIdEqualTo(parcelleLocalId)
            .findAll();
    sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sessions;
  }

  /// Résultats affichables dans le journal : seules les sessions terminées,
  /// de la plus récente à la plus ancienne. Une session abandonnée en cours de
  /// route reste en base mais n'encombre pas le journal.
  Future<List<ResultatScan>> resultats({int? parcelleLocalId}) async {
    final sessions = (await historique(parcelleLocalId: parcelleLocalId))
        .where((session) => session.certitude != null)
        .toList();
    if (sessions.isEmpty) return const [];

    final ids = sessions.map((session) => session.id).toList();
    final observations = await _db.observationLocals
        .filter()
        .anyOf<int, QAfterFilterCondition>(ids, (query, id) => query.sessionIdEqualTo(id))
        .findAll();

    final parSession = <int, List<ObservationLocal>>{};
    for (final observation in observations) {
      parSession.putIfAbsent(observation.sessionId, () => []).add(observation);
    }

    return [
      for (final session in sessions)
        _versResultat(session, parSession[session.id] ?? const []),
    ];
  }

  ResultatScan _versResultat(
    DiagnosticSessionLocal session,
    List<ObservationLocal> observations,
  ) {
    final organes = <Organe>[];
    for (final observation in observations) {
      final organe = observation.organe;
      if (organe != null && !organes.contains(organe)) organes.add(organe);
    }

    return ResultatScan(
      sessionId: session.id,
      date: session.createdAt,
      organes: organes,
      parcelleLocalId: session.parcelleLocalId,
      ficheId: session.resultatFicheId,
      certitude: session.certitude,
      graviteDeclaree: session.graviteDeclaree,
      imagePath: observations
          .map((observation) => observation.imagePath)
          .where((chemin) => chemin.isNotEmpty)
          .firstOrNull,
      nbPhotos: observations.length,
    );
  }

  /// Sessions terminées qui restent à envoyer au serveur (tâche P1.9).
  Future<List<DiagnosticSessionLocal>> nonSynchronisees() async {
    final sessions = await _db.diagnosticSessionLocals
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
    return sessions.where((session) => session.certitude != null).toList();
  }

  Future<void> marquerSynchronisee(int sessionId, int serverId) async {
    final session = await _db.diagnosticSessionLocals.get(sessionId);
    if (session == null) return;

    final observations = await this.observations(sessionId);
    await _db.writeTxn(() async {
      session
        ..isSynced = true
        ..serverId = serverId;
      await _db.diagnosticSessionLocals.put(session);
      for (final observation in observations) {
        observation.isSynced = true;
        await _db.observationLocals.put(observation);
      }
    });
  }

  /// Supprime une session et ses observations.
  Future<void> supprimerSession(int sessionId) async {
    final observations = await this.observations(sessionId);
    await _db.writeTxn(() async {
      await _db.observationLocals.deleteAll([for (final o in observations) o.id]);
      await _db.diagnosticSessionLocals.delete(sessionId);
    });
  }

  /// Supprime les sessions d'une parcelle supprimée, avec leurs observations.
  Future<int> supprimerSessionsDeParcelle(int parcelleLocalId) async {
    final sessions = await historique(parcelleLocalId: parcelleLocalId);
    for (final session in sessions) {
      await supprimerSession(session.id);
    }
    return sessions.length;
  }
}

String encoderClassement(List<ScoredLabel> classement) => jsonEncode([
      for (final candidat in classement) {'label': candidat.label, 'p': candidat.score},
    ]);

List<ScoredLabel> decoderClassement(String? json) {
  if (json == null || json.isEmpty) return const [];
  final brut = jsonDecode(json);
  if (brut is! List) return const [];
  return [
    for (final element in brut)
      if (element is Map)
        ScoredLabel(
          element['label']?.toString() ?? '',
          (element['p'] as num?)?.toDouble() ?? 0,
        ),
  ];
}

Map<String, String> decoderReponses(String? json) {
  if (json == null || json.isEmpty) return const {};
  final brut = jsonDecode(json);
  if (brut is! Map) return const {};
  return {
    for (final entree in brut.entries) entree.key.toString(): entree.value.toString(),
  };
}
