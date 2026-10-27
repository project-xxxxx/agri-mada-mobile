// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observation_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetObservationLocalCollection on Isar {
  IsarCollection<ObservationLocal> get observationLocals => this.collection();
}

const ObservationLocalSchema = CollectionSchema(
  name: r'ObservationLocal',
  id: -1001956267525940352,
  properties: {
    r'clientUuid': PropertySchema(
      id: 0,
      name: r'clientUuid',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'imagePath': PropertySchema(
      id: 2,
      name: r'imagePath',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 3,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'organeCode': PropertySchema(
      id: 4,
      name: r'organeCode',
      type: IsarType.string,
    ),
    r'qualiteLuminosite': PropertySchema(
      id: 5,
      name: r'qualiteLuminosite',
      type: IsarType.double,
    ),
    r'qualiteNettete': PropertySchema(
      id: 6,
      name: r'qualiteNettete',
      type: IsarType.double,
    ),
    r'reponses': PropertySchema(
      id: 7,
      name: r'reponses',
      type: IsarType.string,
    ),
    r'serverId': PropertySchema(
      id: 8,
      name: r'serverId',
      type: IsarType.long,
    ),
    r'sessionId': PropertySchema(
      id: 9,
      name: r'sessionId',
      type: IsarType.long,
    ),
    r'topK': PropertySchema(
      id: 10,
      name: r'topK',
      type: IsarType.string,
    )
  },
  estimateSize: _observationLocalEstimateSize,
  serialize: _observationLocalSerialize,
  deserialize: _observationLocalDeserialize,
  deserializeProp: _observationLocalDeserializeProp,
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
    ),
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _observationLocalGetId,
  getLinks: _observationLocalGetLinks,
  attach: _observationLocalAttach,
  version: '3.1.0+1',
);

int _observationLocalEstimateSize(
  ObservationLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.clientUuid.length * 3;
  bytesCount += 3 + object.imagePath.length * 3;
  bytesCount += 3 + object.organeCode.length * 3;
  {
    final value = object.reponses;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.topK;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _observationLocalSerialize(
  ObservationLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.clientUuid);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.imagePath);
  writer.writeBool(offsets[3], object.isSynced);
  writer.writeString(offsets[4], object.organeCode);
  writer.writeDouble(offsets[5], object.qualiteLuminosite);
  writer.writeDouble(offsets[6], object.qualiteNettete);
  writer.writeString(offsets[7], object.reponses);
  writer.writeLong(offsets[8], object.serverId);
  writer.writeLong(offsets[9], object.sessionId);
  writer.writeString(offsets[10], object.topK);
}

ObservationLocal _observationLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ObservationLocal();
  object.clientUuid = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.imagePath = reader.readString(offsets[2]);
  object.isSynced = reader.readBool(offsets[3]);
  object.organeCode = reader.readString(offsets[4]);
  object.qualiteLuminosite = reader.readDoubleOrNull(offsets[5]);
  object.qualiteNettete = reader.readDoubleOrNull(offsets[6]);
  object.reponses = reader.readStringOrNull(offsets[7]);
  object.serverId = reader.readLongOrNull(offsets[8]);
  object.sessionId = reader.readLong(offsets[9]);
  object.topK = reader.readStringOrNull(offsets[10]);
  return object;
}

