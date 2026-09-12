import 'dart:typed_data';

import 'scale_reading.dart';

/// Parser za BLE advertisement payload Xiaomi vaga.
///
/// Vage ne traže uparivanje: cijelo mjerenje stiže u `service data` polju
/// advertisementa, pa je dovoljno skenirati okolinu. Format je reverzno
/// inženjeriran (openScale, xiaomi_mi_scale) jer Xiaomi ne objavljuje
/// specifikaciju.
class MiScaleParser {
  /// Body Composition Service — Mi Body Composition Scale 2 (oznaka MIBFS).
  static const int serviceUuid16Bfs = 0x181B;

  /// Weight Scale Service — Mi Scale v1 (oznaka MI_SCALE).
  static const int serviceUuid16Ws = 0x181D;

  /// Imena pod kojima se Xiaomi vage javljaju. Neke serije ne koriste
  /// standardni UUID, pa ih prepoznajemo po imenu i duljini paketa.
  static const List<String> knownNamePrefixes = [
    'MIBFS', // Mi Body Composition Scale 2
    'MIBCS', // Mi Body Composition Scale
    'MI_SCALE',
    'MI SCALE',
    'BLESMART', // starije serije Mi Smart Scale
    'XMTZC', // oznaka modela na nekim serijama
  ];

  static bool isKnownScaleName(String? name) {
    if (name == null || name.isEmpty) return false;
    final upper = name.toUpperCase();
    return knownNamePrefixes.any(upper.startsWith);
  }

  /// Vraća `null` ako payload ne pripada poznatoj vagi ili je neispravan.
  ///
  /// [deviceName] je neobavezan: ako je uređaj po imenu prepoznata Xiaomi
  /// vaga, paket se pokušava pročitati i kad je objavljen pod nestandardnim
  /// servisom, jer se serije razlikuju.
  static ScaleReading? parse(
    Map<String, List<int>> serviceData, {
    required String deviceId,
    String? deviceName,
  }) {
    for (final entry in serviceData.entries) {
      final uuid16 = _to16Bit(entry.key);
      final bytes = Uint8List.fromList(entry.value);

      if (uuid16 == serviceUuid16Bfs && bytes.length >= 13) {
        return _parseV2(bytes, deviceId);
      }
      if (uuid16 == serviceUuid16Ws && bytes.length >= 10) {
        return _parseV1(bytes, deviceId);
      }
    }

    if (!isKnownScaleName(deviceName)) return null;

    // Poznata vaga pod nepoznatim servisom: odlučuje duljina paketa.
    for (final bytes in serviceData.values) {
      if (bytes.length == 13) {
        return _parseV2(Uint8List.fromList(bytes), deviceId);
      }
      if (bytes.length == 10) {
        return _parseV1(Uint8List.fromList(bytes), deviceId);
      }
    }
    return null;
  }

  /// Mi Body Composition Scale 2 — 13 bajtova, uključuje impedanciju.
  static ScaleReading _parseV2(Uint8List b, String deviceId) {
    final ctrl0 = b[0];
    final ctrl1 = b[1];

    final isLbs = _bit(ctrl0, 0);
    final isCatty = _bit(ctrl1, 6);
    final isStabilized = _bit(ctrl1, 5);
    final isWeightRemoved = _bit(ctrl1, 7);
    final hasImpedance = _bit(ctrl1, 1);

    final rawWeight = b[11] | (b[12] << 8);
    final rawImpedance = b[9] | (b[10] << 8);

    final unit = isLbs
        ? ScaleUnit.lbs
        : isCatty
            ? ScaleUnit.catty
            : ScaleUnit.kg;

    return ScaleReading(
      weightKg: _toKg(rawWeight, unit),
      // Vaga zna poslati 0 uz postavljen flag dok mjerenje još traje.
      impedance: hasImpedance && rawImpedance > 0 ? rawImpedance : null,
      isStabilized: isStabilized,
      isWeightRemoved: isWeightRemoved,
      unit: unit,
      scaleTimestamp: _timestamp(b, 2),
      deviceId: deviceId,
    );
  }

  /// Mi Scale v1 — 10 bajtova, samo težina.
  static ScaleReading _parseV1(Uint8List b, String deviceId) {
    final ctrl = b[0];

    final isLbs = _bit(ctrl, 0);
    final isCatty = _bit(ctrl, 4);
    final unit = isLbs
        ? ScaleUnit.lbs
        : isCatty
            ? ScaleUnit.catty
            : ScaleUnit.kg;

    final rawWeight = b[1] | (b[2] << 8);

    return ScaleReading(
      weightKg: _toKg(rawWeight, unit),
      impedance: null,
      isStabilized: _bit(ctrl, 5),
      isWeightRemoved: _bit(ctrl, 7),
      unit: unit,
      scaleTimestamp: _timestamp(b, 3),
      deviceId: deviceId,
    );
  }

  /// U kg vaga šalje polovice grama, u ostalim jedinicama stotinke.
  static double _toKg(int raw, ScaleUnit unit) => switch (unit) {
        ScaleUnit.kg => raw / 200.0,
        ScaleUnit.catty => raw / 100.0 / 2, // 1 jin = 0,5 kg
        ScaleUnit.lbs => raw / 100.0 / 2.2046226218,
      };

  static DateTime? _timestamp(Uint8List b, int offset) {
    if (b.length < offset + 7) return null;
    final year = b[offset] | (b[offset + 1] << 8);
    try {
      return DateTime(
        year,
        b[offset + 2],
        b[offset + 3],
        b[offset + 4],
        b[offset + 5],
        b[offset + 6],
      );
    } on ArgumentError {
      return null;
    }
  }

  static bool _bit(int value, int index) => (value & (1 << index)) != 0;

  /// Prihvaća i puni 128-bitni oblik ("0000181b-0000-1000-8000-00805f9b34fb")
  /// i skraćeni ("181b"), jer se platforme razlikuju u zapisu.
  static int? _to16Bit(String uuid) {
    final normalized = uuid.replaceAll('-', '').toLowerCase();
    final hex = switch (normalized.length) {
      4 => normalized,
      8 => normalized.substring(4),
      32 => normalized.substring(4, 8),
      _ => null,
    };
    return hex == null ? null : int.tryParse(hex, radix: 16);
  }
}
