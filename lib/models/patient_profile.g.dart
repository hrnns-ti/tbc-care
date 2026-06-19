// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPatientProfileCollection on Isar {
  IsarCollection<PatientProfile> get patientProfiles => this.collection();
}

const PatientProfileSchema = CollectionSchema(
  name: r'PatientProfile',
  id: 6170442054193895292,
  properties: {
    r'birthDate': PropertySchema(
      id: 0,
      name: r'birthDate',
      type: IsarType.dateTime,
    ),
    r'fullName': PropertySchema(
      id: 1,
      name: r'fullName',
      type: IsarType.string,
    ),
    r'nik': PropertySchema(
      id: 2,
      name: r'nik',
      type: IsarType.string,
    ),
    r'phoneNumber': PropertySchema(
      id: 3,
      name: r'phoneNumber',
      type: IsarType.string,
    ),
    r'pmoName': PropertySchema(
      id: 4,
      name: r'pmoName',
      type: IsarType.string,
    ),
    r'puskesmasName': PropertySchema(
      id: 5,
      name: r'puskesmasName',
      type: IsarType.string,
    ),
    r'regimenCategory': PropertySchema(
      id: 6,
      name: r'regimenCategory',
      type: IsarType.string,
    ),
    r'schedules': PropertySchema(
      id: 7,
      name: r'schedules',
      type: IsarType.objectList,
      target: r'RegimenSchedule',
    ),
    r'totalTreatmentDays': PropertySchema(
      id: 8,
      name: r'totalTreatmentDays',
      type: IsarType.long,
    ),
    r'treatmentStartDate': PropertySchema(
      id: 9,
      name: r'treatmentStartDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _patientProfileEstimateSize,
  serialize: _patientProfileSerialize,
  deserialize: _patientProfileDeserialize,
  deserializeProp: _patientProfileDeserializeProp,
  idName: r'id',
  indexes: {
    r'nik': IndexSchema(
      id: -2798383488431574380,
      name: r'nik',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nik',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {
    r'RegimenSchedule': RegimenScheduleSchema,
    r'MedicineDetail': MedicineDetailSchema
  },
  getId: _patientProfileGetId,
  getLinks: _patientProfileGetLinks,
  attach: _patientProfileAttach,
  version: '3.1.0+1',
);

int _patientProfileEstimateSize(
  PatientProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fullName.length * 3;
  bytesCount += 3 + object.nik.length * 3;
  bytesCount += 3 + object.phoneNumber.length * 3;
  bytesCount += 3 + object.pmoName.length * 3;
  bytesCount += 3 + object.puskesmasName.length * 3;
  bytesCount += 3 + object.regimenCategory.length * 3;
  bytesCount += 3 + object.schedules.length * 3;
  {
    final offsets = allOffsets[RegimenSchedule]!;
    for (var i = 0; i < object.schedules.length; i++) {
      final value = object.schedules[i];
      bytesCount +=
          RegimenScheduleSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _patientProfileSerialize(
  PatientProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.birthDate);
  writer.writeString(offsets[1], object.fullName);
  writer.writeString(offsets[2], object.nik);
  writer.writeString(offsets[3], object.phoneNumber);
  writer.writeString(offsets[4], object.pmoName);
  writer.writeString(offsets[5], object.puskesmasName);
  writer.writeString(offsets[6], object.regimenCategory);
  writer.writeObjectList<RegimenSchedule>(
    offsets[7],
    allOffsets,
    RegimenScheduleSchema.serialize,
    object.schedules,
  );
  writer.writeLong(offsets[8], object.totalTreatmentDays);
  writer.writeDateTime(offsets[9], object.treatmentStartDate);
}

PatientProfile _patientProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PatientProfile();
  object.birthDate = reader.readDateTime(offsets[0]);
  object.fullName = reader.readString(offsets[1]);
  object.id = id;
  object.nik = reader.readString(offsets[2]);
  object.phoneNumber = reader.readString(offsets[3]);
  object.pmoName = reader.readString(offsets[4]);
  object.puskesmasName = reader.readString(offsets[5]);
  object.regimenCategory = reader.readString(offsets[6]);
  object.schedules = reader.readObjectList<RegimenSchedule>(
        offsets[7],
        RegimenScheduleSchema.deserialize,
        allOffsets,
        RegimenSchedule(),
      ) ??
      [];
  object.totalTreatmentDays = reader.readLong(offsets[8]);
  object.treatmentStartDate = reader.readDateTime(offsets[9]);
  return object;
}

P _patientProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readObjectList<RegimenSchedule>(
            offset,
            RegimenScheduleSchema.deserialize,
            allOffsets,
            RegimenSchedule(),
          ) ??
          []) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _patientProfileGetId(PatientProfile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _patientProfileGetLinks(PatientProfile object) {
  return [];
}

void _patientProfileAttach(
    IsarCollection<dynamic> col, Id id, PatientProfile object) {
  object.id = id;
}

extension PatientProfileByIndex on IsarCollection<PatientProfile> {
  Future<PatientProfile?> getByNik(String nik) {
    return getByIndex(r'nik', [nik]);
  }

  PatientProfile? getByNikSync(String nik) {
    return getByIndexSync(r'nik', [nik]);
  }

  Future<bool> deleteByNik(String nik) {
    return deleteByIndex(r'nik', [nik]);
  }

  bool deleteByNikSync(String nik) {
    return deleteByIndexSync(r'nik', [nik]);
  }

  Future<List<PatientProfile?>> getAllByNik(List<String> nikValues) {
    final values = nikValues.map((e) => [e]).toList();
    return getAllByIndex(r'nik', values);
  }

  List<PatientProfile?> getAllByNikSync(List<String> nikValues) {
    final values = nikValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'nik', values);
  }

  Future<int> deleteAllByNik(List<String> nikValues) {
    final values = nikValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'nik', values);
  }

  int deleteAllByNikSync(List<String> nikValues) {
    final values = nikValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'nik', values);
  }

  Future<Id> putByNik(PatientProfile object) {
    return putByIndex(r'nik', object);
  }

  Id putByNikSync(PatientProfile object, {bool saveLinks = true}) {
    return putByIndexSync(r'nik', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNik(List<PatientProfile> objects) {
    return putAllByIndex(r'nik', objects);
  }

  List<Id> putAllByNikSync(List<PatientProfile> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'nik', objects, saveLinks: saveLinks);
  }
}

extension PatientProfileQueryWhereSort
    on QueryBuilder<PatientProfile, PatientProfile, QWhere> {
  QueryBuilder<PatientProfile, PatientProfile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PatientProfileQueryWhere
    on QueryBuilder<PatientProfile, PatientProfile, QWhereClause> {
  QueryBuilder<PatientProfile, PatientProfile, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PatientProfile, PatientProfile, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterWhereClause> idBetween(
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

  QueryBuilder<PatientProfile, PatientProfile, QAfterWhereClause> nikEqualTo(
      String nik) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nik',
        value: [nik],
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterWhereClause> nikNotEqualTo(
      String nik) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nik',
              lower: [],
              upper: [nik],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nik',
              lower: [nik],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nik',
              lower: [nik],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nik',
              lower: [],
              upper: [nik],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PatientProfileQueryFilter
    on QueryBuilder<PatientProfile, PatientProfile, QFilterCondition> {
  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      birthDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'birthDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      birthDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'birthDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      birthDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'birthDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      birthDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'birthDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      fullNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      fullNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      fullNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      fullNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fullName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      fullNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      fullNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      fullNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      fullNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fullName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
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

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
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

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      nikEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nik',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      nikGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nik',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      nikLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nik',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      nikBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nik',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      nikStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nik',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      nikEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nik',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      nikContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nik',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      nikMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nik',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      nikIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nik',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      nikIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nik',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      phoneNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      phoneNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      phoneNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      phoneNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phoneNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      phoneNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      phoneNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      phoneNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      phoneNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phoneNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      phoneNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phoneNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      phoneNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phoneNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      pmoNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pmoName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      pmoNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pmoName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      pmoNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pmoName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      pmoNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pmoName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      pmoNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pmoName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      pmoNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pmoName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      pmoNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pmoName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      pmoNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pmoName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      pmoNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pmoName',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      pmoNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pmoName',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      puskesmasNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'puskesmasName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      puskesmasNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'puskesmasName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      puskesmasNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'puskesmasName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      puskesmasNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'puskesmasName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      puskesmasNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'puskesmasName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      puskesmasNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'puskesmasName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      puskesmasNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'puskesmasName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      puskesmasNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'puskesmasName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      puskesmasNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'puskesmasName',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      puskesmasNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'puskesmasName',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      regimenCategoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'regimenCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      regimenCategoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'regimenCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      regimenCategoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'regimenCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      regimenCategoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'regimenCategory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      regimenCategoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'regimenCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      regimenCategoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'regimenCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      regimenCategoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'regimenCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      regimenCategoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'regimenCategory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      regimenCategoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'regimenCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      regimenCategoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'regimenCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      schedulesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'schedules',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      schedulesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'schedules',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      schedulesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'schedules',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      schedulesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'schedules',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      schedulesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'schedules',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      schedulesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'schedules',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      totalTreatmentDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalTreatmentDays',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      totalTreatmentDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalTreatmentDays',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      totalTreatmentDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalTreatmentDays',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      totalTreatmentDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalTreatmentDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      treatmentStartDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'treatmentStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      treatmentStartDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'treatmentStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      treatmentStartDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'treatmentStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      treatmentStartDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'treatmentStartDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PatientProfileQueryObject
    on QueryBuilder<PatientProfile, PatientProfile, QFilterCondition> {
  QueryBuilder<PatientProfile, PatientProfile, QAfterFilterCondition>
      schedulesElement(FilterQuery<RegimenSchedule> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'schedules');
    });
  }
}

extension PatientProfileQueryLinks
    on QueryBuilder<PatientProfile, PatientProfile, QFilterCondition> {}

extension PatientProfileQuerySortBy
    on QueryBuilder<PatientProfile, PatientProfile, QSortBy> {
  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy> sortByBirthDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthDate', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      sortByBirthDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthDate', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy> sortByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      sortByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy> sortByNik() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nik', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy> sortByNikDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nik', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      sortByPhoneNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      sortByPhoneNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy> sortByPmoName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pmoName', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      sortByPmoNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pmoName', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      sortByPuskesmasName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'puskesmasName', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      sortByPuskesmasNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'puskesmasName', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      sortByRegimenCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regimenCategory', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      sortByRegimenCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regimenCategory', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      sortByTotalTreatmentDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTreatmentDays', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      sortByTotalTreatmentDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTreatmentDays', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      sortByTreatmentStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'treatmentStartDate', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      sortByTreatmentStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'treatmentStartDate', Sort.desc);
    });
  }
}

