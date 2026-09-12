import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miscale2/core/body/body_metrics.dart';
import 'package:miscale2/data/db/app_database.dart';
import 'package:miscale2/data/repositories/measurement_repository.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> addProfile({
    required String name,
    required double min,
    required double max,
    bool syncToHealth = false,
  }) =>
      db.upsertProfile(
        ProfilesCompanion.insert(
          name: name,
          sex: Sex.male.index,
          birthDate: DateTime(1990, 1, 1),
          heightCm: 180,
          minWeightKg: min,
          maxWeightKg: max,
          syncToHealth: Value(syncToHealth),
        ),
      );

  test('samo jedan profil ostaje povezan s Healthom', () async {
    await addProfile(name: 'Ana', min: 50, max: 70, syncToHealth: true);
    await addProfile(name: 'Ivo', min: 70.1, max: 100, syncToHealth: true);

    final linked = (await db.allProfiles()).where((p) => p.syncToHealth);
    expect(linked.map((p) => p.name), ['Ivo']);
  });

  test('profil se prepoznaje po rasponu težine', () async {
    await addProfile(name: 'Ana', min: 50, max: 70);
    await addProfile(name: 'Ivo', min: 70.1, max: 100);

    final profiles = await db.allProfiles();
    expect(profiles.where((p) => p.matchesWeight(64.2)).single.name, 'Ana');
    expect(profiles.where((p) => p.matchesWeight(82.0)).single.name, 'Ivo');
    expect(profiles.where((p) => p.matchesWeight(120.0)), isEmpty);
  });

  test('brisanje profila briše i njegova mjerenja', () async {
    final id = await addProfile(name: 'Ana', min: 50, max: 70);
    await db.insertMeasurement(
      MeasurementsCompanion.insert(
        profileId: id,
        measuredAt: DateTime(2026, 9, 12, 8),
        weightKg: 64.2,
      ),
    );
    expect(await db.latestMeasurement(id), isNotNull);

    await db.deleteProfile(id);
    expect(await db.select(db.measurements).get(), isEmpty);
  });

  test('neposlana mjerenja se izdvajaju i označe kao poslana', () async {
    final id = await addProfile(name: 'Ana', min: 50, max: 70);
    for (var day = 1; day <= 3; day++) {
      await db.insertMeasurement(
        MeasurementsCompanion.insert(
          profileId: id,
          measuredAt: DateTime(2026, 9, day),
          weightKg: 64 + day.toDouble(),
        ),
      );
    }

    final pending = await db.unsyncedMeasurements(id);
    expect(pending, hasLength(3));

    await db.markSynced([pending.first.id]);
    expect(await db.unsyncedMeasurements(id), hasLength(2));
  });
}
