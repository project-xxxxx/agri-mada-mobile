// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parcelle_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetParcelleLocalCollection on Isar {
  IsarCollection<ParcelleLocal> get parcelleLocals => this.collection();
}

const ParcelleLocalSchema = CollectionSchema(
  name: r'ParcelleLocal',
  id: 6903876400587891590,
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
    r'culture': PropertySchema(
      id: 2,
      name: r'culture',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 3,
      name: r'description',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 4,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'latitude': PropertySchema(
      id: 5,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 6,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'nomParcelle': PropertySchema(
      id: 7,
      name: r'nomParcelle',
      type: IsarType.string,
    ),
    r'photoPath': PropertySchema(
      id: 8,
      name: r'photoPath',
      type: IsarType.string,
    ),
    r'serverId': PropertySchema(
      id: 9,
      name: r'serverId',
      type: IsarType.long,
    ),
    r'surface': PropertySchema(
      id: 10,
      name: r'surface',
      type: IsarType.double,
    )
  },
  estimateSize: _parcelleLocalEstimateSize,
  serialize: _parcelleLocalSerialize,
  deserialize: _parcelleLocalDeserialize,
  deserializeProp: _parcelleLocalDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _parcelleLocalGetId,
  getLinks: _parcelleLocalGetLinks,
  attach: _parcelleLocalAttach,
  version: '3.1.0+1',
);

int _parcelleLocalEstimateSize(
  ParcelleLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.clientUuid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.culture;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.nomParcelle.length * 3;
  {
    final value = object.photoPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _parcelleLocalSerialize(
  ParcelleLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.clientUuid);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.culture);
  writer.writeString(offsets[3], object.description);
  writer.writeBool(offsets[4], object.isSynced);
  writer.writeDouble(offsets[5], object.latitude);
  writer.writeDouble(offsets[6], object.longitude);
  writer.writeString(offsets[7], object.nomParcelle);
  writer.writeString(offsets[8], object.photoPath);
  writer.writeLong(offsets[9], object.serverId);
  writer.writeDouble(offsets[10], object.surface);
}

ParcelleLocal _parcelleLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ParcelleLocal();
  object.clientUuid = reader.readStringOrNull(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.culture = reader.readStringOrNull(offsets[2]);
  object.description = reader.readStringOrNull(offsets[3]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[4]);
  object.latitude = reader.readDoubleOrNull(offsets[5]);
  object.longitude = reader.readDoubleOrNull(offsets[6]);
  object.nomParcelle = reader.readString(offsets[7]);
  object.photoPath = reader.readStringOrNull(offsets[8]);
  object.serverId = reader.readLongOrNull(offsets[9]);
  object.surface = reader.readDoubleOrNull(offsets[10]);
  return object;
}

P _parcelleLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _parcelleLocalGetId(ParcelleLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _parcelleLocalGetLinks(ParcelleLocal object) {
  return [];
}

void _parcelleLocalAttach(
    IsarCollection<dynamic> col, Id id, ParcelleLocal object) {
  object.id = id;
}

extension ParcelleLocalQueryWhereSort
    on QueryBuilder<ParcelleLocal, ParcelleLocal, QWhere> {
  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ParcelleLocalQueryWhere
    on QueryBuilder<ParcelleLocal, ParcelleLocal, QWhereClause> {
  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterWhereClause> idBetween(
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

extension ParcelleLocalQueryFilter
    on QueryBuilder<ParcelleLocal, ParcelleLocal, QFilterCondition> {
  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      clientUuidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clientUuid',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      clientUuidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clientUuid',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      clientUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clientUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      clientUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clientUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      clientUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clientUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      clientUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clientUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      cultureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'culture',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      cultureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'culture',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      cultureEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'culture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      cultureGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'culture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      cultureLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'culture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      cultureBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'culture',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      cultureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'culture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      cultureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'culture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      cultureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'culture',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      cultureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'culture',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      cultureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'culture',
        value: '',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      cultureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'culture',
        value: '',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      latitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'latitude',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      latitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'latitude',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      latitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      latitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      latitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      latitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      longitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'longitude',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      longitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'longitude',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      longitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      longitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      longitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      longitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      nomParcelleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomParcelle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      nomParcelleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nomParcelle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      nomParcelleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nomParcelle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      nomParcelleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nomParcelle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      nomParcelleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nomParcelle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      nomParcelleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nomParcelle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      nomParcelleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nomParcelle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      nomParcelleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nomParcelle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      nomParcelleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomParcelle',
        value: '',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      nomParcelleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nomParcelle',
        value: '',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      photoPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'photoPath',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      photoPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'photoPath',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      photoPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      photoPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      photoPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      photoPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photoPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      photoPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      photoPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      photoPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      photoPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      photoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      photoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      serverIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      serverIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
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

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      surfaceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'surface',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      surfaceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'surface',
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      surfaceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'surface',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      surfaceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'surface',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      surfaceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'surface',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterFilterCondition>
      surfaceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'surface',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension ParcelleLocalQueryObject
    on QueryBuilder<ParcelleLocal, ParcelleLocal, QFilterCondition> {}

extension ParcelleLocalQueryLinks
    on QueryBuilder<ParcelleLocal, ParcelleLocal, QFilterCondition> {}

extension ParcelleLocalQuerySortBy
    on QueryBuilder<ParcelleLocal, ParcelleLocal, QSortBy> {
  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> sortByClientUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      sortByClientUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> sortByCulture() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'culture', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> sortByCultureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'culture', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> sortByNomParcelle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomParcelle', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      sortByNomParcelleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomParcelle', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> sortByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      sortByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> sortBySurface() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surface', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> sortBySurfaceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surface', Sort.desc);
    });
  }
}

extension ParcelleLocalQuerySortThenBy
    on QueryBuilder<ParcelleLocal, ParcelleLocal, QSortThenBy> {
  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> thenByClientUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      thenByClientUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientUuid', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> thenByCulture() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'culture', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> thenByCultureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'culture', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> thenByNomParcelle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomParcelle', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      thenByNomParcelleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomParcelle', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> thenByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      thenByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> thenBySurface() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surface', Sort.asc);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QAfterSortBy> thenBySurfaceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surface', Sort.desc);
    });
  }
}

