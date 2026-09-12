import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:miscale2/data/db/app_database.dart';
import 'package:miscale2/data/export/measurement_csv.dart';

Profile profile(String name) => Profile(
      id: 1,
      name: name,
      sex: 0,
      birthDate: DateTime(1990, 1, 1),
      heightCm: 180,
      minWeightKg: 60,
      maxWeightKg: 120,
      syncToHealth: true,
      createdAt: DateTime(2026, 1, 1),
    );

Measurement measurement({
  required DateTime measuredAt,
  double weightKg = 75.35,
  int? impedance = 500,
  bool synced = true,
}) =>
    Measurement(
      id: 1,
      profileId: 1,
      measuredAt: measuredAt,
      weightKg: weightKg,
      impedance: impedance,
      bmi: 23.2562,
      fatPercentage: 20.9891,
      waterPercentage: 54.2015,
      muscleMassKg: 56.5028,
      boneMassKg: 3.0319,
      leanBodyMassKg: 59.5334,
      proteinPercentage: 20.7857,
      visceralFat: 11.9582,
      basalMetabolicRate: 1670.3856,
      metabolicAge: 29.6892,
      syncedToHealth: synced,
    );

void main() {
  group('MeasurementCsv', () {
    test('piše zaglavlje i redak s decimalnim zarezom', () {
      final csv = MeasurementCsv.build([
        (profile('Ana'), measurement(measuredAt: DateTime(2026, 9, 12, 8, 5, 3))),
      ]);
      final lines = const LineSplitter().convert(csv);

      expect(lines.first, startsWith('﻿Datum i vrijeme;Profil;Težina (kg)'));
      expect(
        lines[1],
        '2026-09-12 08:05:03;Ana;75,35;500;23,3;21,0;54,2;56,5;3,0;59,5;'
        '20,8;12,0;1670;30;da',
      );
    });

    test('mjerenja izlaze kronološki bez obzira na ulazni redoslijed', () {
      final csv = MeasurementCsv.build([
        (profile('Ana'), measurement(measuredAt: DateTime(2026, 9, 12), weightKg: 2)),
        (profile('Ana'), measurement(measuredAt: DateTime(2026, 9, 10), weightKg: 1)),
      ]);
      final lines = const LineSplitter().convert(csv);

      expect(lines[1], contains('2026-09-10'));
      expect(lines[2], contains('2026-09-12'));
    });

    test('mjerenje bez impedancije ostavlja prazna polja', () {
      final csv = MeasurementCsv.build([
        (
          profile('Ana'),
          Measurement(
            id: 2,
            profileId: 1,
            measuredAt: DateTime(2026, 9, 12, 8),
            weightKg: 75.35,
            syncedToHealth: false,
          ),
        ),
      ]);

      expect(
        const LineSplitter().convert(csv)[1],
        '2026-09-12 08:00:00;Ana;75,35;;;;;;;;;;;;ne',
      );
    });

    test('ime s razdjelnikom se navodi pod navodnicima', () {
      final csv = MeasurementCsv.build([
        (profile('Ana; "mala"'), measurement(measuredAt: DateTime(2026, 9, 12))),
      ]);

      expect(
        const LineSplitter().convert(csv)[1],
        contains('"Ana; ""mala"""'),
      );
    });

    test('naziv datoteke nosi profil i datum, bez dijakritika', () {
      expect(
        MeasurementCsv.fileName(
          profileName: 'Đuro Čavić',
          now: DateTime(2026, 9, 5),
        ),
        'mjerenja-duro-cavic-2026-09-05.csv',
      );
      expect(
        MeasurementCsv.fileName(now: DateTime(2026, 12, 31)),
        'mjerenja-svi-profili-2026-12-31.csv',
      );
    });
  });
}
