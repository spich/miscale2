import 'dart:math' as math;

enum Sex { male, female }

/// Izračun sastava tijela iz težine i bio-impedancije.
///
/// Formule su reverzno inženjerirane iz Mi Fit aplikacije (projekti openScale
/// i xiaomi_mi_scale) jer Xiaomi algoritam nije javno dokumentiran. Rezultati
/// se poklapaju s onime što prikazuje Mi Fit, ali nisu medicinski mjerni
/// podatak — impedancijska analiza je procjena.
class BodyMetrics {
  BodyMetrics({
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.sex,
    required this.impedance,
  });

  /// Iz datuma rođenja, jer dob ulazi u gotovo svaku formulu.
  factory BodyMetrics.forProfile({
    required double weightKg,
    required int heightCm,
    required DateTime birthDate,
    required Sex sex,
    required int impedance,
    DateTime? measuredAt,
  }) {
    final now = measuredAt ?? DateTime.now();
    var age = now.year - birthDate.year;
    final hadBirthday = now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hadBirthday) age--;

    return BodyMetrics(
      weightKg: weightKg,
      heightCm: heightCm.toDouble(),
      age: age,
      sex: sex,
      impedance: impedance,
    );
  }

  final double weightKg;
  final double heightCm;
  final int age;
  final Sex sex;
  final int impedance;

  bool get _isFemale => sex == Sex.female;

  /// Ulazni podaci su unutar raspona za koji algoritam daje smislen rezultat.
  bool get isPlausible =>
      heightCm > 90 &&
      heightCm <= 220 &&
      weightKg >= 10 &&
      weightKg <= 200 &&
      age > 0 &&
      age <= 99 &&
      impedance > 0 &&
      impedance <= 3000;

  double get bmi =>
      _clamp(weightKg / ((heightCm / 100) * (heightCm / 100)), 10, 90);

  /// Lean Body Mass koeficijent — temelj većine ostalih formula.
  double get _lbmCoefficient {
    var lbm = (heightCm * 9.058 / 100) * (heightCm / 100);
    lbm += weightKg * 0.32 + 12.226;
    lbm -= impedance * 0.0068;
    lbm -= age * 0.0542;
    return lbm;
  }

  /// Postotak tjelesne masti.
  double get fatPercentage {
    final double constant;
    if (_isFemale && age <= 49) {
      constant = 9.25;
    } else if (_isFemale) {
      constant = 7.25;
    } else {
      constant = 0.8;
    }

    var coefficient = 1.0;
    if (!_isFemale && weightKg < 61) {
      coefficient = 0.98;
    } else if (_isFemale && weightKg > 60) {
      coefficient = 0.96;
      if (heightCm > 160) coefficient *= 1.03;
    } else if (_isFemale && weightKg < 50) {
      coefficient = 1.02;
      if (heightCm > 160) coefficient *= 1.03;
    }

    var value = (1.0 - (((_lbmCoefficient - constant) * coefficient) / weightKg)) * 100;
    if (value > 63) value = 75;
    return _clamp(value, 5, 75);
  }

  /// Postotak vode u tijelu.
  double get waterPercentage {
    final base = (100 - fatPercentage) * 0.7;
    final coefficient = base <= 50 ? 1.02 : 0.98;
    final value = base * coefficient;
    return _clamp(value >= 65 ? 75 : value, 35, 75);
  }

  /// Masa kostiju u kilogramima.
  double get boneMassKg {
    final base = _isFemale ? 0.245691014 : 0.18016894;
    var value = (base - (_lbmCoefficient * 0.05158)) * -1;
    value += value > 2.2 ? 0.1 : -0.1;

    final cap = _isFemale ? 5.1 : 5.2;
    if (value > cap) value = 8;
    return _clamp(value, 0.5, 8);
  }

  /// Mišićna masa u kilogramima.
  double get muscleMassKg {
    var value = weightKg - ((fatPercentage * 0.01) * weightKg) - boneMassKg;
    final cap = _isFemale ? 84.0 : 93.5;
    if (value >= cap) value = 120;
    return _clamp(value, 10, 120);
  }

  /// Nemasna masa (sve osim masti) u kilogramima.
  double get leanBodyMassKg =>
      _clamp(weightKg - (weightKg * fatPercentage / 100), 1, weightKg);

  /// Masa vode u kilogramima — Health Connect je traži kao masu, ne postotak.
  double get waterMassKg => weightKg * waterPercentage / 100;

  /// Postotak proteina.
  double get proteinPercentage =>
      _clamp((muscleMassKg / weightKg) * 100 - waterPercentage, 5, 32);

  /// Visceralna mast — indeks, nije postotak ni masa.
  double get visceralFat {
    double value;
    if (_isFemale) {
      if (weightKg > (13 - (heightCm * 0.5)) * -1) {
        final sub = ((heightCm * 1.45) + (heightCm * 0.1158) * heightCm) - 120;
        value = ((weightKg * 500 / sub) - 6) + (age * 0.07);
      } else {
        final sub = 0.691 + (heightCm * -0.0024) + (heightCm * -0.0024);
        value = (((heightCm * 0.027) - (sub * weightKg)) * -1) + (age * 0.07) - age;
      }
    } else {
      if (heightCm < weightKg * 1.6) {
        final sub = ((heightCm * 0.4) - (heightCm * (heightCm * 0.0826))) * -1;
        value = ((weightKg * 305) / (sub + 48)) - 2.9 + (age * 0.15);
      } else {
        final sub = 0.765 + heightCm * -0.0015;
        value = (((heightCm * 0.143) - (weightKg * sub)) * -1) + (age * 0.15) - 5.0;
      }
    }
    return _clamp(value, 1, 50);
  }

  /// Bazalni metabolizam u kcal/dan.
  double get basalMetabolicRate {
    double value;
    if (_isFemale) {
      value = 864.6 + weightKg * 10.2036 - heightCm * 0.39336 - age * 6.204;
      if (value > 2996) value = 5000;
    } else {
      value = 877.8 + weightKg * 14.016 - heightCm * 0.704 - age * 3.8;
      if (value > 2322) value = 5000;
    }
    return _clamp(value, 500, 10000);
  }

  /// Metabolička dob u godinama.
  double get metabolicAge {
    final value = _isFemale
        ? (heightCm * -1.1165) +
            (weightKg * 1.5784) +
            (age * 0.4615) +
            (impedance * 0.0415) +
            83.2548
        : (heightCm * -0.7471) +
            (weightKg * 0.9161) +
            (age * 0.4184) +
            (impedance * 0.0517) +
            54.2267;
    return _clamp(value, 15, 80);
  }

  /// Idealna težina po Mi Fit formuli.
  double get idealWeightKg =>
      _isFemale ? (heightCm - 70) * 0.6 : (heightCm - 80) * 0.7;

  static double _clamp(double value, double min, double max) =>
      math.min(math.max(value, min), max);
}
