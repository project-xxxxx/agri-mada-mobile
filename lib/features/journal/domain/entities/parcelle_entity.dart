import 'package:freezed_annotation/freezed_annotation.dart';

part 'parcelle_entity.freezed.dart';

@freezed
class ParcelleEntity with _$ParcelleEntity {
  const factory ParcelleEntity({
    required String id,
    required String nom,

    /// Emplacement saisi par l'agriculteur (village, fokontany, repère).
    String? description,
    double? surface,
    @Default('Riz') String culture,
    DateTime? lastDiagnosticDate,
    @Default(false) bool isSynced,
    String? photoPath,
  }) = _ParcelleEntity;
}
