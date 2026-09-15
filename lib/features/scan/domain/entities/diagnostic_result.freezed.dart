// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagnostic_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DiagnosticResult {
  String? get id => throw _privateConstructorUsedError;
  String get culture => throw _privateConstructorUsedError;
  String get maladieDetectee => throw _privateConstructorUsedError;
  double get confiance => throw _privateConstructorUsedError;
  String? get imagePath => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get parcelleId => throw _privateConstructorUsedError;

  /// Part de la parcelle touchée déclarée par l'agriculteur
  /// (code de `DeclaredSeverity`), jamais déduite du modèle.
  String? get niveauGravite => throw _privateConstructorUsedError;
  List<String> get recommandations => throw _privateConstructorUsedError;
  DiagnosisCertainty get certitude => throw _privateConstructorUsedError;

  /// Les classes les plus probables, de la plus à la moins probable.
  List<ScoredLabel> get classement => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DiagnosticResultCopyWith<DiagnosticResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiagnosticResultCopyWith<$Res> {
  factory $DiagnosticResultCopyWith(
          DiagnosticResult value, $Res Function(DiagnosticResult) then) =
      _$DiagnosticResultCopyWithImpl<$Res, DiagnosticResult>;
  @useResult
  $Res call(
      {String? id,
      String culture,
      String maladieDetectee,
      double confiance,
      String? imagePath,
      DateTime createdAt,
      String? parcelleId,
      String? niveauGravite,
      List<String> recommandations,
      DiagnosisCertainty certitude,
      List<ScoredLabel> classement});
}

/// @nodoc
class _$DiagnosticResultCopyWithImpl<$Res, $Val extends DiagnosticResult>
    implements $DiagnosticResultCopyWith<$Res> {
  _$DiagnosticResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? culture = null,
    Object? maladieDetectee = null,
    Object? confiance = null,
    Object? imagePath = freezed,
    Object? createdAt = null,
    Object? parcelleId = freezed,
    Object? niveauGravite = freezed,
    Object? recommandations = null,
    Object? certitude = null,
    Object? classement = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      culture: null == culture
          ? _value.culture
          : culture // ignore: cast_nullable_to_non_nullable
              as String,
      maladieDetectee: null == maladieDetectee
          ? _value.maladieDetectee
          : maladieDetectee // ignore: cast_nullable_to_non_nullable
              as String,
      confiance: null == confiance
          ? _value.confiance
          : confiance // ignore: cast_nullable_to_non_nullable
              as double,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      parcelleId: freezed == parcelleId
          ? _value.parcelleId
          : parcelleId // ignore: cast_nullable_to_non_nullable
              as String?,
      niveauGravite: freezed == niveauGravite
          ? _value.niveauGravite
          : niveauGravite // ignore: cast_nullable_to_non_nullable
              as String?,
      recommandations: null == recommandations
          ? _value.recommandations
          : recommandations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      certitude: null == certitude
          ? _value.certitude
          : certitude // ignore: cast_nullable_to_non_nullable
              as DiagnosisCertainty,
      classement: null == classement
          ? _value.classement
          : classement // ignore: cast_nullable_to_non_nullable
              as List<ScoredLabel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiagnosticResultImplCopyWith<$Res>
    implements $DiagnosticResultCopyWith<$Res> {
  factory _$$DiagnosticResultImplCopyWith(_$DiagnosticResultImpl value,
          $Res Function(_$DiagnosticResultImpl) then) =
      __$$DiagnosticResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String culture,
      String maladieDetectee,
      double confiance,
      String? imagePath,
      DateTime createdAt,
      String? parcelleId,
      String? niveauGravite,
      List<String> recommandations,
      DiagnosisCertainty certitude,
      List<ScoredLabel> classement});
}

/// @nodoc
class __$$DiagnosticResultImplCopyWithImpl<$Res>
    extends _$DiagnosticResultCopyWithImpl<$Res, _$DiagnosticResultImpl>
    implements _$$DiagnosticResultImplCopyWith<$Res> {
  __$$DiagnosticResultImplCopyWithImpl(_$DiagnosticResultImpl _value,
      $Res Function(_$DiagnosticResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? culture = null,
    Object? maladieDetectee = null,
    Object? confiance = null,
    Object? imagePath = freezed,
    Object? createdAt = null,
    Object? parcelleId = freezed,
    Object? niveauGravite = freezed,
    Object? recommandations = null,
    Object? certitude = null,
    Object? classement = null,
  }) {
    return _then(_$DiagnosticResultImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      culture: null == culture
          ? _value.culture
          : culture // ignore: cast_nullable_to_non_nullable
              as String,
      maladieDetectee: null == maladieDetectee
          ? _value.maladieDetectee
          : maladieDetectee // ignore: cast_nullable_to_non_nullable
              as String,
      confiance: null == confiance
          ? _value.confiance
          : confiance // ignore: cast_nullable_to_non_nullable
              as double,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      parcelleId: freezed == parcelleId
          ? _value.parcelleId
          : parcelleId // ignore: cast_nullable_to_non_nullable
              as String?,
      niveauGravite: freezed == niveauGravite
          ? _value.niveauGravite
          : niveauGravite // ignore: cast_nullable_to_non_nullable
              as String?,
      recommandations: null == recommandations
          ? _value._recommandations
          : recommandations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      certitude: null == certitude
          ? _value.certitude
          : certitude // ignore: cast_nullable_to_non_nullable
              as DiagnosisCertainty,
      classement: null == classement
          ? _value._classement
          : classement // ignore: cast_nullable_to_non_nullable
              as List<ScoredLabel>,
    ));
  }
}

