import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Osoba koja se važe. Raspon težine služi za automatsko prepoznavanje
/// kome pripada mjerenje, kao u Mi Fit aplikaciji.
class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  /// 0 = muško, 1 = žensko (indeks u `Sex`).
  IntColumn get sex => integer()();
  DateTimeColumn get birthDate => dateTime()();
  IntColumn get heightCm => integer()();
  RealColumn get minWeightKg => real()();
  RealColumn get maxWeightKg => real()();
  /// Samo jedan profil smije pisati u Apple Health / Health Connect, jer su
  /// to podaci vlasnika uređaja.
  BoolColumn get syncToHealth => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Jedno vaganje sa svim izvedenim vrijednostima. Izvedene vrijednosti se
/// pohranjuju, a ne računaju iznova, da se povijest ne mijenja retroaktivno
/// kad korisnik ispravi visinu ili datum rođenja.
class Measurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get measuredAt => dateTime()();
  RealColumn get weightKg => real()();
  IntColumn get impedance => integer().nullable()();
  RealColumn get bmi => real().nullable()();
  RealColumn get fatPercentage => real().nullable()();
  RealColumn get waterPercentage => real().nullable()();
  RealColumn get muscleMassKg => real().nullable()();
  RealColumn get boneMassKg => real().nullable()();
  RealColumn get leanBodyMassKg => real().nullable()();
  RealColumn get proteinPercentage => real().nullable()();
  RealColumn get visceralFat => real().nullable()();
  RealColumn get basalMetabolicRate => real().nullable()();
  RealColumn get metabolicAge => real().nullable()();
  BoolColumn get syncedToHealth =>
      boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {profileId, measuredAt},
      ];
}

@DriftDatabase(tables: [Profiles, Measurements])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'miscale2'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // SQLite po zadanome ignorira strane ključeve, pa bi brisanje
          // profila ostavljalo njegova mjerenja u bazi.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // --- Profili ---

  Stream<List<Profile>> watchProfiles() =>
      (select(profiles)..orderBy([(p) => OrderingTerm(expression: p.name)]))
          .watch();

  Future<List<Profile>> allProfiles() => select(profiles).get();

  Future<Profile?> profileById(int id) =>
      (select(profiles)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<int> upsertProfile(ProfilesCompanion profile) async {
    if (profile.syncToHealth.present && profile.syncToHealth.value) {
      // Health smije primati podatke samo jednog profila.
      await (update(profiles)..where((p) => p.syncToHealth.equals(true)))
          .write(const ProfilesCompanion(syncToHealth: Value(false)));
    }
    return into(profiles).insertOnConflictUpdate(profile);
  }

  Future<int> deleteProfile(int id) =>
      (delete(profiles)..where((p) => p.id.equals(id))).go();

  // --- Mjerenja ---

  Stream<List<Measurement>> watchMeasurements(int profileId, {int? limit}) {
    final query = select(measurements)
      ..where((m) => m.profileId.equals(profileId))
      ..orderBy([
        (m) => OrderingTerm(expression: m.measuredAt, mode: OrderingMode.desc),
      ]);
    if (limit != null) query.limit(limit);
    return query.watch();
  }

  Future<Measurement?> measurementById(int id) =>
      (select(measurements)..where((m) => m.id.equals(id))).getSingleOrNull();

  Stream<Measurement?> watchMeasurement(int id) =>
      (select(measurements)..where((m) => m.id.equals(id))).watchSingleOrNull();

  Future<Measurement?> latestMeasurement(int profileId) => (select(measurements)
        ..where((m) => m.profileId.equals(profileId))
        ..orderBy([
          (m) => OrderingTerm(expression: m.measuredAt, mode: OrderingMode.desc),
        ])
        ..limit(1))
      .getSingleOrNull();

  /// Vraća `null` ako mjerenje u istoj sekundi za isti profil već postoji —
  /// vaga isti rezultat emitira više puta zaredom.
  Future<int?> insertMeasurement(MeasurementsCompanion measurement) =>
      into(measurements).insertOnConflictUpdate(measurement);

  Future<List<Measurement>> unsyncedMeasurements(int profileId) =>
      (select(measurements)
            ..where((m) =>
                m.profileId.equals(profileId) & m.syncedToHealth.equals(false))
            ..orderBy([(m) => OrderingTerm(expression: m.measuredAt)]))
          .get();

  Future<void> markSynced(Iterable<int> ids) =>
      (update(measurements)..where((m) => m.id.isIn(ids)))
          .write(const MeasurementsCompanion(syncedToHealth: Value(true)));

  Future<int> deleteMeasurement(int id) =>
      (delete(measurements)..where((m) => m.id.equals(id))).go();
}
