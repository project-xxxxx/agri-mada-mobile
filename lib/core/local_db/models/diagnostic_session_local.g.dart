// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostic_session_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDiagnosticSessionLocalCollection on Isar {
  IsarCollection<DiagnosticSessionLocal> get diagnosticSessionLocals =>
      this.collection();
}

const DiagnosticSessionLocalSchema = CollectionSchema(
  name: r'DiagnosticSessionLocal',
  id: -4906178844298217880,
  properties: {
    r'certitude': PropertySchema(
      id: 0,
      name: r'certitude',
      type: IsarType.string,
    ),
    r'classement': PropertySchema(
      id: 1,
      name: r'classement',
      type: IsarType.string,
    ),
    r'clientUuid': PropertySchema(
      id: 2,
      name: r'clientUuid',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'ecosysteme': PropertySchema(
      id: 4,
      name: r'ecosysteme',
      type: IsarType.string,
    ),
    r'graviteDeclaree': PropertySchema(
      id: 5,
      name: r'graviteDeclaree',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 6,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'origineDiagnosticId': PropertySchema(
      id: 7,
      name: r'origineDiagnosticId',
      type: IsarType.long,
    ),
    r'parcelleLocalId': PropertySchema(
      id: 8,
      name: r'parcelleLocalId',
      type: IsarType.long,
    ),
    r'resultatFicheId': PropertySchema(
      id: 9,
      name: r'resultatFicheId',
      type: IsarType.string,
    ),
    r'serverId': PropertySchema(
      id: 10,
      name: r'serverId',
      type: IsarType.long,
    ),
    r'stade': PropertySchema(
      id: 11,
      name: r'stade',
      type: IsarType.string,
    ),
    r'statutValidation': PropertySchema(
      id: 12,
      name: r'statutValidation',
      type: IsarType.string,
    )
  },
  estimateSize: _diagnosticSessionLocalEstimateSize,
  serialize: _diagnosticSessionLocalSerialize,
  deserialize: _diagnosticSessionLocalDeserialize,
  deserializeProp: _diagnosticSessionLocalDeserializeProp,
  idName: r'id',
  indexes: {
    r'clientUuid': IndexSchema(
      id: 9054268822263051315,
      name: r'clientUuid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'clientUuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _diagnosticSessionLocalGetId,
  getLinks: _diagnosticSessionLocalGetLinks,
  attach: _diagnosticSessionLocalAttach,
  version: '3.1.0+1',
);

int _diagnosticSessionLocalEstimateSize(
  DiagnosticSessionLocal object,
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
    final value = object.classement;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.clientUuid.length * 3;
  {
    final value = object.ecosysteme;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.graviteDeclaree;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.resultatFicheId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.stade;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.statutValidation.length * 3;
  return bytesCount;
}

void _diagnosticSessionLocalSerialize(
  DiagnosticSessionLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.certitude);
  writer.writeString(offsets[1], object.classement);
  writer.writeString(offsets[2], object.clientUuid);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeString(offsets[4], object.ecosysteme);
  writer.writeString(offsets[5], object.graviteDeclaree);
  writer.writeBool(offsets[6], object.isSynced);
  writer.writeLong(offsets[7], object.origineDiagnosticId);
  writer.writeLong(offsets[8], object.parcelleLocalId);
  writer.writeString(offsets[9], object.resultatFicheId);
  writer.writeLong(offsets[10], object.serverId);
  writer.writeString(offsets[11], object.stade);
  writer.writeString(offsets[12], object.statutValidation);
}

DiagnosticSessionLocal _diagnosticSessionLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DiagnosticSessionLocal();
  object.certitude = reader.readStringOrNull(offsets[0]);
  object.classement = reader.readStringOrNull(offsets[1]);
  object.clientUuid = reader.readString(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.ecosysteme = reader.readStringOrNull(offsets[4]);
  object.graviteDeclaree = reader.readStringOrNull(offsets[5]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[6]);
  object.origineDiagnosticId = reader.readLongOrNull(offsets[7]);
  object.parcelleLocalId = reader.readLongOrNull(offsets[8]);
  object.resultatFicheId = reader.readStringOrNull(offsets[9]);
  object.serverId = reader.readLongOrNull(offsets[10]);
  object.stade = reader.readStringOrNull(offsets[11]);
  object.statutValidation = reader.readString(offsets[12]);
  return object;
}

P _diagnosticSessionLocalDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _diagnosticSessionLocalGetId(DiagnosticSessionLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _diagnosticSessionLocalGetLinks(
    DiagnosticSessionLocal object) {
  return [];
}

void _diagnosticSessionLocalAttach(
    IsarCollection<dynamic> col, Id id, DiagnosticSessionLocal object) {
  object.id = id;
}

extension DiagnosticSessionLocalByIndex
    on IsarCollection<DiagnosticSessionLocal> {
  Future<DiagnosticSessionLocal?> getByClientUuid(String clientUuid) {
    return getByIndex(r'clientUuid', [clientUuid]);
  }

  DiagnosticSessionLocal? getByClientUuidSync(String clientUuid) {
    return getByIndexSync(r'clientUuid', [clientUuid]);
  }

  Future<bool> deleteByClientUuid(String clientUuid) {
    return deleteByIndex(r'clientUuid', [clientUuid]);
  }

  bool deleteByClientUuidSync(String clientUuid) {
    return deleteByIndexSync(r'clientUuid', [clientUuid]);
  }

  Future<List<DiagnosticSessionLocal?>> getAllByClientUuid(
      List<String> clientUuidValues) {
    final values = clientUuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'clientUuid', values);
  }

  List<DiagnosticSessionLocal?> getAllByClientUuidSync(
      List<String> clientUuidValues) {
    final values = clientUuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'clientUuid', values);
  }

  Future<int> deleteAllByClientUuid(List<String> clientUuidValues) {
    final values = clientUuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'clientUuid', values);
  }

  int deleteAllByClientUuidSync(List<String> clientUuidValues) {
    final values = clientUuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'clientUuid', values);
  }

  Future<Id> putByClientUuid(DiagnosticSessionLocal object) {
    return putByIndex(r'clientUuid', object);
  }

  Id putByClientUuidSync(DiagnosticSessionLocal object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'clientUuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByClientUuid(List<DiagnosticSessionLocal> objects) {
    return putAllByIndex(r'clientUuid', objects);
  }

  List<Id> putAllByClientUuidSync(List<DiagnosticSessionLocal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'clientUuid', objects, saveLinks: saveLinks);
  }
}

