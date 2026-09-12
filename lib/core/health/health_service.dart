import 'dart:io';

import 'package:health/health.dart';

import '../body/body_metrics.dart';

enum HealthAvailability { available, notInstalled, needsUpdate, unsupported }

/// Upis mjerenja u Apple Health (HealthKit) i Android Health Connect.
class HealthService {
  HealthService([Health? health]) : _health = health ?? Health();

  final Health _health;
  bool _configured = false;

  /// Tipovi koje zapisujemo. Platforme se razlikuju: Health Connect nema
  /// zapis za BMI, a HealthKit nema ni masu vode ni bazalni metabolizam kao
  /// trenutačnu vrijednost (tamo je "basal energy" potrošnja kroz vrijeme,
  /// pa bi upis BMR-a iskrivio dnevni zbroj kalorija).
  static final List<HealthDataType> writeTypes = [
    HealthDataType.WEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.LEAN_BODY_MASS,
    if (Platform.isIOS) HealthDataType.BODY_MASS_INDEX,
    if (Platform.isAndroid) ...[
      HealthDataType.BODY_WATER_MASS,
      HealthDataType.BASAL_ENERGY_BURNED,
      // Koštanu masu HealthKit uopće nema; u Health Connect ide preko našeg
      // forka paketa (spich/health, `BoneMassRecord`).
      HealthDataType.BONE_MASS,
    ],
  ];

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  Future<HealthAvailability> availability() async {
    await _ensureConfigured();
    if (Platform.isIOS) return HealthAvailability.available;
    if (!Platform.isAndroid) return HealthAvailability.unsupported;

    return switch (await _health.getHealthConnectSdkStatus()) {
      HealthConnectSdkStatus.sdkAvailable => HealthAvailability.available,
      HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired =>
        HealthAvailability.needsUpdate,
      _ => HealthAvailability.notInstalled,
    };
  }

  /// Otvara Play Store / Health Connect instalaciju (samo Android).
  Future<void> installHealthConnect() => _health.installHealthConnect();

  Future<bool> hasPermissions() async {
    await _ensureConfigured();
    return await _health.hasPermissions(
          writeTypes,
          permissions: List.filled(writeTypes.length, HealthDataAccess.WRITE),
        ) ??
        false;
  }

  Future<bool> requestPermissions() async {
    await _ensureConfigured();
    return _health.requestAuthorization(
      writeTypes,
      permissions: List.filled(writeTypes.length, HealthDataAccess.WRITE),
    );
  }

  /// Zapisuje jedno vaganje. Vraća `true` samo ako je prošla i težina i svaka
  /// izvedena vrijednost koju smo imali.
  Future<bool> writeMeasurement({
    required DateTime measuredAt,
    required double weightKg,
    BodyMetrics? metrics,
  }) async {
    await _ensureConfigured();

    var allOk = await _write(HealthDataType.WEIGHT, weightKg, measuredAt);
    if (metrics == null) return allOk;

    allOk &= await _write(
      HealthDataType.BODY_FAT_PERCENTAGE,
      _percent(metrics.fatPercentage),
      measuredAt,
    );
    allOk &= await _write(
      HealthDataType.LEAN_BODY_MASS,
      metrics.leanBodyMassKg,
      measuredAt,
    );
    if (Platform.isIOS) {
      allOk &= await _write(
        HealthDataType.BODY_MASS_INDEX,
        metrics.bmi,
        measuredAt,
      );
    }
    if (Platform.isAndroid) {
      allOk &= await _write(
        HealthDataType.BODY_WATER_MASS,
        metrics.waterMassKg,
        measuredAt,
      );
      // Health Connect BMR je snaga u kcal/dan — točno ono što računamo.
      allOk &= await _write(
        HealthDataType.BASAL_ENERGY_BURNED,
        metrics.basalMetabolicRate,
        measuredAt,
      );
      allOk &= await _write(
        HealthDataType.BONE_MASS,
        metrics.boneMassKg,
        measuredAt,
      );
    }
    return allOk;
  }

  Future<bool> _write(
    HealthDataType type,
    double value,
    DateTime timestamp,
  ) async {
    try {
      return await _health.writeHealthData(
        value: value,
        type: type,
        startTime: timestamp,
        endTime: timestamp,
        // Podatak dolazi s uređaja, korisnik ga nije upisao rukom.
        recordingMethod: RecordingMethod.automatic,
      );
    } catch (_) {
      // Nedostatak dozvole za pojedini tip ne smije srušiti cijeli upis.
      return false;
    }
  }

  /// HealthKit očekuje udio (1,0 = 100 %), Health Connect postotak.
  static double _percent(double percentage) =>
      Platform.isIOS ? percentage / 100 : percentage;
}