extension PatientProfileQuerySortThenBy
    on QueryBuilder<PatientProfile, PatientProfile, QSortThenBy> {
  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy> thenByBirthDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthDate', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      thenByBirthDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthDate', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy> thenByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      thenByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy> thenByNik() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nik', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy> thenByNikDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nik', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      thenByPhoneNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      thenByPhoneNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy> thenByPmoName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pmoName', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      thenByPmoNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pmoName', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      thenByPuskesmasName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'puskesmasName', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      thenByPuskesmasNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'puskesmasName', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      thenByRegimenCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regimenCategory', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      thenByRegimenCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regimenCategory', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      thenByTotalTreatmentDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTreatmentDays', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      thenByTotalTreatmentDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTreatmentDays', Sort.desc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      thenByTreatmentStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'treatmentStartDate', Sort.asc);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QAfterSortBy>
      thenByTreatmentStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'treatmentStartDate', Sort.desc);
    });
  }
}

extension PatientProfileQueryWhereDistinct
    on QueryBuilder<PatientProfile, PatientProfile, QDistinct> {
  QueryBuilder<PatientProfile, PatientProfile, QDistinct>
      distinctByBirthDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'birthDate');
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QDistinct> distinctByFullName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QDistinct> distinctByNik(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nik', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QDistinct> distinctByPhoneNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phoneNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QDistinct> distinctByPmoName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pmoName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QDistinct>
      distinctByPuskesmasName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'puskesmasName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QDistinct>
      distinctByRegimenCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'regimenCategory',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QDistinct>
      distinctByTotalTreatmentDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalTreatmentDays');
    });
  }

  QueryBuilder<PatientProfile, PatientProfile, QDistinct>
      distinctByTreatmentStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'treatmentStartDate');
    });
  }
}

