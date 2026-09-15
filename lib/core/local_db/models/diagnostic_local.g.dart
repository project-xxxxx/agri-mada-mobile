// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDiagnosticLocalCollection on Isar {
  IsarCollection<DiagnosticLocal> get diagnosticLocals => this.collection();
}

const DiagnosticLocalSchema = CollectionSchema(
  name: r'DiagnosticLocal',
  id: 383149067658847577,
  properties: {
    r'certitude': PropertySchema(
      id: 0,
      name: r'certitude',
      type: IsarType.string,
    ),
    r'clientUuid': PropertySchema(
      id: 1,
      name: r'clientUuid',
      type: IsarType.string,
    ),
    r'confiance': PropertySchema(
      id: 2,
      name: r'confiance',
      type: IsarType.double,
    ),
    r'dateDiagnostic': PropertySchema(
      id: 3,
      name: r'dateDiagnostic',
      type: IsarType.dateTime,
    ),
    r'imagePath': PropertySchema(
      id: 4,
      name: r'imagePath',
      type: IsarType.string,
    ),
    r'inferenceTimeMs': PropertySchema(
      id: 5,
      name: r'inferenceTimeMs',
      type: IsarType.long,
    ),
    r'isSynced': PropertySchema(
      id: 6,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'maladieDetectee': PropertySchema(
      id: 7,
      name: r'maladieDetectee',
      type: IsarType.string,
    ),
    r'niveauGravite': PropertySchema(
      id: 8,
      name: r'niveauGravite',
      type: IsarType.string,
    ),
    r'parcelleLocalId': PropertySchema(
      id: 9,
      name: r'parcelleLocalId',
      type: IsarType.long,
    ),
    r'recommandations': PropertySchema(
      id: 10,
      name: r'recommandations',
      type: IsarType.string,
    ),
    r'serverId': PropertySchema(
      id: 11,
      name: r'serverId',
      type: IsarType.long,
    )
  },
  estimateSize: _diagnosticLocalEstimateSize,
  serialize: _diagnosticLocalSerialize,
  deserialize: _diagnosticLocalDeserialize,
  deserializeProp: _diagnosticLocalDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _diagnosticLocalGetId,
  getLinks: _diagnosticLocalGetLinks,
  attach: _diagnosticLocalAttach,
  version: '3.1.0+1',
);

int _diagnosticLocalEstimateSize(
  DiagnosticLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.certitude;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.clientUuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.imagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.maladieDetectee.length * 3;
  {
    final value = object.niveauGravite;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.recommandations;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _diagnosticLocalSerialize(
  DiagnosticLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.certitude);
  writer.writeString(offsets[1], object.clientUuid);
  writer.writeDouble(offsets[2], object.confiance);
  writer.writeDateTime(offsets[3], object.dateDiagnostic);
  writer.writeString(offsets[4], object.imagePath);
  writer.writeLong(offsets[5], object.inferenceTimeMs);
  writer.writeBool(offsets[6], object.isSynced);
  writer.writeString(offsets[7], object.maladieDetectee);
  writer.writeString(offsets[8], object.niveauGravite);
  writer.writeLong(offsets[9], object.parcelleLocalId);
  writer.writeString(offsets[10], object.recommandations);
  writer.writeLong(offsets[11], object.serverId);
}

DiagnosticLocal _diagnosticLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DiagnosticLocal();
  object.certitude = reader.readStringOrNull(offsets[0]);
  object.clientUuid = reader.readStringOrNull(offsets[1]);
  object.confiance = reader.readDoubleOrNull(offsets[2]);
  object.dateDiagnostic = reader.readDateTime(offsets[3]);
  object.id = id;
  object.imagePath = reader.readStringOrNull(offsets[4]);
  object.inferenceTimeMs = reader.readLongOrNull(offsets[5]);
  object.isSynced = reader.readBool(offsets[6]);
  object.maladieDetectee = reader.readString(offsets[7]);
  object.niveauGravite = reader.readStringOrNull(offsets[8]);
  object.parcelleLocalId = reader.readLong(offsets[9]);
  object.recommandations = reader.readStringOrNull(offsets[10]);
  object.serverId = reader.readLongOrNull(offsets[11]);
  return object;
}

P _diagnosticLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _diagnosticLocalGetId(DiagnosticLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _diagnosticLocalGetLinks(DiagnosticLocal object) {
  return [];
}

void _diagnosticLocalAttach(
    IsarCollection<dynamic> col, Id id, DiagnosticLocal object) {
  object.id = id;
}

extension DiagnosticLocalQueryWhereSort
    on QueryBuilder<DiagnosticLocal, DiagnosticLocal, QWhere> {
  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DiagnosticLocalQueryWhere
    on QueryBuilder<DiagnosticLocal, DiagnosticLocal, QWhereClause> {
  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DiagnosticLocalQueryFilter
    on QueryBuilder<DiagnosticLocal, DiagnosticLocal, QFilterCondition> {
  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      certitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'certitude',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      certitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'certitude',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      certitudeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'certitude',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      certitudeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'certitude',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      certitudeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'certitude',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      certitudeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'certitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      certitudeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'certitude',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      certitudeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'certitude',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      certitudeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'certitude',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      certitudeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'certitude',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      certitudeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'certitude',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      certitudeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'certitude',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      clientUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clientUuid',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      clientUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clientUuid',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      clientUuidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clientUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      clientUuidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clientUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      clientUuidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clientUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      clientUuidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clientUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      clientUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clientUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      clientUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clientUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      clientUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clientUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      clientUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clientUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      clientUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clientUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      clientUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clientUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      confianceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'confiance',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      confianceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'confiance',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      confianceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confiance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      confianceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'confiance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      confianceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'confiance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      confianceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'confiance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      dateDiagnosticEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateDiagnostic',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      dateDiagnosticGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateDiagnostic',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      dateDiagnosticLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateDiagnostic',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      dateDiagnosticBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateDiagnostic',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      imagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imagePath',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      imagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imagePath',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      imagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      imagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      imagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      imagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      imagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      imagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      imagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      imagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      imagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      imagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      inferenceTimeMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'inferenceTimeMs',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      inferenceTimeMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'inferenceTimeMs',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      inferenceTimeMsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inferenceTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      inferenceTimeMsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'inferenceTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      inferenceTimeMsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'inferenceTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      inferenceTimeMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'inferenceTimeMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      maladieDetecteeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maladieDetectee',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      maladieDetecteeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maladieDetectee',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      maladieDetecteeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maladieDetectee',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      maladieDetecteeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maladieDetectee',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      maladieDetecteeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'maladieDetectee',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      maladieDetecteeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'maladieDetectee',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      maladieDetecteeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'maladieDetectee',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      maladieDetecteeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'maladieDetectee',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      maladieDetecteeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maladieDetectee',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      maladieDetecteeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'maladieDetectee',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      niveauGraviteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'niveauGravite',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      niveauGraviteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'niveauGravite',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      niveauGraviteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'niveauGravite',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      niveauGraviteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'niveauGravite',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      niveauGraviteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'niveauGravite',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      niveauGraviteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'niveauGravite',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      niveauGraviteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'niveauGravite',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      niveauGraviteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'niveauGravite',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      niveauGraviteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'niveauGravite',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      niveauGraviteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'niveauGravite',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      niveauGraviteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'niveauGravite',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      niveauGraviteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'niveauGravite',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      parcelleLocalIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parcelleLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      parcelleLocalIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parcelleLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      parcelleLocalIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parcelleLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      parcelleLocalIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parcelleLocalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      recommandationsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'recommandations',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      recommandationsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'recommandations',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      recommandationsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recommandations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      recommandationsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recommandations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      recommandationsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recommandations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      recommandationsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recommandations',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      recommandationsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recommandations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      recommandationsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recommandations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      recommandationsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recommandations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      recommandationsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recommandations',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      recommandationsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recommandations',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      recommandationsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recommandations',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      serverIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      serverIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      serverIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      serverIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterFilterCondition>
      serverIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serverId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DiagnosticLocalQueryObject
    on QueryBuilder<DiagnosticLocal, DiagnosticLocal, QFilterCondition> {}

extension DiagnosticLocalQueryLinks
    on QueryBuilder<DiagnosticLocal, DiagnosticLocal, QFilterCondition> {}

extension DiagnosticLocalQuerySortBy
    on QueryBuilder<DiagnosticLocal, DiagnosticLocal, QSortBy> {
  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByCertitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certitude', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByCertitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certitude', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByClientUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByClientUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByConfiance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confiance', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByConfianceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confiance', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByDateDiagnostic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateDiagnostic', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByDateDiagnosticDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateDiagnostic', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByInferenceTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inferenceTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByInferenceTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inferenceTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByMaladieDetectee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maladieDetectee', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByMaladieDetecteeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maladieDetectee', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByNiveauGravite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'niveauGravite', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByNiveauGraviteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'niveauGravite', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByParcelleLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parcelleLocalId', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByParcelleLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parcelleLocalId', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByRecommandations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommandations', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByRecommandationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommandations', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }
}

extension DiagnosticLocalQuerySortThenBy
    on QueryBuilder<DiagnosticLocal, DiagnosticLocal, QSortThenBy> {
  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByCertitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certitude', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByCertitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certitude', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByClientUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByClientUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByConfiance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confiance', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByConfianceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confiance', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByDateDiagnostic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateDiagnostic', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByDateDiagnosticDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateDiagnostic', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByInferenceTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inferenceTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByInferenceTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inferenceTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByMaladieDetectee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maladieDetectee', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByMaladieDetecteeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maladieDetectee', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByNiveauGravite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'niveauGravite', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByNiveauGraviteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'niveauGravite', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByParcelleLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parcelleLocalId', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByParcelleLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parcelleLocalId', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByRecommandations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommandations', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByRecommandationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommandations', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }
}

extension DiagnosticLocalQueryWhereDistinct
    on QueryBuilder<DiagnosticLocal, DiagnosticLocal, QDistinct> {
  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QDistinct> distinctByCertitude(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'certitude', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QDistinct>
      distinctByClientUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clientUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QDistinct>
      distinctByConfiance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confiance');
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QDistinct>
      distinctByDateDiagnostic() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateDiagnostic');
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QDistinct> distinctByImagePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QDistinct>
      distinctByInferenceTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inferenceTimeMs');
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QDistinct>
      distinctByMaladieDetectee({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maladieDetectee',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QDistinct>
      distinctByNiveauGravite({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'niveauGravite',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QDistinct>
      distinctByParcelleLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parcelleLocalId');
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QDistinct>
      distinctByRecommandations({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recommandations',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiagnosticLocal, DiagnosticLocal, QDistinct>
      distinctByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId');
    });
  }
}

extension DiagnosticLocalQueryProperty
    on QueryBuilder<DiagnosticLocal, DiagnosticLocal, QQueryProperty> {
  QueryBuilder<DiagnosticLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DiagnosticLocal, String?, QQueryOperations> certitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'certitude');
    });
  }

  QueryBuilder<DiagnosticLocal, String?, QQueryOperations>
      clientUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clientUuid');
    });
  }

  QueryBuilder<DiagnosticLocal, double?, QQueryOperations> confianceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confiance');
    });
  }

  QueryBuilder<DiagnosticLocal, DateTime, QQueryOperations>
      dateDiagnosticProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateDiagnostic');
    });
  }

  QueryBuilder<DiagnosticLocal, String?, QQueryOperations> imagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagePath');
    });
  }

  QueryBuilder<DiagnosticLocal, int?, QQueryOperations>
      inferenceTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inferenceTimeMs');
    });
  }

  QueryBuilder<DiagnosticLocal, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<DiagnosticLocal, String, QQueryOperations>
      maladieDetecteeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maladieDetectee');
    });
  }

  QueryBuilder<DiagnosticLocal, String?, QQueryOperations>
      niveauGraviteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'niveauGravite');
    });
  }

  QueryBuilder<DiagnosticLocal, int, QQueryOperations>
      parcelleLocalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parcelleLocalId');
    });
  }

  QueryBuilder<DiagnosticLocal, String?, QQueryOperations>
      recommandationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recommandations');
    });
  }

  QueryBuilder<DiagnosticLocal, int?, QQueryOperations> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }
}
