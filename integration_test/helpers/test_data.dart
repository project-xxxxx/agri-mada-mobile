import 'dart:io';

import 'package:agri_mada/features/scan/domain/entities/diagnostic_result.dart';
import 'package:agri_mada/core/local_db/models/diagnostic_local.dart';
import 'package:agri_mada/core/local_db/models/parcelle_local.dart';
import 'package:isar/isar.dart';

const mockDiseaseName = 'Brown spot';

const mockRecommendations = <String>[
  'Améliorer la fertilisation (potassium)',
  'Appliquer un fongicide à base de mancozèbe',
  'Assurer un drainage correct',
  'Éviter le stress hydrique',
];

final mockTfliteResult = DiagnosticResult(
  maladieDetectee: mockDiseaseName,
  confiance: 0.91,
  niveauGravite: 'modéré',
  createdAt: DateTime(2026, 1, 2),
  recommandations: mockRecommendations,
);


ParcelleLocal buildTestParcelle({
  int? id,
  String nomParcelle = 'Parcelle Test',
  String? description,
  double? surface,
}) {
  return ParcelleLocal()
    ..id = id ?? Isar.autoIncrement
    ..nomParcelle = nomParcelle
    ..description = description
    ..surface = surface
    ..createdAt = DateTime(2026, 1, 1)
    ..isSynced = false;
}

DiagnosticLocal buildTestDiagnostic({
  int? id,
  int parcelleLocalId = 1,
  String maladieDetectee = mockDiseaseName,
  double confiance = 0.91,
  String? niveauGravite = 'modéré',
  String? imagePath,
  int? inferenceTimeMs,
  bool isSynced = false,
}) {
  return DiagnosticLocal()
    ..id = id ?? Isar.autoIncrement
    ..parcelleLocalId = parcelleLocalId
    ..maladieDetectee = maladieDetectee
    ..confiance = confiance
    ..niveauGravite = niveauGravite
    ..recommandations = mockRecommendations.join('\n')
    ..imagePath = imagePath
    ..inferenceTimeMs = inferenceTimeMs
    ..dateDiagnostic = DateTime(2026, 1, 2)
    ..isSynced = isSynced;
}

Future<File> createMockImageFile({String fileName = 'scan-test.jpg'}) async {
  final directory = await Directory.systemTemp.createTemp('agri_mada_e2e_');
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(const <int>[]);
  return file;
}