extension PatientProfileQueryProperty
    on QueryBuilder<PatientProfile, PatientProfile, QQueryProperty> {
  QueryBuilder<PatientProfile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PatientProfile, DateTime, QQueryOperations> birthDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'birthDate');
    });
  }

  QueryBuilder<PatientProfile, String, QQueryOperations> fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullName');
    });
  }

  QueryBuilder<PatientProfile, String, QQueryOperations> nikProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nik');
    });
  }

  QueryBuilder<PatientProfile, String, QQueryOperations> phoneNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phoneNumber');
    });
  }

  QueryBuilder<PatientProfile, String, QQueryOperations> pmoNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pmoName');
    });
  }

  QueryBuilder<PatientProfile, String, QQueryOperations>
      puskesmasNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'puskesmasName');
    });
  }

  QueryBuilder<PatientProfile, String, QQueryOperations>
      regimenCategoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'regimenCategory');
    });
  }

  QueryBuilder<PatientProfile, List<RegimenSchedule>, QQueryOperations>
      schedulesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schedules');
    });
  }

  QueryBuilder<PatientProfile, int, QQueryOperations>
      totalTreatmentDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalTreatmentDays');
    });
  }

  QueryBuilder<PatientProfile, DateTime, QQueryOperations>
      treatmentStartDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'treatmentStartDate');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const MedicineDetailSchema = Schema(
  name: r'MedicineDetail',
  id: 2382306744818312100,
  properties: {
    r'dosage': PropertySchema(
      id: 0,
      name: r'dosage',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _medicineDetailEstimateSize,
  serialize: _medicineDetailSerialize,
  deserialize: _medicineDetailDeserialize,
  deserializeProp: _medicineDetailDeserializeProp,
);

int _medicineDetailEstimateSize(
  MedicineDetail object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.dosage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _medicineDetailSerialize(
  MedicineDetail object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.dosage);
  writer.writeString(offsets[1], object.name);
}

MedicineDetail _medicineDetailDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicineDetail();
  object.dosage = reader.readStringOrNull(offsets[0]);
  object.name = reader.readStringOrNull(offsets[1]);
  return object;
}

P _medicineDetailDeserializeProp<P>(
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension MedicineDetailQueryFilter
    on QueryBuilder<MedicineDetail, MedicineDetail, QFilterCondition> {
  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      dosageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dosage',
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      dosageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dosage',
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      dosageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      dosageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      dosageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      dosageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dosage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      dosageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      dosageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      dosageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      dosageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dosage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      dosageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dosage',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      dosageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dosage',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineDetail, MedicineDetail, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension MedicineDetailQueryObject
    on QueryBuilder<MedicineDetail, MedicineDetail, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const RegimenScheduleSchema = Schema(
  name: r'RegimenSchedule',
  id: -4777529612481797970,
  properties: {
    r'medicines': PropertySchema(
      id: 0,
      name: r'medicines',
      type: IsarType.objectList,
      target: r'MedicineDetail',
    ),
    r'time': PropertySchema(
      id: 1,
      name: r'time',
      type: IsarType.string,
    )
  },
  estimateSize: _regimenScheduleEstimateSize,
  serialize: _regimenScheduleSerialize,
  deserialize: _regimenScheduleDeserialize,
  deserializeProp: _regimenScheduleDeserializeProp,
);

int _regimenScheduleEstimateSize(
  RegimenSchedule object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.medicines.length * 3;
  {
    final offsets = allOffsets[MedicineDetail]!;
    for (var i = 0; i < object.medicines.length; i++) {
      final value = object.medicines[i];
      bytesCount +=
          MedicineDetailSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.time;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _regimenScheduleSerialize(
  RegimenSchedule object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<MedicineDetail>(
    offsets[0],
    allOffsets,
    MedicineDetailSchema.serialize,
    object.medicines,
  );
  writer.writeString(offsets[1], object.time);
}

RegimenSchedule _regimenScheduleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RegimenSchedule();
  object.medicines = reader.readObjectList<MedicineDetail>(
        offsets[0],
        MedicineDetailSchema.deserialize,
        allOffsets,
        MedicineDetail(),
      ) ??
      [];
  object.time = reader.readStringOrNull(offsets[1]);
  return object;
}

P _regimenScheduleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<MedicineDetail>(
            offset,
            MedicineDetailSchema.deserialize,
            allOffsets,
            MedicineDetail(),
          ) ??
          []) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension RegimenScheduleQueryFilter
    on QueryBuilder<RegimenSchedule, RegimenSchedule, QFilterCondition> {
  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      medicinesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicines',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      medicinesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicines',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      medicinesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicines',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      medicinesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicines',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      medicinesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicines',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      medicinesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicines',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      timeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'time',
      ));
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      timeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'time',
      ));
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      timeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'time',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      timeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'time',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      timeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'time',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      timeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'time',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      timeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'time',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      timeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'time',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      timeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'time',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      timeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'time',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      timeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'time',
        value: '',
      ));
    });
  }

  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      timeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'time',
        value: '',
      ));
    });
  }
}

extension RegimenScheduleQueryObject
    on QueryBuilder<RegimenSchedule, RegimenSchedule, QFilterCondition> {
  QueryBuilder<RegimenSchedule, RegimenSchedule, QAfterFilterCondition>
      medicinesElement(FilterQuery<MedicineDetail> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'medicines');
    });
  }
}
