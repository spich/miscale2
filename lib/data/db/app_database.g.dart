// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<int> sex = GeneratedColumn<int>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<int> heightCm = GeneratedColumn<int>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minWeightKgMeta = const VerificationMeta(
    'minWeightKg',
  );
  @override
  late final GeneratedColumn<double> minWeightKg = GeneratedColumn<double>(
    'min_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxWeightKgMeta = const VerificationMeta(
    'maxWeightKg',
  );
  @override
  late final GeneratedColumn<double> maxWeightKg = GeneratedColumn<double>(
    'max_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncToHealthMeta = const VerificationMeta(
    'syncToHealth',
  );
  @override
  late final GeneratedColumn<bool> syncToHealth = GeneratedColumn<bool>(
    'sync_to_health',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_to_health" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sex,
    birthDate,
    heightCm,
    minWeightKg,
    maxWeightKg,
    syncToHealth,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('min_weight_kg')) {
      context.handle(
        _minWeightKgMeta,
        minWeightKg.isAcceptableOrUnknown(
          data['min_weight_kg']!,
          _minWeightKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minWeightKgMeta);
    }
    if (data.containsKey('max_weight_kg')) {
      context.handle(
        _maxWeightKgMeta,
        maxWeightKg.isAcceptableOrUnknown(
          data['max_weight_kg']!,
          _maxWeightKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maxWeightKgMeta);
    }
    if (data.containsKey('sync_to_health')) {
      context.handle(
        _syncToHealthMeta,
        syncToHealth.isAcceptableOrUnknown(
          data['sync_to_health']!,
          _syncToHealthMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sex'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height_cm'],
      )!,
      minWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_weight_kg'],
      )!,
      maxWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_weight_kg'],
      )!,
      syncToHealth: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_to_health'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String name;

  /// 0 = muško, 1 = žensko (indeks u `Sex`).
  final int sex;
  final DateTime birthDate;
  final int heightCm;
  final double minWeightKg;
  final double maxWeightKg;

  /// Samo jedan profil smije pisati u Apple Health / Health Connect, jer su
  /// to podaci vlasnika uređaja.
  final bool syncToHealth;
  final DateTime createdAt;
  const Profile({
    required this.id,
    required this.name,
    required this.sex,
    required this.birthDate,
    required this.heightCm,
    required this.minWeightKg,
    required this.maxWeightKg,
    required this.syncToHealth,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sex'] = Variable<int>(sex);
    map['birth_date'] = Variable<DateTime>(birthDate);
    map['height_cm'] = Variable<int>(heightCm);
    map['min_weight_kg'] = Variable<double>(minWeightKg);
    map['max_weight_kg'] = Variable<double>(maxWeightKg);
    map['sync_to_health'] = Variable<bool>(syncToHealth);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      sex: Value(sex),
      birthDate: Value(birthDate),
      heightCm: Value(heightCm),
      minWeightKg: Value(minWeightKg),
      maxWeightKg: Value(maxWeightKg),
      syncToHealth: Value(syncToHealth),
      createdAt: Value(createdAt),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sex: serializer.fromJson<int>(json['sex']),
      birthDate: serializer.fromJson<DateTime>(json['birthDate']),
      heightCm: serializer.fromJson<int>(json['heightCm']),
      minWeightKg: serializer.fromJson<double>(json['minWeightKg']),
      maxWeightKg: serializer.fromJson<double>(json['maxWeightKg']),
      syncToHealth: serializer.fromJson<bool>(json['syncToHealth']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sex': serializer.toJson<int>(sex),
      'birthDate': serializer.toJson<DateTime>(birthDate),
      'heightCm': serializer.toJson<int>(heightCm),
      'minWeightKg': serializer.toJson<double>(minWeightKg),
      'maxWeightKg': serializer.toJson<double>(maxWeightKg),
      'syncToHealth': serializer.toJson<bool>(syncToHealth),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Profile copyWith({
    int? id,
    String? name,
    int? sex,
    DateTime? birthDate,
    int? heightCm,
    double? minWeightKg,
    double? maxWeightKg,
    bool? syncToHealth,
    DateTime? createdAt,
  }) => Profile(
    id: id ?? this.id,
    name: name ?? this.name,
    sex: sex ?? this.sex,
    birthDate: birthDate ?? this.birthDate,
    heightCm: heightCm ?? this.heightCm,
    minWeightKg: minWeightKg ?? this.minWeightKg,
    maxWeightKg: maxWeightKg ?? this.maxWeightKg,
    syncToHealth: syncToHealth ?? this.syncToHealth,
    createdAt: createdAt ?? this.createdAt,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sex: data.sex.present ? data.sex.value : this.sex,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      minWeightKg: data.minWeightKg.present
          ? data.minWeightKg.value
          : this.minWeightKg,
      maxWeightKg: data.maxWeightKg.present
          ? data.maxWeightKg.value
          : this.maxWeightKg,
      syncToHealth: data.syncToHealth.present
          ? data.syncToHealth.value
          : this.syncToHealth,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('heightCm: $heightCm, ')
          ..write('minWeightKg: $minWeightKg, ')
          ..write('maxWeightKg: $maxWeightKg, ')
          ..write('syncToHealth: $syncToHealth, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sex,
    birthDate,
    heightCm,
    minWeightKg,
    maxWeightKg,
    syncToHealth,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.name == this.name &&
          other.sex == this.sex &&
          other.birthDate == this.birthDate &&
          other.heightCm == this.heightCm &&
          other.minWeightKg == this.minWeightKg &&
          other.maxWeightKg == this.maxWeightKg &&
          other.syncToHealth == this.syncToHealth &&
          other.createdAt == this.createdAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sex;
  final Value<DateTime> birthDate;
  final Value<int> heightCm;
  final Value<double> minWeightKg;
  final Value<double> maxWeightKg;
  final Value<bool> syncToHealth;
  final Value<DateTime> createdAt;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.minWeightKg = const Value.absent(),
    this.maxWeightKg = const Value.absent(),
    this.syncToHealth = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int sex,
    required DateTime birthDate,
    required int heightCm,
    required double minWeightKg,
    required double maxWeightKg,
    this.syncToHealth = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       sex = Value(sex),
       birthDate = Value(birthDate),
       heightCm = Value(heightCm),
       minWeightKg = Value(minWeightKg),
       maxWeightKg = Value(maxWeightKg);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sex,
    Expression<DateTime>? birthDate,
    Expression<int>? heightCm,
    Expression<double>? minWeightKg,
    Expression<double>? maxWeightKg,
    Expression<bool>? syncToHealth,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sex != null) 'sex': sex,
      if (birthDate != null) 'birth_date': birthDate,
      if (heightCm != null) 'height_cm': heightCm,
      if (minWeightKg != null) 'min_weight_kg': minWeightKg,
      if (maxWeightKg != null) 'max_weight_kg': maxWeightKg,
      if (syncToHealth != null) 'sync_to_health': syncToHealth,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? sex,
    Value<DateTime>? birthDate,
    Value<int>? heightCm,
    Value<double>? minWeightKg,
    Value<double>? maxWeightKg,
    Value<bool>? syncToHealth,
    Value<DateTime>? createdAt,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      minWeightKg: minWeightKg ?? this.minWeightKg,
      maxWeightKg: maxWeightKg ?? this.maxWeightKg,
      syncToHealth: syncToHealth ?? this.syncToHealth,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sex.present) {
      map['sex'] = Variable<int>(sex.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<int>(heightCm.value);
    }
    if (minWeightKg.present) {
      map['min_weight_kg'] = Variable<double>(minWeightKg.value);
    }
    if (maxWeightKg.present) {
      map['max_weight_kg'] = Variable<double>(maxWeightKg.value);
    }
    if (syncToHealth.present) {
      map['sync_to_health'] = Variable<bool>(syncToHealth.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('heightCm: $heightCm, ')
          ..write('minWeightKg: $minWeightKg, ')
          ..write('maxWeightKg: $maxWeightKg, ')
          ..write('syncToHealth: $syncToHealth, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MeasurementsTable extends Measurements
    with TableInfo<$MeasurementsTable, Measurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<DateTime> measuredAt = GeneratedColumn<DateTime>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _impedanceMeta = const VerificationMeta(
    'impedance',
  );
  @override
  late final GeneratedColumn<int> impedance = GeneratedColumn<int>(
    'impedance',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bmiMeta = const VerificationMeta('bmi');
  @override
  late final GeneratedColumn<double> bmi = GeneratedColumn<double>(
    'bmi',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatPercentageMeta = const VerificationMeta(
    'fatPercentage',
  );
  @override
  late final GeneratedColumn<double> fatPercentage = GeneratedColumn<double>(
    'fat_percentage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waterPercentageMeta = const VerificationMeta(
    'waterPercentage',
  );
  @override
  late final GeneratedColumn<double> waterPercentage = GeneratedColumn<double>(
    'water_percentage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muscleMassKgMeta = const VerificationMeta(
    'muscleMassKg',
  );
  @override
  late final GeneratedColumn<double> muscleMassKg = GeneratedColumn<double>(
    'muscle_mass_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boneMassKgMeta = const VerificationMeta(
    'boneMassKg',
  );
  @override
  late final GeneratedColumn<double> boneMassKg = GeneratedColumn<double>(
    'bone_mass_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leanBodyMassKgMeta = const VerificationMeta(
    'leanBodyMassKg',
  );
  @override
  late final GeneratedColumn<double> leanBodyMassKg = GeneratedColumn<double>(
    'lean_body_mass_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinPercentageMeta = const VerificationMeta(
    'proteinPercentage',
  );
  @override
  late final GeneratedColumn<double> proteinPercentage =
      GeneratedColumn<double>(
        'protein_percentage',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _visceralFatMeta = const VerificationMeta(
    'visceralFat',
  );
  @override
  late final GeneratedColumn<double> visceralFat = GeneratedColumn<double>(
    'visceral_fat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _basalMetabolicRateMeta =
      const VerificationMeta('basalMetabolicRate');
  @override
  late final GeneratedColumn<double> basalMetabolicRate =
      GeneratedColumn<double>(
        'basal_metabolic_rate',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _metabolicAgeMeta = const VerificationMeta(
    'metabolicAge',
  );
  @override
  late final GeneratedColumn<double> metabolicAge = GeneratedColumn<double>(
    'metabolic_age',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedToHealthMeta = const VerificationMeta(
    'syncedToHealth',
  );
  @override
  late final GeneratedColumn<bool> syncedToHealth = GeneratedColumn<bool>(
    'synced_to_health',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced_to_health" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    measuredAt,
    weightKg,
    impedance,
    bmi,
    fatPercentage,
    waterPercentage,
    muscleMassKg,
    boneMassKg,
    leanBodyMassKg,
    proteinPercentage,
    visceralFat,
    basalMetabolicRate,
    metabolicAge,
    syncedToHealth,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Measurement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('impedance')) {
      context.handle(
        _impedanceMeta,
        impedance.isAcceptableOrUnknown(data['impedance']!, _impedanceMeta),
      );
    }
    if (data.containsKey('bmi')) {
      context.handle(
        _bmiMeta,
        bmi.isAcceptableOrUnknown(data['bmi']!, _bmiMeta),
      );
    }
    if (data.containsKey('fat_percentage')) {
      context.handle(
        _fatPercentageMeta,
        fatPercentage.isAcceptableOrUnknown(
          data['fat_percentage']!,
          _fatPercentageMeta,
        ),
      );
    }
    if (data.containsKey('water_percentage')) {
      context.handle(
        _waterPercentageMeta,
        waterPercentage.isAcceptableOrUnknown(
          data['water_percentage']!,
          _waterPercentageMeta,
        ),
      );
    }
    if (data.containsKey('muscle_mass_kg')) {
      context.handle(
        _muscleMassKgMeta,
        muscleMassKg.isAcceptableOrUnknown(
          data['muscle_mass_kg']!,
          _muscleMassKgMeta,
        ),
      );
    }
    if (data.containsKey('bone_mass_kg')) {
      context.handle(
        _boneMassKgMeta,
        boneMassKg.isAcceptableOrUnknown(
          data['bone_mass_kg']!,
          _boneMassKgMeta,
        ),
      );
    }
    if (data.containsKey('lean_body_mass_kg')) {
      context.handle(
        _leanBodyMassKgMeta,
        leanBodyMassKg.isAcceptableOrUnknown(
          data['lean_body_mass_kg']!,
          _leanBodyMassKgMeta,
        ),
      );
    }
    if (data.containsKey('protein_percentage')) {
      context.handle(
        _proteinPercentageMeta,
        proteinPercentage.isAcceptableOrUnknown(
          data['protein_percentage']!,
          _proteinPercentageMeta,
        ),
      );
    }
    if (data.containsKey('visceral_fat')) {
      context.handle(
        _visceralFatMeta,
        visceralFat.isAcceptableOrUnknown(
          data['visceral_fat']!,
          _visceralFatMeta,
        ),
      );
    }
    if (data.containsKey('basal_metabolic_rate')) {
      context.handle(
        _basalMetabolicRateMeta,
        basalMetabolicRate.isAcceptableOrUnknown(
          data['basal_metabolic_rate']!,
          _basalMetabolicRateMeta,
        ),
      );
    }
    if (data.containsKey('metabolic_age')) {
      context.handle(
        _metabolicAgeMeta,
        metabolicAge.isAcceptableOrUnknown(
          data['metabolic_age']!,
          _metabolicAgeMeta,
        ),
      );
    }
    if (data.containsKey('synced_to_health')) {
      context.handle(
        _syncedToHealthMeta,
        syncedToHealth.isAcceptableOrUnknown(
          data['synced_to_health']!,
          _syncedToHealthMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {profileId, measuredAt},
  ];
  @override
  Measurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Measurement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}measured_at'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      impedance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}impedance'],
      ),
      bmi: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bmi'],
      ),
      fatPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_percentage'],
      ),
      waterPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}water_percentage'],
      ),
      muscleMassKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}muscle_mass_kg'],
      ),
      boneMassKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bone_mass_kg'],
      ),
      leanBodyMassKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lean_body_mass_kg'],
      ),
      proteinPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_percentage'],
      ),
      visceralFat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}visceral_fat'],
      ),
      basalMetabolicRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}basal_metabolic_rate'],
      ),
      metabolicAge: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}metabolic_age'],
      ),
      syncedToHealth: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced_to_health'],
      )!,
    );
  }

  @override
  $MeasurementsTable createAlias(String alias) {
    return $MeasurementsTable(attachedDatabase, alias);
  }
}