extension DiagnosticSessionLocalQueryWhereSort
    on QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QWhere> {
  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DiagnosticSessionLocalQueryWhere on QueryBuilder<
    DiagnosticSessionLocal, DiagnosticSessionLocal, QWhereClause> {
  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterWhereClause> clientUuidEqualTo(String clientUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'clientUuid',
        value: [clientUuid],
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterWhereClause> clientUuidNotEqualTo(String clientUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clientUuid',
              lower: [],
              upper: [clientUuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clientUuid',
              lower: [clientUuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clientUuid',
              lower: [clientUuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clientUuid',
              lower: [],
              upper: [clientUuid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DiagnosticSessionLocalQueryFilter on QueryBuilder<
    DiagnosticSessionLocal, DiagnosticSessionLocal, QFilterCondition> {
  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> certitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'certitude',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> certitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'certitude',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> certitudeEqualTo(
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> certitudeGreaterThan(
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> certitudeLessThan(
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> certitudeBetween(
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> certitudeStartsWith(
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> certitudeEndsWith(
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      certitudeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'certitude',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      certitudeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'certitude',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> certitudeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'certitude',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> certitudeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'certitude',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> classementIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'classement',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> classementIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'classement',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> classementEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classement',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> classementGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'classement',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> classementLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'classement',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> classementBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'classement',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> classementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'classement',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> classementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'classement',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      classementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'classement',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      classementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'classement',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> classementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classement',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> classementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'classement',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> clientUuidEqualTo(
    String value, {
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> clientUuidGreaterThan(
    String value, {
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> clientUuidLessThan(
    String value, {
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> clientUuidBetween(
    String lower,
    String upper, {
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> clientUuidStartsWith(
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> clientUuidEndsWith(
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      clientUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clientUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      clientUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clientUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> clientUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clientUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> clientUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clientUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> ecosystemeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ecosysteme',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> ecosystemeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ecosysteme',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> ecosystemeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ecosysteme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> ecosystemeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ecosysteme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> ecosystemeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ecosysteme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> ecosystemeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ecosysteme',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> ecosystemeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ecosysteme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> ecosystemeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ecosysteme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      ecosystemeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ecosysteme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      ecosystemeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ecosysteme',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> ecosystemeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ecosysteme',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> ecosystemeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ecosysteme',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> graviteDeclareeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'graviteDeclaree',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> graviteDeclareeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'graviteDeclaree',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> graviteDeclareeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'graviteDeclaree',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> graviteDeclareeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'graviteDeclaree',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> graviteDeclareeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'graviteDeclaree',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> graviteDeclareeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'graviteDeclaree',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> graviteDeclareeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'graviteDeclaree',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> graviteDeclareeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'graviteDeclaree',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      graviteDeclareeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'graviteDeclaree',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      graviteDeclareeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'graviteDeclaree',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> graviteDeclareeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'graviteDeclaree',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> graviteDeclareeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'graviteDeclaree',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> origineDiagnosticIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'origineDiagnosticId',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> origineDiagnosticIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'origineDiagnosticId',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> origineDiagnosticIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origineDiagnosticId',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> origineDiagnosticIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'origineDiagnosticId',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> origineDiagnosticIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'origineDiagnosticId',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> origineDiagnosticIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'origineDiagnosticId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> parcelleLocalIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parcelleLocalId',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> parcelleLocalIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parcelleLocalId',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> parcelleLocalIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parcelleLocalId',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> parcelleLocalIdGreaterThan(
    int? value, {
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> parcelleLocalIdLessThan(
    int? value, {
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> parcelleLocalIdBetween(
    int? lower,
    int? upper, {
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> resultatFicheIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'resultatFicheId',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> resultatFicheIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'resultatFicheId',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> resultatFicheIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resultatFicheId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> resultatFicheIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'resultatFicheId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> resultatFicheIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'resultatFicheId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> resultatFicheIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'resultatFicheId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> resultatFicheIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'resultatFicheId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> resultatFicheIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'resultatFicheId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      resultatFicheIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'resultatFicheId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      resultatFicheIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'resultatFicheId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> resultatFicheIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resultatFicheId',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> resultatFicheIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'resultatFicheId',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> serverIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> serverIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> serverIdGreaterThan(
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> serverIdLessThan(
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> serverIdBetween(
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

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> stadeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stade',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> stadeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stade',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> stadeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> stadeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> stadeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> stadeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stade',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> stadeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> stadeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      stadeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      stadeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stade',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> stadeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stade',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> stadeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stade',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> statutValidationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statutValidation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> statutValidationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'statutValidation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> statutValidationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'statutValidation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> statutValidationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'statutValidation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> statutValidationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'statutValidation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> statutValidationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'statutValidation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      statutValidationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'statutValidation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
          QAfterFilterCondition>
      statutValidationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'statutValidation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> statutValidationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statutValidation',
        value: '',
      ));
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal,
      QAfterFilterCondition> statutValidationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'statutValidation',
        value: '',
      ));
    });
  }
}

extension DiagnosticSessionLocalQueryObject on QueryBuilder<
    DiagnosticSessionLocal, DiagnosticSessionLocal, QFilterCondition> {}

extension DiagnosticSessionLocalQueryLinks on QueryBuilder<
    DiagnosticSessionLocal, DiagnosticSessionLocal, QFilterCondition> {}

extension DiagnosticSessionLocalQuerySortBy
    on QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QSortBy> {
  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByCertitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certitude', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByCertitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certitude', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByClassement() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classement', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByClassementDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classement', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByClientUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByClientUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByEcosysteme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ecosysteme', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByEcosystemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ecosysteme', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByGraviteDeclaree() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'graviteDeclaree', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByGraviteDeclareeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'graviteDeclaree', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByOrigineDiagnosticId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origineDiagnosticId', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByOrigineDiagnosticIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origineDiagnosticId', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByParcelleLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parcelleLocalId', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByParcelleLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parcelleLocalId', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByResultatFicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultatFicheId', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByResultatFicheIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultatFicheId', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByStade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stade', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByStadeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stade', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByStatutValidation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statutValidation', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      sortByStatutValidationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statutValidation', Sort.desc);
    });
  }
}

extension DiagnosticSessionLocalQuerySortThenBy on QueryBuilder<
    DiagnosticSessionLocal, DiagnosticSessionLocal, QSortThenBy> {
  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByCertitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certitude', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByCertitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'certitude', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByClassement() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classement', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByClassementDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classement', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByClientUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByClientUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByEcosysteme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ecosysteme', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByEcosystemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ecosysteme', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByGraviteDeclaree() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'graviteDeclaree', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByGraviteDeclareeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'graviteDeclaree', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByOrigineDiagnosticId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origineDiagnosticId', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByOrigineDiagnosticIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origineDiagnosticId', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByParcelleLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parcelleLocalId', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByParcelleLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parcelleLocalId', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByResultatFicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultatFicheId', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByResultatFicheIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultatFicheId', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByStade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stade', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByStadeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stade', Sort.desc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByStatutValidation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statutValidation', Sort.asc);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QAfterSortBy>
      thenByStatutValidationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statutValidation', Sort.desc);
    });
  }
}

extension DiagnosticSessionLocalQueryWhereDistinct
    on QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QDistinct> {
  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QDistinct>
      distinctByCertitude({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'certitude', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QDistinct>
      distinctByClassement({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'classement', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QDistinct>
      distinctByClientUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clientUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QDistinct>
      distinctByEcosysteme({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ecosysteme', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QDistinct>
      distinctByGraviteDeclaree({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'graviteDeclaree',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QDistinct>
      distinctByOrigineDiagnosticId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origineDiagnosticId');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QDistinct>
      distinctByParcelleLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parcelleLocalId');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QDistinct>
      distinctByResultatFicheId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resultatFicheId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QDistinct>
      distinctByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QDistinct>
      distinctByStade({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stade', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DiagnosticSessionLocal, QDistinct>
      distinctByStatutValidation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statutValidation',
          caseSensitive: caseSensitive);
    });
  }
}

extension DiagnosticSessionLocalQueryProperty on QueryBuilder<
    DiagnosticSessionLocal, DiagnosticSessionLocal, QQueryProperty> {
  QueryBuilder<DiagnosticSessionLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, String?, QQueryOperations>
      certitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'certitude');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, String?, QQueryOperations>
      classementProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classement');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, String, QQueryOperations>
      clientUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clientUuid');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, String?, QQueryOperations>
      ecosystemeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ecosysteme');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, String?, QQueryOperations>
      graviteDeclareeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'graviteDeclaree');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, bool, QQueryOperations>
      isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, int?, QQueryOperations>
      origineDiagnosticIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origineDiagnosticId');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, int?, QQueryOperations>
      parcelleLocalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parcelleLocalId');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, String?, QQueryOperations>
      resultatFicheIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resultatFicheId');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, int?, QQueryOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, String?, QQueryOperations>
      stadeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stade');
    });
  }

  QueryBuilder<DiagnosticSessionLocal, String, QQueryOperations>
      statutValidationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statutValidation');
    });
  }
}