extension ParcelleLocalQueryWhereDistinct
    on QueryBuilder<ParcelleLocal, ParcelleLocal, QDistinct> {
  QueryBuilder<ParcelleLocal, ParcelleLocal, QDistinct> distinctByClientUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clientUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QDistinct> distinctByCulture(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'culture', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QDistinct> distinctByNomParcelle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nomParcelle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QDistinct> distinctByPhotoPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QDistinct> distinctByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId');
    });
  }

  QueryBuilder<ParcelleLocal, ParcelleLocal, QDistinct> distinctBySurface() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'surface');
    });
  }
}

extension ParcelleLocalQueryProperty
    on QueryBuilder<ParcelleLocal, ParcelleLocal, QQueryProperty> {
  QueryBuilder<ParcelleLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ParcelleLocal, String?, QQueryOperations> clientUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clientUuid');
    });
  }

  QueryBuilder<ParcelleLocal, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ParcelleLocal, String?, QQueryOperations> cultureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'culture');
    });
  }

  QueryBuilder<ParcelleLocal, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<ParcelleLocal, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<ParcelleLocal, double?, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<ParcelleLocal, double?, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<ParcelleLocal, String, QQueryOperations> nomParcelleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nomParcelle');
    });
  }

  QueryBuilder<ParcelleLocal, String?, QQueryOperations> photoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoPath');
    });
  }

  QueryBuilder<ParcelleLocal, int?, QQueryOperations> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<ParcelleLocal, double?, QQueryOperations> surfaceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'surface');
    });
  }
}
