import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/ai/diagnosis_certainty.dart';

part 'diagnostic_result.freezed.dart';

@freezed
class DiagnosticResult with _$DiagnosticResult {
  const factory DiagnosticResult({
    String? id,
    @Default('Riz') String culture,
    required String maladieDetectee,
    required double confiance,
    String? imagePath,
    required DateTime createdAt,
    String? parcelleId,

    /// Part de la parcelle touchée déclarée par l'agriculteur
    /// (code de `DeclaredSeverity`), jamais déduite du modèle.
    String? niveauGravite,
    @Default(<String>[]) List<String> recommandations,
    @Default(DiagnosisCertainty.incertain) DiagnosisCertainty certitude,

    /// Les classes les plus probables, de la plus à la moins probable.
    @Default(<ScoredLabel>[]) List<ScoredLabel> classement,
  }) = _DiagnosticResult;
}
