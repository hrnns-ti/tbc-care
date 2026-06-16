// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicationRecordCollection on Isar {
  IsarCollection<MedicationRecord> get medicationRecords => this.collection();
}

const MedicationRecordSchema = CollectionSchema(
  name: r'MedicationRecord',
  id: 2640923040866432282,
  properties: {
    r'imagePath': PropertySchema(
      id: 0,
      name: r'imagePath',
      type: IsarType.string,
    ),
    r'isTaken': PropertySchema(
      id: 1,
      name: r'isTaken',
      type: IsarType.bool,
    ),
    r'scheduledTime': PropertySchema(
      id: 2,
      name: r'scheduledTime',
      type: IsarType.dateTime,
    ),
    r'takenTime': PropertySchema(
      id: 3,
      name: r'takenTime',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _medicationRecordEstimateSize,
  serialize: _medicationRecordSerialize,
  deserialize: _medicationRecordDeserialize,
  deserializeProp: _medicationRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _medicationRecordGetId,
  getLinks: _medicationRecordGetLinks,
  attach: _medicationRecordAttach,
  version: '3.1.0+1',
);

int _medicationRecordEstimateSize(
  MedicationRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.imagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _medicationRecordSerialize(
  MedicationRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.imagePath);
  writer.writeBool(offsets[1], object.isTaken);
  writer.writeDateTime(offsets[2], object.scheduledTime);
  writer.writeDateTime(offsets[3], object.takenTime);
}

MedicationRecord _medicationRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicationRecord();
  object.id = id;
  object.imagePath = reader.readStringOrNull(offsets[0]);
  object.isTaken = reader.readBool(offsets[1]);
  object.scheduledTime = reader.readDateTime(offsets[2]);
  object.takenTime = reader.readDateTimeOrNull(offsets[3]);
  return object;
}

P _medicationRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _medicationRecordGetId(MedicationRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _medicationRecordGetLinks(MedicationRecord object) {
  return [];
}

void _medicationRecordAttach(
    IsarCollection<dynamic> col, Id id, MedicationRecord object) {
  object.id = id;
}

extension MedicationRecordQueryWhereSort
    on QueryBuilder<MedicationRecord, MedicationRecord, QWhere> {
  QueryBuilder<MedicationRecord, MedicationRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MedicationRecordQueryWhere
    on QueryBuilder<MedicationRecord, MedicationRecord, QWhereClause> {
  QueryBuilder<MedicationRecord, MedicationRecord, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterWhereClause>
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

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterWhereClause> idBetween(
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

extension MedicationRecordQueryFilter
    on QueryBuilder<MedicationRecord, MedicationRecord, QFilterCondition> {
  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
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

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
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

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
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

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      imagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imagePath',
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      imagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imagePath',
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
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

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
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

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
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

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
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

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
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

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
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

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      imagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      imagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      imagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      imagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      isTakenEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isTaken',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      scheduledTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      scheduledTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      scheduledTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      scheduledTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      takenTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'takenTime',
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      takenTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'takenTime',
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      takenTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'takenTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      takenTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'takenTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      takenTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'takenTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterFilterCondition>
      takenTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'takenTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MedicationRecordQueryObject
    on QueryBuilder<MedicationRecord, MedicationRecord, QFilterCondition> {}

extension MedicationRecordQueryLinks
    on QueryBuilder<MedicationRecord, MedicationRecord, QFilterCondition> {}

extension MedicationRecordQuerySortBy
    on QueryBuilder<MedicationRecord, MedicationRecord, QSortBy> {
  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      sortByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      sortByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      sortByIsTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTaken', Sort.asc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      sortByIsTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTaken', Sort.desc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      sortByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.asc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      sortByScheduledTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.desc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      sortByTakenTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'takenTime', Sort.asc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      sortByTakenTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'takenTime', Sort.desc);
    });
  }
}

extension MedicationRecordQuerySortThenBy
    on QueryBuilder<MedicationRecord, MedicationRecord, QSortThenBy> {
  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      thenByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      thenByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      thenByIsTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTaken', Sort.asc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      thenByIsTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTaken', Sort.desc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      thenByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.asc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      thenByScheduledTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.desc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      thenByTakenTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'takenTime', Sort.asc);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QAfterSortBy>
      thenByTakenTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'takenTime', Sort.desc);
    });
  }
}

extension MedicationRecordQueryWhereDistinct
    on QueryBuilder<MedicationRecord, MedicationRecord, QDistinct> {
  QueryBuilder<MedicationRecord, MedicationRecord, QDistinct>
      distinctByImagePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QDistinct>
      distinctByIsTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isTaken');
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QDistinct>
      distinctByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledTime');
    });
  }

  QueryBuilder<MedicationRecord, MedicationRecord, QDistinct>
      distinctByTakenTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'takenTime');
    });
  }
}

extension MedicationRecordQueryProperty
    on QueryBuilder<MedicationRecord, MedicationRecord, QQueryProperty> {
  QueryBuilder<MedicationRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MedicationRecord, String?, QQueryOperations>
      imagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagePath');
    });
  }

  QueryBuilder<MedicationRecord, bool, QQueryOperations> isTakenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isTaken');
    });
  }

  QueryBuilder<MedicationRecord, DateTime, QQueryOperations>
      scheduledTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledTime');
    });
  }

  QueryBuilder<MedicationRecord, DateTime?, QQueryOperations>
      takenTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'takenTime');
    });
  }
}