P _observationLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _observationLocalGetId(ObservationLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _observationLocalGetLinks(ObservationLocal object) {
  return [];
}

void _observationLocalAttach(
    IsarCollection<dynamic> col, Id id, ObservationLocal object) {
  object.id = id;
}

extension ObservationLocalByIndex on IsarCollection<ObservationLocal> {
  Future<ObservationLocal?> getByClientUuid(String clientUuid) {
    return getByIndex(r'clientUuid', [clientUuid]);
  }

  ObservationLocal? getByClientUuidSync(String clientUuid) {
    return getByIndexSync(r'clientUuid', [clientUuid]);
  }

  Future<bool> deleteByClientUuid(String clientUuid) {
    return deleteByIndex(r'clientUuid', [clientUuid]);
  }

  bool deleteByClientUuidSync(String clientUuid) {
    return deleteByIndexSync(r'clientUuid', [clientUuid]);
  }

  Future<List<ObservationLocal?>> getAllByClientUuid(
      List<String> clientUuidValues) {
    final values = clientUuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'clientUuid', values);
  }

  List<ObservationLocal?> getAllByClientUuidSync(
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

  Future<Id> putByClientUuid(ObservationLocal object) {
    return putByIndex(r'clientUuid', object);
  }

  Id putByClientUuidSync(ObservationLocal object, {bool saveLinks = true}) {
    return putByIndexSync(r'clientUuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByClientUuid(List<ObservationLocal> objects) {
    return putAllByIndex(r'clientUuid', objects);
  }

  List<Id> putAllByClientUuidSync(List<ObservationLocal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'clientUuid', objects, saveLinks: saveLinks);
  }
}

extension ObservationLocalQueryWhereSort
    on QueryBuilder<ObservationLocal, ObservationLocal, QWhere> {
  QueryBuilder<ObservationLocal, ObservationLocal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterWhere> anySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sessionId'),
      );
    });
  }
}

