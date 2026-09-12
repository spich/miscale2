import 'package:flutter_test/flutter_test.dart';
import 'package:miscale2/core/body/body_metrics.dart';

void main() {
  // Referentne vrijednosti izračunate iz Xiaomi formula; test čuva ponašanje
  // od nenamjernih promjena.
  final reference = BodyMetrics(
    weightKg: 75.35,
    heightCm: 180,
    age: 36,
    sex: Sex.male,
    impedance: 500,
  );

  group('BodyMetrics', () {
    test('daje očekivane vrijednosti za poznati ulaz', () {
      expect(reference.isPlausible, isTrue);
      expect(reference.bmi, closeTo(23.2562, 0.0001));
      expect(reference.fatPercentage, closeTo(20.9891, 0.0001));
      expect(reference.waterPercentage, closeTo(54.2015, 0.0001));
      expect(reference.boneMassKg, closeTo(3.0319, 0.0001));
      expect(reference.muscleMassKg, closeTo(56.5028, 0.0001));
      expect(reference.proteinPercentage, closeTo(20.7857, 0.0001));
      expect(reference.visceralFat, closeTo(11.9582, 0.0001));
      expect(reference.basalMetabolicRate, closeTo(1670.3856, 0.0001));
      expect(reference.metabolicAge, closeTo(29.6892, 0.0001));
    });

    test('mišići, mast i kosti zajedno daju ukupnu težinu', () {
      final fatMass = reference.weightKg * reference.fatPercentage / 100;
      expect(
        fatMass + reference.muscleMassKg + reference.boneMassKg,
        closeTo(reference.weightKg, 0.0001),
      );
    });

    test('veća impedancija znači veći postotak masti', () {
      double fatFor(int impedance) => BodyMetrics(
            weightKg: 75.35,
            heightCm: 180,
            age: 36,
            sex: Sex.male,
            impedance: impedance,
          ).fatPercentage;

      expect(fatFor(600), greaterThan(fatFor(400)));
    });

    test('žene imaju veći izračunati postotak masti pri istim mjerama', () {
      final female = BodyMetrics(
        weightKg: 75.35,
        heightCm: 180,
        age: 36,
        sex: Sex.female,
        impedance: 500,
      );
      expect(female.fatPercentage, greaterThan(reference.fatPercentage));
    });

    test('vrijednosti ostaju unutar granica i za ekstremne ulaze', () {
      final extreme = BodyMetrics(
        weightKg: 199,
        heightCm: 150,
        age: 99,
        sex: Sex.female,
        impedance: 2900,
      );
      expect(extreme.fatPercentage, inInclusiveRange(5, 75));
      expect(extreme.waterPercentage, inInclusiveRange(35, 75));
      expect(extreme.boneMassKg, inInclusiveRange(0.5, 8));
      expect(extreme.muscleMassKg, inInclusiveRange(10, 120));
      expect(extreme.visceralFat, inInclusiveRange(1, 50));
      expect(extreme.metabolicAge, inInclusiveRange(15, 80));
    });

    test('nemoguće očitanje se prepozna kao neuvjerljivo', () {
      final bogus = BodyMetrics(
        weightKg: 5,
        heightCm: 180,
        age: 36,
        sex: Sex.male,
        impedance: 0,
      );
      expect(bogus.isPlausible, isFalse);
    });

    test('dob se računa iz datuma rođenja na dan mjerenja', () {
      final beforeBirthday = BodyMetrics.forProfile(
        weightKg: 75.35,
        heightCm: 180,
        birthDate: DateTime(1990, 9, 20),
        sex: Sex.male,
        impedance: 500,
        measuredAt: DateTime(2026, 9, 12),
      );
      final afterBirthday = BodyMetrics.forProfile(
        weightKg: 75.35,
        heightCm: 180,
        birthDate: DateTime(1990, 9, 1),
        sex: Sex.male,
        impedance: 500,
        measuredAt: DateTime(2026, 9, 12),
      );

      expect(beforeBirthday.age, 35);
      expect(afterBirthday.age, 36);
    });
  });
}