class Measurement extends DataClass implements Insertable<Measurement> {
  final int id;
  final int profileId;
  final DateTime measuredAt;
  final double weightKg;
  final int? impedance;
  final double? bmi;
  final double? fatPercentage;
  final double? waterPercentage;
  final double? muscleMassKg;
  final double? boneMassKg;
  final double? leanBodyMassKg;
  final double? proteinPercentage;
  final double? visceralFat;
  final double? basalMetabolicRate;
  final double? metabolicAge;
  final bool syncedToHealth;
  const Measurement({
    required this.id,
    required this.profileId,
    required this.measuredAt,
    required this.weightKg,
    this.impedance,
    this.bmi,
    this.fatPercentage,
    this.waterPercentage,
    this.muscleMassKg,
    this.boneMassKg,
    this.leanBodyMassKg,
    this.proteinPercentage,
    this.visceralFat,
    this.basalMetabolicRate,
    this.metabolicAge,
    required this.syncedToHealth,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['measured_at'] = Variable<DateTime>(measuredAt);
    map['weight_kg'] = Variable<double>(weightKg);
    if (!nullToAbsent || impedance != null) {
      map['impedance'] = Variable<int>(impedance);
    }
    if (!nullToAbsent || bmi != null) {
      map['bmi'] = Variable<double>(bmi);
    }
    if (!nullToAbsent || fatPercentage != null) {
      map['fat_percentage'] = Variable<double>(fatPercentage);
    }
    if (!nullToAbsent || waterPercentage != null) {
      map['water_percentage'] = Variable<double>(waterPercentage);
    }
    if (!nullToAbsent || muscleMassKg != null) {
      map['muscle_mass_kg'] = Variable<double>(muscleMassKg);
    }
    if (!nullToAbsent || boneMassKg != null) {
      map['bone_mass_kg'] = Variable<double>(boneMassKg);
    }
    if (!nullToAbsent || leanBodyMassKg != null) {
      map['lean_body_mass_kg'] = Variable<double>(leanBodyMassKg);
    }
    if (!nullToAbsent || proteinPercentage != null) {
      map['protein_percentage'] = Variable<double>(proteinPercentage);
    }
    if (!nullToAbsent || visceralFat != null) {
      map['visceral_fat'] = Variable<double>(visceralFat);
    }
    if (!nullToAbsent || basalMetabolicRate != null) {
      map['basal_metabolic_rate'] = Variable<double>(basalMetabolicRate);
    }
    if (!nullToAbsent || metabolicAge != null) {
      map['metabolic_age'] = Variable<double>(metabolicAge);
    }
    map['synced_to_health'] = Variable<bool>(syncedToHealth);
    return map;
  }

  MeasurementsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      measuredAt: Value(measuredAt),
      weightKg: Value(weightKg),
      impedance: impedance == null && nullToAbsent
          ? const Value.absent()
          : Value(impedance),
      bmi: bmi == null && nullToAbsent ? const Value.absent() : Value(bmi),
      fatPercentage: fatPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(fatPercentage),
      waterPercentage: waterPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(waterPercentage),
      muscleMassKg: muscleMassKg == null && nullToAbsent
          ? const Value.absent()
          : Value(muscleMassKg),
      boneMassKg: boneMassKg == null && nullToAbsent
          ? const Value.absent()
          : Value(boneMassKg),
      leanBodyMassKg: leanBodyMassKg == null && nullToAbsent
          ? const Value.absent()
          : Value(leanBodyMassKg),
      proteinPercentage: proteinPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinPercentage),
      visceralFat: visceralFat == null && nullToAbsent
          ? const Value.absent()
          : Value(visceralFat),
      basalMetabolicRate: basalMetabolicRate == null && nullToAbsent
          ? const Value.absent()
          : Value(basalMetabolicRate),
      metabolicAge: metabolicAge == null && nullToAbsent
          ? const Value.absent()
          : Value(metabolicAge),
      syncedToHealth: Value(syncedToHealth),
    );
  }

  factory Measurement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Measurement(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      measuredAt: serializer.fromJson<DateTime>(json['measuredAt']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      impedance: serializer.fromJson<int?>(json['impedance']),
      bmi: serializer.fromJson<double?>(json['bmi']),
      fatPercentage: serializer.fromJson<double?>(json['fatPercentage']),
      waterPercentage: serializer.fromJson<double?>(json['waterPercentage']),
      muscleMassKg: serializer.fromJson<double?>(json['muscleMassKg']),
      boneMassKg: serializer.fromJson<double?>(json['boneMassKg']),
      leanBodyMassKg: serializer.fromJson<double?>(json['leanBodyMassKg']),
      proteinPercentage: serializer.fromJson<double?>(
        json['proteinPercentage'],
      ),
      visceralFat: serializer.fromJson<double?>(json['visceralFat']),
      basalMetabolicRate: serializer.fromJson<double?>(
        json['basalMetabolicRate'],
      ),
      metabolicAge: serializer.fromJson<double?>(json['metabolicAge']),
      syncedToHealth: serializer.fromJson<bool>(json['syncedToHealth']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'measuredAt': serializer.toJson<DateTime>(measuredAt),
      'weightKg': serializer.toJson<double>(weightKg),
      'impedance': serializer.toJson<int?>(impedance),
      'bmi': serializer.toJson<double?>(bmi),
      'fatPercentage': serializer.toJson<double?>(fatPercentage),
      'waterPercentage': serializer.toJson<double?>(waterPercentage),
      'muscleMassKg': serializer.toJson<double?>(muscleMassKg),
      'boneMassKg': serializer.toJson<double?>(boneMassKg),
      'leanBodyMassKg': serializer.toJson<double?>(leanBodyMassKg),
      'proteinPercentage': serializer.toJson<double?>(proteinPercentage),
      'visceralFat': serializer.toJson<double?>(visceralFat),
      'basalMetabolicRate': serializer.toJson<double?>(basalMetabolicRate),
      'metabolicAge': serializer.toJson<double?>(metabolicAge),
      'syncedToHealth': serializer.toJson<bool>(syncedToHealth),
    };
  }

  Measurement copyWith({
    int? id,
    int? profileId,
    DateTime? measuredAt,
    double? weightKg,
    Value<int?> impedance = const Value.absent(),
    Value<double?> bmi = const Value.absent(),
    Value<double?> fatPercentage = const Value.absent(),
    Value<double?> waterPercentage = const Value.absent(),
    Value<double?> muscleMassKg = const Value.absent(),
    Value<double?> boneMassKg = const Value.absent(),
    Value<double?> leanBodyMassKg = const Value.absent(),
    Value<double?> proteinPercentage = const Value.absent(),
    Value<double?> visceralFat = const Value.absent(),
    Value<double?> basalMetabolicRate = const Value.absent(),
    Value<double?> metabolicAge = const Value.absent(),
    bool? syncedToHealth,
  }) => Measurement(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    measuredAt: measuredAt ?? this.measuredAt,
    weightKg: weightKg ?? this.weightKg,
    impedance: impedance.present ? impedance.value : this.impedance,
    bmi: bmi.present ? bmi.value : this.bmi,
    fatPercentage: fatPercentage.present
        ? fatPercentage.value
        : this.fatPercentage,
    waterPercentage: waterPercentage.present
        ? waterPercentage.value
        : this.waterPercentage,
    muscleMassKg: muscleMassKg.present ? muscleMassKg.value : this.muscleMassKg,
    boneMassKg: boneMassKg.present ? boneMassKg.value : this.boneMassKg,
    leanBodyMassKg: leanBodyMassKg.present
        ? leanBodyMassKg.value
        : this.leanBodyMassKg,
    proteinPercentage: proteinPercentage.present
        ? proteinPercentage.value
        : this.proteinPercentage,
    visceralFat: visceralFat.present ? visceralFat.value : this.visceralFat,
    basalMetabolicRate: basalMetabolicRate.present
        ? basalMetabolicRate.value
        : this.basalMetabolicRate,
    metabolicAge: metabolicAge.present ? metabolicAge.value : this.metabolicAge,
    syncedToHealth: syncedToHealth ?? this.syncedToHealth,
  );
  Measurement copyWithCompanion(MeasurementsCompanion data) {
    return Measurement(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      impedance: data.impedance.present ? data.impedance.value : this.impedance,
      bmi: data.bmi.present ? data.bmi.value : this.bmi,
      fatPercentage: data.fatPercentage.present
          ? data.fatPercentage.value
          : this.fatPercentage,
      waterPercentage: data.waterPercentage.present
          ? data.waterPercentage.value
          : this.waterPercentage,
      muscleMassKg: data.muscleMassKg.present
          ? data.muscleMassKg.value
          : this.muscleMassKg,
      boneMassKg: data.boneMassKg.present
          ? data.boneMassKg.value
          : this.boneMassKg,
      leanBodyMassKg: data.leanBodyMassKg.present
          ? data.leanBodyMassKg.value
          : this.leanBodyMassKg,
      proteinPercentage: data.proteinPercentage.present
          ? data.proteinPercentage.value
          : this.proteinPercentage,
      visceralFat: data.visceralFat.present
          ? data.visceralFat.value
          : this.visceralFat,
      basalMetabolicRate: data.basalMetabolicRate.present
          ? data.basalMetabolicRate.value
          : this.basalMetabolicRate,
      metabolicAge: data.metabolicAge.present
          ? data.metabolicAge.value
          : this.metabolicAge,
      syncedToHealth: data.syncedToHealth.present
          ? data.syncedToHealth.value
          : this.syncedToHealth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Measurement(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('impedance: $impedance, ')
          ..write('bmi: $bmi, ')
          ..write('fatPercentage: $fatPercentage, ')
          ..write('waterPercentage: $waterPercentage, ')
          ..write('muscleMassKg: $muscleMassKg, ')
          ..write('boneMassKg: $boneMassKg, ')
          ..write('leanBodyMassKg: $leanBodyMassKg, ')
          ..write('proteinPercentage: $proteinPercentage, ')
          ..write('visceralFat: $visceralFat, ')
          ..write('basalMetabolicRate: $basalMetabolicRate, ')
          ..write('metabolicAge: $metabolicAge, ')
          ..write('syncedToHealth: $syncedToHealth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    measuredAt,
    weightKg,
    impedance,
    bmi,
    fatPercentage,
    waterPercentage,
    muscleMassKg,
    boneMassKg,
    leanBodyMassKg,
    proteinPercentage,
    visceralFat,
    basalMetabolicRate,
    metabolicAge,
    syncedToHealth,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Measurement &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.measuredAt == this.measuredAt &&
          other.weightKg == this.weightKg &&
          other.impedance == this.impedance &&
          other.bmi == this.bmi &&
          other.fatPercentage == this.fatPercentage &&
          other.waterPercentage == this.waterPercentage &&
          other.muscleMassKg == this.muscleMassKg &&
          other.boneMassKg == this.boneMassKg &&
          other.leanBodyMassKg == this.leanBodyMassKg &&
          other.proteinPercentage == this.proteinPercentage &&
          other.visceralFat == this.visceralFat &&
          other.basalMetabolicRate == this.basalMetabolicRate &&
          other.metabolicAge == this.metabolicAge &&
          other.syncedToHealth == this.syncedToHealth);
}

class MeasurementsCompanion extends UpdateCompanion<Measurement> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<DateTime> measuredAt;
  final Value<double> weightKg;
  final Value<int?> impedance;
  final Value<double?> bmi;
  final Value<double?> fatPercentage;
  final Value<double?> waterPercentage;
  final Value<double?> muscleMassKg;
  final Value<double?> boneMassKg;
  final Value<double?> leanBodyMassKg;
  final Value<double?> proteinPercentage;
  final Value<double?> visceralFat;
  final Value<double?> basalMetabolicRate;
  final Value<double?> metabolicAge;
  final Value<bool> syncedToHealth;
  const MeasurementsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.impedance = const Value.absent(),
    this.bmi = const Value.absent(),
    this.fatPercentage = const Value.absent(),
    this.waterPercentage = const Value.absent(),
    this.muscleMassKg = const Value.absent(),
    this.boneMassKg = const Value.absent(),
    this.leanBodyMassKg = const Value.absent(),
    this.proteinPercentage = const Value.absent(),
    this.visceralFat = const Value.absent(),
    this.basalMetabolicRate = const Value.absent(),
    this.metabolicAge = const Value.absent(),
    this.syncedToHealth = const Value.absent(),
  });
  MeasurementsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required DateTime measuredAt,
    required double weightKg,
    this.impedance = const Value.absent(),
    this.bmi = const Value.absent(),
    this.fatPercentage = const Value.absent(),
    this.waterPercentage = const Value.absent(),
    this.muscleMassKg = const Value.absent(),
    this.boneMassKg = const Value.absent(),
    this.leanBodyMassKg = const Value.absent(),
    this.proteinPercentage = const Value.absent(),
    this.visceralFat = const Value.absent(),
    this.basalMetabolicRate = const Value.absent(),
    this.metabolicAge = const Value.absent(),
    this.syncedToHealth = const Value.absent(),
  }) : profileId = Value(profileId),
       measuredAt = Value(measuredAt),
       weightKg = Value(weightKg);
  static Insertable<Measurement> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<DateTime>? measuredAt,
    Expression<double>? weightKg,
    Expression<int>? impedance,
    Expression<double>? bmi,
    Expression<double>? fatPercentage,
    Expression<double>? waterPercentage,
    Expression<double>? muscleMassKg,
    Expression<double>? boneMassKg,
    Expression<double>? leanBodyMassKg,
    Expression<double>? proteinPercentage,
    Expression<double>? visceralFat,
    Expression<double>? basalMetabolicRate,
    Expression<double>? metabolicAge,
    Expression<bool>? syncedToHealth,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (weightKg != null) 'weight_kg': weightKg,
      if (impedance != null) 'impedance': impedance,
      if (bmi != null) 'bmi': bmi,
      if (fatPercentage != null) 'fat_percentage': fatPercentage,
      if (waterPercentage != null) 'water_percentage': waterPercentage,
      if (muscleMassKg != null) 'muscle_mass_kg': muscleMassKg,
      if (boneMassKg != null) 'bone_mass_kg': boneMassKg,
      if (leanBodyMassKg != null) 'lean_body_mass_kg': leanBodyMassKg,
      if (proteinPercentage != null) 'protein_percentage': proteinPercentage,
      if (visceralFat != null) 'visceral_fat': visceralFat,
      if (basalMetabolicRate != null)
        'basal_metabolic_rate': basalMetabolicRate,
      if (metabolicAge != null) 'metabolic_age': metabolicAge,
      if (syncedToHealth != null) 'synced_to_health': syncedToHealth,
    });
  }

  MeasurementsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<DateTime>? measuredAt,
    Value<double>? weightKg,
    Value<int?>? impedance,
    Value<double?>? bmi,
    Value<double?>? fatPercentage,
    Value<double?>? waterPercentage,
    Value<double?>? muscleMassKg,
    Value<double?>? boneMassKg,
    Value<double?>? leanBodyMassKg,
    Value<double?>? proteinPercentage,
    Value<double?>? visceralFat,
    Value<double?>? basalMetabolicRate,
    Value<double?>? metabolicAge,
    Value<bool>? syncedToHealth,
  }) {
    return MeasurementsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      measuredAt: measuredAt ?? this.measuredAt,
      weightKg: weightKg ?? this.weightKg,
      impedance: impedance ?? this.impedance,
      bmi: bmi ?? this.bmi,
      fatPercentage: fatPercentage ?? this.fatPercentage,
      waterPercentage: waterPercentage ?? this.waterPercentage,
      muscleMassKg: muscleMassKg ?? this.muscleMassKg,
      boneMassKg: boneMassKg ?? this.boneMassKg,
      leanBodyMassKg: leanBodyMassKg ?? this.leanBodyMassKg,
      proteinPercentage: proteinPercentage ?? this.proteinPercentage,
      visceralFat: visceralFat ?? this.visceralFat,
      basalMetabolicRate: basalMetabolicRate ?? this.basalMetabolicRate,
      metabolicAge: metabolicAge ?? this.metabolicAge,
      syncedToHealth: syncedToHealth ?? this.syncedToHealth,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<DateTime>(measuredAt.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (impedance.present) {
      map['impedance'] = Variable<int>(impedance.value);
    }
    if (bmi.present) {
      map['bmi'] = Variable<double>(bmi.value);
    }
    if (fatPercentage.present) {
      map['fat_percentage'] = Variable<double>(fatPercentage.value);
    }
    if (waterPercentage.present) {
      map['water_percentage'] = Variable<double>(waterPercentage.value);
    }
    if (muscleMassKg.present) {
      map['muscle_mass_kg'] = Variable<double>(muscleMassKg.value);
    }
    if (boneMassKg.present) {
      map['bone_mass_kg'] = Variable<double>(boneMassKg.value);
    }
    if (leanBodyMassKg.present) {
      map['lean_body_mass_kg'] = Variable<double>(leanBodyMassKg.value);
    }
    if (proteinPercentage.present) {
      map['protein_percentage'] = Variable<double>(proteinPercentage.value);
    }
    if (visceralFat.present) {
      map['visceral_fat'] = Variable<double>(visceralFat.value);
    }
    if (basalMetabolicRate.present) {
      map['basal_metabolic_rate'] = Variable<double>(basalMetabolicRate.value);
    }
    if (metabolicAge.present) {
      map['metabolic_age'] = Variable<double>(metabolicAge.value);
    }
    if (syncedToHealth.present) {
      map['synced_to_health'] = Variable<bool>(syncedToHealth.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('impedance: $impedance, ')
          ..write('bmi: $bmi, ')
          ..write('fatPercentage: $fatPercentage, ')
          ..write('waterPercentage: $waterPercentage, ')
          ..write('muscleMassKg: $muscleMassKg, ')
          ..write('boneMassKg: $boneMassKg, ')
          ..write('leanBodyMassKg: $leanBodyMassKg, ')
          ..write('proteinPercentage: $proteinPercentage, ')
          ..write('visceralFat: $visceralFat, ')
          ..write('basalMetabolicRate: $basalMetabolicRate, ')
          ..write('metabolicAge: $metabolicAge, ')
          ..write('syncedToHealth: $syncedToHealth')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $MeasurementsTable measurements = $MeasurementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [profiles, measurements];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('measurements', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  required String name,
  required int sex,
  required DateTime birthDate,
  required int heightCm,
  required double minWeightKg,
  required double maxWeightKg,
  Value<bool> syncToHealth,
  Value<DateTime> createdAt,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> sex,
  Value<DateTime> birthDate,
  Value<int> heightCm,
  Value<double> minWeightKg,
  Value<double> maxWeightKg,
  Value<bool> syncToHealth,
  Value<DateTime> createdAt,
});

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MeasurementsTable, List<Measurement>>
  _measurementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.measurements,
    aliasName: 'profiles__id__measurements__profile_id',
  );

  $$MeasurementsTableProcessedTableManager get measurementsRefs {
    final manager = $$MeasurementsTableTableManager(
      $_db,
      $_db.measurements,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_measurementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minWeightKg => $composableBuilder(
    column: $table.minWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxWeightKg => $composableBuilder(
    column: $table.maxWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncToHealth => $composableBuilder(
    column: $table.syncToHealth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> measurementsRefs(
    Expression<bool> Function($$MeasurementsTableFilterComposer f) f,
  ) {
    final $$MeasurementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurements,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementsTableFilterComposer(
            $db: $db,
            $table: $db.measurements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minWeightKg => $composableBuilder(
    column: $table.minWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxWeightKg => $composableBuilder(
    column: $table.maxWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncToHealth => $composableBuilder(
    column: $table.syncToHealth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<int> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get minWeightKg => $composableBuilder(
    column: $table.minWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxWeightKg => $composableBuilder(
    column: $table.maxWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get syncToHealth => $composableBuilder(
    column: $table.syncToHealth,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> measurementsRefs<T extends Object>(
    Expression<T> Function($$MeasurementsTableAnnotationComposer a) f,
  ) {
    final $$MeasurementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurements,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementsTableAnnotationComposer(
            $db: $db,
            $table: $db.measurements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, $$ProfilesTableReferences),
          Profile,
          PrefetchHooks Function({bool measurementsRefs})
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sex = const Value.absent(),
                Value<DateTime> birthDate = const Value.absent(),
                Value<int> heightCm = const Value.absent(),
                Value<double> minWeightKg = const Value.absent(),
                Value<double> maxWeightKg = const Value.absent(),
                Value<bool> syncToHealth = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                name: name,
                sex: sex,
                birthDate: birthDate,
                heightCm: heightCm,
                minWeightKg: minWeightKg,
                maxWeightKg: maxWeightKg,
                syncToHealth: syncToHealth,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int sex,
                required DateTime birthDate,
                required int heightCm,
                required double minWeightKg,
                required double maxWeightKg,
                Value<bool> syncToHealth = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                name: name,
                sex: sex,
                birthDate: birthDate,
                heightCm: heightCm,
                minWeightKg: minWeightKg,
                maxWeightKg: maxWeightKg,
                syncToHealth: syncToHealth,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, Profile>(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({measurementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (measurementsRefs) db.measurements],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (measurementsRefs)
                    await $_getPrefetchedData<
                      Profile,
                      $ProfilesTable,
                      Measurement
                    >(
                      currentTable: table,
                      referencedTable: $$ProfilesTableReferences
                          ._measurementsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ProfilesTableReferences(
                        db,
                        table,
                        p0,
                      ).measurementsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.profileId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, $$ProfilesTableReferences),
      Profile,
      PrefetchHooks Function({bool measurementsRefs})
    >;
typedef $$MeasurementsTableCreateCompanionBuilder =
    MeasurementsCompanion Function({
      Value<int> id,
      required int profileId,
      required DateTime measuredAt,
      required double weightKg,
      Value<int?> impedance,
      Value<double?> bmi,
      Value<double?> fatPercentage,
      Value<double?> waterPercentage,
      Value<double?> muscleMassKg,
      Value<double?> boneMassKg,
      Value<double?> leanBodyMassKg,
      Value<double?> proteinPercentage,
      Value<double?> visceralFat,
      Value<double?> basalMetabolicRate,
      Value<double?> metabolicAge,
      Value<bool> syncedToHealth,
    });
typedef $$MeasurementsTableUpdateCompanionBuilder =
    MeasurementsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<DateTime> measuredAt,
      Value<double> weightKg,
      Value<int?> impedance,
      Value<double?> bmi,
      Value<double?> fatPercentage,
      Value<double?> waterPercentage,
      Value<double?> muscleMassKg,
      Value<double?> boneMassKg,
      Value<double?> leanBodyMassKg,
      Value<double?> proteinPercentage,
      Value<double?> visceralFat,
      Value<double?> basalMetabolicRate,
      Value<double?> metabolicAge,
      Value<bool> syncedToHealth,
    });

final class $$MeasurementsTableReferences
    extends BaseReferences<_$AppDatabase, $MeasurementsTable, Measurement> {
  $$MeasurementsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('measurements__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get impedance => $composableBuilder(
    column: $table.impedance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bmi => $composableBuilder(
    column: $table.bmi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatPercentage => $composableBuilder(
    column: $table.fatPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waterPercentage => $composableBuilder(
    column: $table.waterPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get muscleMassKg => $composableBuilder(
    column: $table.muscleMassKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get boneMassKg => $composableBuilder(
    column: $table.boneMassKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leanBodyMassKg => $composableBuilder(
    column: $table.leanBodyMassKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinPercentage => $composableBuilder(
    column: $table.proteinPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get visceralFat => $composableBuilder(
    column: $table.visceralFat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get basalMetabolicRate => $composableBuilder(
    column: $table.basalMetabolicRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get metabolicAge => $composableBuilder(
    column: $table.metabolicAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncedToHealth => $composableBuilder(
    column: $table.syncedToHealth,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get impedance => $composableBuilder(
    column: $table.impedance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bmi => $composableBuilder(
    column: $table.bmi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatPercentage => $composableBuilder(
    column: $table.fatPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waterPercentage => $composableBuilder(
    column: $table.waterPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get muscleMassKg => $composableBuilder(
    column: $table.muscleMassKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get boneMassKg => $composableBuilder(
    column: $table.boneMassKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leanBodyMassKg => $composableBuilder(
    column: $table.leanBodyMassKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinPercentage => $composableBuilder(
    column: $table.proteinPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get visceralFat => $composableBuilder(
    column: $table.visceralFat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get basalMetabolicRate => $composableBuilder(
    column: $table.basalMetabolicRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get metabolicAge => $composableBuilder(
    column: $table.metabolicAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncedToHealth => $composableBuilder(
    column: $table.syncedToHealth,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get impedance =>
      $composableBuilder(column: $table.impedance, builder: (column) => column);

  GeneratedColumn<double> get bmi =>
      $composableBuilder(column: $table.bmi, builder: (column) => column);

  GeneratedColumn<double> get fatPercentage => $composableBuilder(
    column: $table.fatPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get waterPercentage => $composableBuilder(
    column: $table.waterPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get muscleMassKg => $composableBuilder(
    column: $table.muscleMassKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get boneMassKg => $composableBuilder(
    column: $table.boneMassKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get leanBodyMassKg => $composableBuilder(
    column: $table.leanBodyMassKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinPercentage => $composableBuilder(
    column: $table.proteinPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get visceralFat => $composableBuilder(
    column: $table.visceralFat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get basalMetabolicRate => $composableBuilder(
    column: $table.basalMetabolicRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get metabolicAge => $composableBuilder(
    column: $table.metabolicAge,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get syncedToHealth => $composableBuilder(
    column: $table.syncedToHealth,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementsTable,
          Measurement,
          $$MeasurementsTableFilterComposer,
          $$MeasurementsTableOrderingComposer,
          $$MeasurementsTableAnnotationComposer,
          $$MeasurementsTableCreateCompanionBuilder,
          $$MeasurementsTableUpdateCompanionBuilder,
          (Measurement, $$MeasurementsTableReferences),
          Measurement,
          PrefetchHooks Function({bool profileId})
        > {
  $$MeasurementsTableTableManager(_$AppDatabase db, $MeasurementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<DateTime> measuredAt = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<int?> impedance = const Value.absent(),
                Value<double?> bmi = const Value.absent(),
                Value<double?> fatPercentage = const Value.absent(),
                Value<double?> waterPercentage = const Value.absent(),
                Value<double?> muscleMassKg = const Value.absent(),
                Value<double?> boneMassKg = const Value.absent(),
                Value<double?> leanBodyMassKg = const Value.absent(),
                Value<double?> proteinPercentage = const Value.absent(),
                Value<double?> visceralFat = const Value.absent(),
                Value<double?> basalMetabolicRate = const Value.absent(),
                Value<double?> metabolicAge = const Value.absent(),
                Value<bool> syncedToHealth = const Value.absent(),
              }) => MeasurementsCompanion(
                id: id,
                profileId: profileId,
                measuredAt: measuredAt,
                weightKg: weightKg,
                impedance: impedance,
                bmi: bmi,
                fatPercentage: fatPercentage,
                waterPercentage: waterPercentage,
                muscleMassKg: muscleMassKg,
                boneMassKg: boneMassKg,
                leanBodyMassKg: leanBodyMassKg,
                proteinPercentage: proteinPercentage,
                visceralFat: visceralFat,
                basalMetabolicRate: basalMetabolicRate,
                metabolicAge: metabolicAge,
                syncedToHealth: syncedToHealth,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required DateTime measuredAt,
                required double weightKg,
                Value<int?> impedance = const Value.absent(),
                Value<double?> bmi = const Value.absent(),
                Value<double?> fatPercentage = const Value.absent(),
                Value<double?> waterPercentage = const Value.absent(),
                Value<double?> muscleMassKg = const Value.absent(),
                Value<double?> boneMassKg = const Value.absent(),
                Value<double?> leanBodyMassKg = const Value.absent(),
                Value<double?> proteinPercentage = const Value.absent(),
                Value<double?> visceralFat = const Value.absent(),
                Value<double?> basalMetabolicRate = const Value.absent(),
                Value<double?> metabolicAge = const Value.absent(),
                Value<bool> syncedToHealth = const Value.absent(),
              }) => MeasurementsCompanion.insert(
                id: id,
                profileId: profileId,
                measuredAt: measuredAt,
                weightKg: weightKg,
                impedance: impedance,
                bmi: bmi,
                fatPercentage: fatPercentage,
                waterPercentage: waterPercentage,
                muscleMassKg: muscleMassKg,
                boneMassKg: boneMassKg,
                leanBodyMassKg: leanBodyMassKg,
                proteinPercentage: proteinPercentage,
                visceralFat: visceralFat,
                basalMetabolicRate: basalMetabolicRate,
                metabolicAge: metabolicAge,
                syncedToHealth: syncedToHealth,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MeasurementsTable, Measurement>(table),
                  $$MeasurementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$MeasurementsTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$MeasurementsTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementsTable,
      Measurement,
      $$MeasurementsTableFilterComposer,
      $$MeasurementsTableOrderingComposer,
      $$MeasurementsTableAnnotationComposer,
      $$MeasurementsTableCreateCompanionBuilder,
      $$MeasurementsTableUpdateCompanionBuilder,
      (Measurement, $$MeasurementsTableReferences),
      Measurement,
      PrefetchHooks Function({bool profileId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$MeasurementsTableTableManager get measurements =>
      $$MeasurementsTableTableManager(_db, _db.measurements);
}