extension ObservationLocalQueryWhere
    on QueryBuilder<ObservationLocal, ObservationLocal, QWhereClause> {
  QueryBuilder<ObservationLocal, ObservationLocal, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterWhereClause>
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterWhereClause> idBetween(
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterWhereClause>
      clientUuidEqualTo(String clientUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'clientUuid',
        value: [clientUuid],
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterWhereClause>
      clientUuidNotEqualTo(String clientUuid) {
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterWhereClause>
      sessionIdEqualTo(int sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId',
        value: [sessionId],
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterWhereClause>
      sessionIdNotEqualTo(int sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterWhereClause>
      sessionIdGreaterThan(
    int sessionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId',
        lower: [sessionId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterWhereClause>
      sessionIdLessThan(
    int sessionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId',
        lower: [],
        upper: [sessionId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterWhereClause>
      sessionIdBetween(
    int lowerSessionId,
    int upperSessionId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId',
        lower: [lowerSessionId],
        includeLower: includeLower,
        upper: [upperSessionId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ObservationLocalQueryFilter
    on QueryBuilder<ObservationLocal, ObservationLocal, QFilterCondition> {
  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      clientUuidEqualTo(
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      clientUuidGreaterThan(
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      clientUuidLessThan(
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      clientUuidBetween(
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      clientUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clientUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      clientUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clientUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      clientUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clientUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      clientUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clientUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      createdAtGreaterThan(
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      imagePathEqualTo(
    String value, {
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      imagePathGreaterThan(
    String value, {
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      imagePathLessThan(
    String value, {
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      imagePathBetween(
    String lower,
    String upper, {
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      imagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      imagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      imagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      imagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      organeCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'organeCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      organeCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'organeCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      organeCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'organeCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      organeCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'organeCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      organeCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'organeCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      organeCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'organeCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      organeCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'organeCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      organeCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'organeCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      organeCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'organeCode',
        value: '',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      organeCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'organeCode',
        value: '',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      qualiteLuminositeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'qualiteLuminosite',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      qualiteLuminositeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'qualiteLuminosite',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      qualiteLuminositeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qualiteLuminosite',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      qualiteLuminositeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'qualiteLuminosite',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      qualiteLuminositeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'qualiteLuminosite',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      qualiteLuminositeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'qualiteLuminosite',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      qualiteNetteteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'qualiteNettete',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      qualiteNetteteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'qualiteNettete',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      qualiteNetteteEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qualiteNettete',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      qualiteNetteteGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'qualiteNettete',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      qualiteNetteteLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'qualiteNettete',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      qualiteNetteteBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'qualiteNettete',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      reponsesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reponses',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      reponsesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reponses',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      reponsesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reponses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      reponsesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reponses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      reponsesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reponses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      reponsesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reponses',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      reponsesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reponses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      reponsesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reponses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      reponsesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reponses',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      reponsesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reponses',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      reponsesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reponses',
        value: '',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      reponsesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reponses',
        value: '',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      serverIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      serverIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
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

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      sessionIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      sessionIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      sessionIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      sessionIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      topKIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'topK',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      topKIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'topK',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      topKEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topK',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      topKGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topK',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      topKLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topK',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      topKBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topK',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      topKStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'topK',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      topKEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'topK',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      topKContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'topK',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      topKMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'topK',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      topKIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topK',
        value: '',
      ));
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterFilterCondition>
      topKIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'topK',
        value: '',
      ));
    });
  }
}

extension ObservationLocalQueryObject
    on QueryBuilder<ObservationLocal, ObservationLocal, QFilterCondition> {}

extension ObservationLocalQueryLinks
    on QueryBuilder<ObservationLocal, ObservationLocal, QFilterCondition> {}

extension ObservationLocalQuerySortBy
    on QueryBuilder<ObservationLocal, ObservationLocal, QSortBy> {
  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByClientUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByClientUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByOrganeCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organeCode', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByOrganeCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organeCode', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByQualiteLuminosite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualiteLuminosite', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByQualiteLuminositeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualiteLuminosite', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByQualiteNettete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualiteNettete', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByQualiteNetteteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualiteNettete', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByReponses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reponses', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByReponsesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reponses', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy> sortByTopK() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topK', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      sortByTopKDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topK', Sort.desc);
    });
  }
}

extension ObservationLocalQuerySortThenBy
    on QueryBuilder<ObservationLocal, ObservationLocal, QSortThenBy> {
  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByClientUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByClientUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByOrganeCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organeCode', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByOrganeCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organeCode', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByQualiteLuminosite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualiteLuminosite', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByQualiteLuminositeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualiteLuminosite', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByQualiteNettete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualiteNettete', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByQualiteNetteteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualiteNettete', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByReponses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reponses', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByReponsesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reponses', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy> thenByTopK() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topK', Sort.asc);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QAfterSortBy>
      thenByTopKDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topK', Sort.desc);
    });
  }
}

extension ObservationLocalQueryWhereDistinct
    on QueryBuilder<ObservationLocal, ObservationLocal, QDistinct> {
  QueryBuilder<ObservationLocal, ObservationLocal, QDistinct>
      distinctByClientUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clientUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QDistinct>
      distinctByImagePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QDistinct>
      distinctByOrganeCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'organeCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QDistinct>
      distinctByQualiteLuminosite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qualiteLuminosite');
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QDistinct>
      distinctByQualiteNettete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qualiteNettete');
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QDistinct>
      distinctByReponses({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reponses', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QDistinct>
      distinctByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId');
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QDistinct>
      distinctBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId');
    });
  }

  QueryBuilder<ObservationLocal, ObservationLocal, QDistinct> distinctByTopK(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topK', caseSensitive: caseSensitive);
    });
  }
}

extension ObservationLocalQueryProperty
    on QueryBuilder<ObservationLocal, ObservationLocal, QQueryProperty> {
  QueryBuilder<ObservationLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ObservationLocal, String, QQueryOperations>
      clientUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clientUuid');
    });
  }

  QueryBuilder<ObservationLocal, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ObservationLocal, String, QQueryOperations> imagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagePath');
    });
  }

  QueryBuilder<ObservationLocal, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<ObservationLocal, String, QQueryOperations>
      organeCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'organeCode');
    });
  }

  QueryBuilder<ObservationLocal, double?, QQueryOperations>
      qualiteLuminositeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qualiteLuminosite');
    });
  }

  QueryBuilder<ObservationLocal, double?, QQueryOperations>
      qualiteNetteteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qualiteNettete');
    });
  }

  QueryBuilder<ObservationLocal, String?, QQueryOperations> reponsesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reponses');
    });
  }

  QueryBuilder<ObservationLocal, int?, QQueryOperations> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<ObservationLocal, int, QQueryOperations> sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<ObservationLocal, String?, QQueryOperations> topKProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topK');
    });
  }
}