/// @nodoc

class _$DiagnosticResultImpl implements _DiagnosticResult {
  const _$DiagnosticResultImpl(
      {this.id,
      this.culture = 'Riz',
      required this.maladieDetectee,
      required this.confiance,
      this.imagePath,
      required this.createdAt,
      this.parcelleId,
      this.niveauGravite,
      final List<String> recommandations = const <String>[],
      this.certitude = DiagnosisCertainty.incertain,
      final List<ScoredLabel> classement = const <ScoredLabel>[]})
      : _recommandations = recommandations,
        _classement = classement;

  @override
  final String? id;
  @override
  @JsonKey()
  final String culture;
  @override
  final String maladieDetectee;
  @override
  final double confiance;
  @override
  final String? imagePath;
  @override
  final DateTime createdAt;
  @override
  final String? parcelleId;

  /// Part de la parcelle touchée déclarée par l'agriculteur
  /// (code de `DeclaredSeverity`), jamais déduite du modèle.
  @override
  final String? niveauGravite;
  final List<String> _recommandations;
  @override
  @JsonKey()
  List<String> get recommandations {
    if (_recommandations is EqualUnmodifiableListView) return _recommandations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommandations);
  }

  @override
  @JsonKey()
  final DiagnosisCertainty certitude;

  /// Les classes les plus probables, de la plus à la moins probable.
  final List<ScoredLabel> _classement;

  /// Les classes les plus probables, de la plus à la moins probable.
  @override
  @JsonKey()
  List<ScoredLabel> get classement {
    if (_classement is EqualUnmodifiableListView) return _classement;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_classement);
  }

  @override
  String toString() {
    return 'DiagnosticResult(id: $id, culture: $culture, maladieDetectee: $maladieDetectee, confiance: $confiance, imagePath: $imagePath, createdAt: $createdAt, parcelleId: $parcelleId, niveauGravite: $niveauGravite, recommandations: $recommandations, certitude: $certitude, classement: $classement)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiagnosticResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.culture, culture) || other.culture == culture) &&
            (identical(other.maladieDetectee, maladieDetectee) ||
                other.maladieDetectee == maladieDetectee) &&
            (identical(other.confiance, confiance) ||
                other.confiance == confiance) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.parcelleId, parcelleId) ||
                other.parcelleId == parcelleId) &&
            (identical(other.niveauGravite, niveauGravite) ||
                other.niveauGravite == niveauGravite) &&
            const DeepCollectionEquality()
                .equals(other._recommandations, _recommandations) &&
            (identical(other.certitude, certitude) ||
                other.certitude == certitude) &&
            const DeepCollectionEquality()
                .equals(other._classement, _classement));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      culture,
      maladieDetectee,
      confiance,
      imagePath,
      createdAt,
      parcelleId,
      niveauGravite,
      const DeepCollectionEquality().hash(_recommandations),
      certitude,
      const DeepCollectionEquality().hash(_classement));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DiagnosticResultImplCopyWith<_$DiagnosticResultImpl> get copyWith =>
      __$$DiagnosticResultImplCopyWithImpl<_$DiagnosticResultImpl>(
          this, _$identity);
}

abstract class _DiagnosticResult implements DiagnosticResult {
  const factory _DiagnosticResult(
      {final String? id,
      final String culture,
      required final String maladieDetectee,
      required final double confiance,
      final String? imagePath,
      required final DateTime createdAt,
      final String? parcelleId,
      final String? niveauGravite,
      final List<String> recommandations,
      final DiagnosisCertainty certitude,
      final List<ScoredLabel> classement}) = _$DiagnosticResultImpl;

  @override
  String? get id;
  @override
  String get culture;
  @override
  String get maladieDetectee;
  @override
  double get confiance;
  @override
  String? get imagePath;
  @override
  DateTime get createdAt;
  @override
  String? get parcelleId;
  @override

  /// Part de la parcelle touchée déclarée par l'agriculteur
  /// (code de `DeclaredSeverity`), jamais déduite du modèle.
  String? get niveauGravite;
  @override
  List<String> get recommandations;
  @override
  DiagnosisCertainty get certitude;
  @override

  /// Les classes les plus probables, de la plus à la moins probable.
  List<ScoredLabel> get classement;
  @override
  @JsonKey(ignore: true)
  _$$DiagnosticResultImplCopyWith<_$DiagnosticResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
