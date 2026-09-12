import 'package:flutter_test/flutter_test.dart';
import 'package:miscale2/core/ble/mi_scale_parser.dart';
import 'package:miscale2/core/ble/scale_reading.dart';

/// Slaže 13-bajtni advertisement kakav šalje Mi Body Composition Scale 2.
List<int> bfsPayload({
  required int ctrl0,
  required int ctrl1,
  required int rawWeight,
  int rawImpedance = 0,
  DateTime? timestamp,
}) {
  final t = timestamp ?? DateTime(2026, 9, 12, 8, 30, 15);
  return [
    ctrl0,
    ctrl1,
    t.year & 0xFF,
    (t.year >> 8) & 0xFF,
    t.month,
    t.day,
    t.hour,
    t.minute,
    t.second,
    rawImpedance & 0xFF,
    (rawImpedance >> 8) & 0xFF,
    rawWeight & 0xFF,
    (rawWeight >> 8) & 0xFF,
  ];
}

void main() {
  group('MiScaleParser (Mi Scale 2)', () {
    test('čita stabilizirano mjerenje s impedancijom u kilogramima', () {
      final reading = MiScaleParser.parse(
        {
          '0000181b-0000-1000-8000-00805f9b34fb': bfsPayload(
            ctrl0: 0x02,
            ctrl1: 0x22, // stabilizirano (bit 5) + impedancija (bit 1)
            rawWeight: 15070, // 75,35 kg * 200
            rawImpedance: 500,
          ),
        },
        deviceId: 'AA:BB:CC:DD:EE:FF',
      );

      expect(reading, isNotNull);
      expect(reading!.weightKg, closeTo(75.35, 0.001));
      expect(reading.impedance, 500);
      expect(reading.unit, ScaleUnit.kg);
      expect(reading.isStabilized, isTrue);
      expect(reading.isWeightRemoved, isFalse);
      expect(reading.isComplete, isTrue);
      expect(reading.scaleTimestamp, DateTime(2026, 9, 12, 8, 30, 15));
    });

    test('mjerenje u tijeku nije stabilizirano ni potpuno', () {
      final reading = MiScaleParser.parse(
        {'181b': bfsPayload(ctrl0: 0x02, ctrl1: 0x00, rawWeight: 14000)},
        deviceId: 'x',
      );

      expect(reading!.isStabilized, isFalse);
      expect(reading.hasImpedance, isFalse);
      expect(reading.isComplete, isFalse);
      expect(reading.weightKg, closeTo(70.0, 0.001));
    });

    test('postavljen flag impedancije s nulom se ne uzima kao vrijednost', () {
      final reading = MiScaleParser.parse(
        {
          '181b': bfsPayload(
            ctrl0: 0x02,
            ctrl1: 0x22,
            rawWeight: 15070,
          ),
        },
        deviceId: 'x',
      );

      expect(reading!.impedance, isNull);
      expect(reading.isComplete, isFalse);
    });

    test('funte se pretvaraju u kilograme', () {
      final reading = MiScaleParser.parse(
        {
          '181b': bfsPayload(
            ctrl0: 0x03, // bit 0 = lbs
            ctrl1: 0x22,
            rawWeight: 16600, // 166,00 lbs
            rawImpedance: 480,
          ),
        },
        deviceId: 'x',
      );

      expect(reading!.unit, ScaleUnit.lbs);
      expect(reading.weightKg, closeTo(75.30, 0.01));
    });

    test('prepoznaje silazak s vage', () {
      final reading = MiScaleParser.parse(
        {'181b': bfsPayload(ctrl0: 0x02, ctrl1: 0xA2, rawWeight: 15070)},
        deviceId: 'x',
      );

      expect(reading!.isWeightRemoved, isTrue);
      expect(reading.isComplete, isFalse);
    });
  });

  group('MiScaleParser (Mi Scale v1)', () {
    test('čita težinu iz 10-bajtnog paketa bez impedancije', () {
      final reading = MiScaleParser.parse(
        {
          '0000181d-0000-1000-8000-00805f9b34fb': [
            0x22, // stabilizirano, kg
            0xDE, 0x3A, // 15070 -> 75,35 kg
            0xF2, 0x07, 9, 12, 8, 30, 15,
          ],
        },
        deviceId: 'x',
      );

      expect(reading!.weightKg, closeTo(75.35, 0.001));
      expect(reading.impedance, isNull);
      expect(reading.isStabilized, isTrue);
    });
  });

  test('nepoznati servis vraća null', () {
    expect(
      MiScaleParser.parse({'180f': [0x64]}, deviceId: 'x'),
      isNull,
    );
  });
}
