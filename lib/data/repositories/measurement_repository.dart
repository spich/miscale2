import 'package:drift/drift.dart';

import '../../core/ble/scale_reading.dart';
import '../../core/body/body_metrics.dart';
import '../../core/health/health_service.dart';
import '../db/app_database.dart';

extension ProfileX on Profile {
  Sex get sexValue => Sex.values[sex];

  bool matchesWeight(double weightKg) =>
      weightKg >= minWeightKg && weightKg <= maxWeightKg;

  int ageAt(DateTime moment) {
    var years = moment.year - birthDate.year;
    final hadBirthday = moment.month > birthDate.month ||
        (moment.month == birthDate.month && moment.day >= birthDate.day);
    return hadBirthday ? years : years - 1;
  }
}

/// Spaja očitanje s vage, izračun sastava tijela, lokalnu bazu i Health.
class MeasurementRepository {
  MeasurementRepository(this._db, this._health);

  final AppDatabase _db;
  final HealthService _health;

  /// Profili čiji raspon težine odgovara izmjerenoj težini. Prazno ili više
  /// od jednog znači da korisnik mora sam odabrati profil.
  Future<List<Profile>> matchingProfiles(double weightKg) async {
    final all = await _db.allProfiles();
    return all.where((p) => p.matchesWeight(weightKg)).toList();
  }

  BodyMetrics? metricsFor(Profile profile, ScaleReading reading, DateTime at) {
    if (reading.impedance == null) return null;
    final metrics = BodyMetrics.forProfile(
      weightKg: reading.weightKg,
      heightCm: profile.heightCm,
      birthDate: profile.birthDate,
      sex: profile.sexValue,
      impedance: reading.impedance!,
      measuredAt: at,
    );
    return metrics.isPlausible ? metrics : null;
  }

  /// Sprema mjerenje i, ako je profil povezan s Healthom, odmah ga šalje dalje.
  Future<Measurement> save(Profile profile, ScaleReading reading) async {
    // Sat u vagi zna odlutati za dane, pa je vrijeme telefona pouzdanije.
    final measuredAt = DateTime.now();
    final metrics = metricsFor(profile, reading, measuredAt);

    await _db.insertMeasurement(
      MeasurementsCompanion.insert(
        profileId: profile.id,
        measuredAt: measuredAt,
        weightKg: reading.weightKg,
        impedance: Value(reading.impedance),
        bmi: Value(metrics?.bmi),
        fatPercentage: Value(metrics?.fatPercentage),
        waterPercentage: Value(metrics?.waterPercentage),
        muscleMassKg: Value(metrics?.muscleMassKg),
        boneMassKg: Value(metrics?.boneMassKg),
        leanBodyMassKg: Value(metrics?.leanBodyMassKg),
        proteinPercentage: Value(metrics?.proteinPercentage),
        visceralFat: Value(metrics?.visceralFat),
        basalMetabolicRate: Value(metrics?.basalMetabolicRate),
        metabolicAge: Value(metrics?.metabolicAge),
      ),
    );

    final saved = (await _db.latestMeasurement(profile.id))!;
    if (profile.syncToHealth) {
      await _syncOne(saved, metrics);
    }
    return saved;
  }

  /// Šalje u Health sva mjerenja koja još nisu poslana (npr. jer dozvola
  /// tada nije bila odobrena).
  Future<int> syncPending(Profile profile) async {
    if (!profile.syncToHealth) return 0;
    if (!await _health.hasPermissions()) return 0;

    final pending = await _db.unsyncedMeasurements(profile.id);
    final synced = <int>[];
    for (final measurement in pending) {
      if (await _writeToHealth(profile, measurement)) synced.add(measurement.id);
    }
    if (synced.isNotEmpty) await _db.markSynced(synced);
    return synced.length;
  }

  Future<void> _syncOne(Measurement measurement, BodyMetrics? metrics) async {
    final ok = await _health.writeMeasurement(
      measuredAt: measurement.measuredAt,
      weightKg: measurement.weightKg,
      metrics: metrics,
    );
    if (ok) await _db.markSynced([measurement.id]);
  }

  Future<bool> _writeToHealth(Profile profile, Measurement m) async {
    final impedance = m.impedance;
    final metrics = impedance == null
        ? null
        : BodyMetrics.forProfile(
            weightKg: m.weightKg,
            heightCm: profile.heightCm,
            birthDate: profile.birthDate,
            sex: profile.sexValue,
            impedance: impedance,
            measuredAt: m.measuredAt,
          );
    return _health.writeMeasurement(
      measuredAt: m.measuredAt,
      weightKg: m.weightKg,
      metrics: metrics?.isPlausible == true ? metrics : null,
    );
  }
}
