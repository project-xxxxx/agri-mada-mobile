// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parcelle_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ParcelleEntity {
  String get id => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  double? get surface => throw _privateConstructorUsedError;
  String get culture => throw _privateConstructorUsedError;
  DateTime? get lastDiagnosticDate => throw _privateConstructorUsedError;
  bool get isSynced => throw _privateConstructorUsedError;
  String? get photoPath => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ParcelleEntityCopyWith<ParcelleEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParcelleEntityCopyWith<$Res> {
  factory $ParcelleEntityCopyWith(
          ParcelleEntity value, $Res Function(ParcelleEntity) then) =
      _$ParcelleEntityCopyWithImpl<$Res, ParcelleEntity>;
  @useResult
  $Res call(
      {String id,
      String nom,
      double? surface,
      String culture,
      DateTime? lastDiagnosticDate,
      bool isSynced,
      String? photoPath});
}

/// @nodoc
class _$ParcelleEntityCopyWithImpl<$Res, $Val extends ParcelleEntity>
    implements $ParcelleEntityCopyWith<$Res> {
  _$ParcelleEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? surface = freezed,
    Object? culture = null,
    Object? lastDiagnosticDate = freezed,
    Object? isSynced = null,
    Object? photoPath = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      surface: freezed == surface
          ? _value.surface
          : surface // ignore: cast_nullable_to_non_nullable
              as double?,
      culture: null == culture
          ? _value.culture
          : culture // ignore: cast_nullable_to_non_nullable
              as String,
      lastDiagnosticDate: freezed == lastDiagnosticDate
          ? _value.lastDiagnosticDate
          : lastDiagnosticDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      photoPath: freezed == photoPath
          ? _value.photoPath
          : photoPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ParcelleEntityImplCopyWith<$Res>
    implements $ParcelleEntityCopyWith<$Res> {
  factory _$$ParcelleEntityImplCopyWith(_$ParcelleEntityImpl value,
          $Res Function(_$ParcelleEntityImpl) then) =
      __$$ParcelleEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String nom,
      double? surface,
      String culture,
      DateTime? lastDiagnosticDate,
      bool isSynced,
      String? photoPath});
}

/// @nodoc
class __$$ParcelleEntityImplCopyWithImpl<$Res>
    extends _$ParcelleEntityCopyWithImpl<$Res, _$ParcelleEntityImpl>
    implements _$$ParcelleEntityImplCopyWith<$Res> {
  __$$ParcelleEntityImplCopyWithImpl(
      _$ParcelleEntityImpl _value, $Res Function(_$ParcelleEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? surface = freezed,
    Object? culture = null,
    Object? lastDiagnosticDate = freezed,
    Object? isSynced = null,
    Object? photoPath = freezed,
  }) {
    return _then(_$ParcelleEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      surface: freezed == surface
          ? _value.surface
          : surface // ignore: cast_nullable_to_non_nullable
              as double?,
      culture: null == culture
          ? _value.culture
          : culture // ignore: cast_nullable_to_non_nullable
              as String,
      lastDiagnosticDate: freezed == lastDiagnosticDate
          ? _value.lastDiagnosticDate
          : lastDiagnosticDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSynced: null == isSynced
          ? _value.isSynced
          : isSynced // ignore: cast_nullable_to_non_nullable
              as bool,
      photoPath: freezed == photoPath
          ? _value.photoPath
          : photoPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ParcelleEntityImpl implements _ParcelleEntity {
  const _$ParcelleEntityImpl(
      {required this.id,
      required this.nom,
      this.surface,
      this.culture = 'Riz',
      this.lastDiagnosticDate,
      this.isSynced = false,
      this.photoPath});

  @override
  final String id;
  @override
  final String nom;
  @override
  final double? surface;
  @override
  @JsonKey()
  final String culture;
  @override
  final DateTime? lastDiagnosticDate;
  @override
  @JsonKey()
  final bool isSynced;
  @override
  final String? photoPath;

  @override
  String toString() {
    return 'ParcelleEntity(id: $id, nom: $nom, surface: $surface, culture: $culture, lastDiagnosticDate: $lastDiagnosticDate, isSynced: $isSynced, photoPath: $photoPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParcelleEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.surface, surface) || other.surface == surface) &&
            (identical(other.culture, culture) || other.culture == culture) &&
            (identical(other.lastDiagnosticDate, lastDiagnosticDate) ||
                other.lastDiagnosticDate == lastDiagnosticDate) &&
            (identical(other.isSynced, isSynced) ||
                other.isSynced == isSynced) &&
            (identical(other.photoPath, photoPath) ||
                other.photoPath == photoPath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, nom, surface, culture,
      lastDiagnosticDate, isSynced, photoPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ParcelleEntityImplCopyWith<_$ParcelleEntityImpl> get copyWith =>
      __$$ParcelleEntityImplCopyWithImpl<_$ParcelleEntityImpl>(
          this, _$identity);
}

abstract class _ParcelleEntity implements ParcelleEntity {
  const factory _ParcelleEntity(
      {required final String id,
      required final String nom,
      final double? surface,
      final String culture,
      final DateTime? lastDiagnosticDate,
      final bool isSynced,
      final String? photoPath}) = _$ParcelleEntityImpl;

  @override
  String get id;
  @override
  String get nom;
  @override
  double? get surface;
  @override
  String get culture;
  @override
  DateTime? get lastDiagnosticDate;
  @override
  bool get isSynced;
  @override
  String? get photoPath;
  @override
  @JsonKey(ignore: true)
  _$$ParcelleEntityImplCopyWith<_$ParcelleEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
