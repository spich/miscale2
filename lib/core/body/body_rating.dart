import 'dart:math' as math;

import 'body_metrics.dart';

/// Kakvoća pojedinog raspona; određuje boju i poruku korisniku.
enum RatingQuality { low, good, caution, bad }

/// Ocjena jedne vrijednosti u odnosu na raspone za tu osobu.
class MetricRating {
  /// [labels] i [qualities] moraju imati jedan član više od [thresholds] —
  /// svaki raspon svoj naziv i kakvoću.
  const MetricRating({
    required this.value,
    required this.thresholds,
    required this.labels,
    required this.qualities,
  });

  final double value;

  /// Granice raspona, uzlazno.
  final List<double> thresholds;

  /// Nazivi raspona; uvijek jedan više od broja granica.
  final List<String> labels;
  final List<RatingQuality> qualities;

  int get bandIndex {
    for (var i = 0; i < thresholds.length; i++) {
      if (value < thresholds[i]) return i;
    }
    return thresholds.length;
  }

  String get label => labels[bandIndex];
  RatingQuality get quality => qualities[bandIndex];

  /// Položaj vrijednosti na traci, 0–1. Rasponi su jednako široki bez obzira
  /// na brojčanu širinu, jer traka pokazuje "u kojem si rasponu", ne mjerilo.
  double get position {
    final bands = thresholds.length + 1;
    final index = bandIndex;
    final lower = index == 0 ? null : thresholds[index - 1];
    final upper = index == thresholds.length ? null : thresholds[index];

    final double withinBand;
    if (lower != null && upper != null) {
      withinBand = (value - lower) / (upper - lower);
    } else {
      // Otvoreni rubni raspon: širina se procjenjuje iz susjednih granica.
      final span = _edgeSpan;
      withinBand = lower == null
          ? 1 - ((upper! - value) / span).clamp(0.0, 1.0)
          : ((value - lower) / span).clamp(0.0, 1.0);
    }

    return ((index + withinBand.clamp(0.0, 1.0)) / bands).clamp(0.0, 1.0);
  }

  double get _edgeSpan {
    if (thresholds.length >= 2) {
      final widths = [
        for (var i = 1; i < thresholds.length; i++)
          thresholds[i] - thresholds[i - 1],
      ];
      return widths.reduce((a, b) => a + b) / widths.length;
    }
    return math.max(thresholds.first * 0.2, 1);
  }
}

/// Rasponi po kojima Mi Fit ocjenjuje mjerenja. Tablice su, kao i formule,
/// reverzno inženjerirane (openScale, xiaomi_mi_scale) i ovise o spolu, dobi,
/// visini i težini osobe.
class BodyRatings {
  BodyRatings(this.metrics);

  factory BodyRatings.of(BodyMetrics metrics) => BodyRatings(metrics);

  final BodyMetrics metrics;

  bool get _isFemale => metrics.sex == Sex.female;

  MetricRating get bmi => MetricRating(
        value: metrics.bmi,
        thresholds: const [18.5, 25, 28, 32],
        // Nazivi su kratki namjerno — stanu u pločicu bez rezanja.
        labels: const [
          'Pothranjeno',
          'Normalno',
          'Prekomjerno',
          'Debljina',
          'Pretilost',
        ],
        qualities: const [
          RatingQuality.caution,
          RatingQuality.good,
          RatingQuality.caution,
          RatingQuality.bad,
          RatingQuality.bad,
        ],
      );

  MetricRating get fatPercentage => MetricRating(
        value: metrics.fatPercentage,
        thresholds: _fatThresholds,
        labels: const ['Nisko', 'Optimalno', 'Normalno', 'Povišeno', 'Visoko'],
        qualities: const [
          RatingQuality.low,
          RatingQuality.good,
          RatingQuality.good,
          RatingQuality.caution,
          RatingQuality.bad,
        ],
      );

  MetricRating get waterPercentage => MetricRating(
        value: metrics.waterPercentage,
        thresholds: _isFemale ? const [45, 60.1] : const [55, 65.1],
        labels: const ['Nedostatno', 'Normalno', 'Odlično'],
        qualities: const [
          RatingQuality.low,
          RatingQuality.good,
          RatingQuality.good,
        ],
      );

  MetricRating get muscleMass => MetricRating(
        value: metrics.muscleMassKg,
        thresholds: _muscleThresholds,
        labels: const ['Nedostatno', 'Normalno', 'Odlično'],
        qualities: const [
          RatingQuality.low,
          RatingQuality.good,
          RatingQuality.good,
        ],
      );

  MetricRating get boneMass {
    final optimal = _optimalBoneMass;
    return MetricRating(
      value: metrics.boneMassKg,
      thresholds: [optimal - 1, optimal + 1],
      labels: const ['Nisko', 'Normalno', 'Visoko'],
      qualities: const [
        RatingQuality.low,
        RatingQuality.good,
        RatingQuality.good,
      ],
    );
  }

  MetricRating get proteinPercentage => MetricRating(
        value: metrics.proteinPercentage,
        thresholds: const [16, 20],
        labels: const ['Nedostatno', 'Normalno', 'Odlično'],
        qualities: const [
          RatingQuality.low,
          RatingQuality.good,
          RatingQuality.good,
        ],
      );

  MetricRating get visceralFat => MetricRating(
        value: metrics.visceralFat,
        thresholds: const [10, 15],
        labels: const ['Normalno', 'Povišeno', 'Visoko'],
        qualities: const [
          RatingQuality.good,
          RatingQuality.caution,
          RatingQuality.bad,
        ],
      );

  MetricRating get basalMetabolicRate => MetricRating(
        value: metrics.basalMetabolicRate,
        thresholds: [_minimumBmr],
        labels: const ['Nisko', 'Normalno'],
        qualities: const [RatingQuality.low, RatingQuality.good],
      );

  MetricRating get metabolicAge => MetricRating(
        value: metrics.metabolicAge,
        thresholds: [metrics.age.toDouble()],
        labels: const ['Ispod dobi', 'Iznad dobi'],
        qualities: const [RatingQuality.good, RatingQuality.caution],
      );

  /// Razlika do idealne težine; ocjenjuje se odstupanje, ne sama težina.
  MetricRating get idealWeight => MetricRating(
        value: metrics.weightKg - metrics.idealWeightKg,
        thresholds: const [-5, 5],
        labels: const ['Ispod ideala', 'Blizu ideala', 'Iznad ideala'],
        qualities: const [
          RatingQuality.caution,
          RatingQuality.good,
          RatingQuality.caution,
        ],
      );

  /// Postotak masti ovisi o dobi i spolu.
  List<double> get _fatThresholds {
    const byAge = <int, Map<String, List<double>>>{
      20: {
        'f': [18, 23, 30, 35],
        'm': [8, 14, 21, 25],
      },
      25: {
        'f': [19, 24, 30, 35],
        'm': [10, 15, 22, 26],
      },
      30: {
        'f': [20, 25, 31, 36],
        'm': [11, 16, 21, 27],
      },
      35: {
        'f': [21, 26, 33, 36],
        'm': [13, 17, 25, 28],
      },
      40: {
        'f': [22, 27, 34, 37],
        'm': [15, 18, 26, 29],
      },
      45: {
        'f': [23, 28, 35, 38],
        'm': [16, 19, 27, 30],
      },
      50: {
        'f': [24, 30, 36, 38],
        'm': [17, 20, 28, 31],
      },
      55: {
        'f': [26, 31, 36, 39],
        'm': [19, 21, 28, 32],
      },
      200: {
        'f': [27, 32, 37, 40],
        'm': [21, 22, 29, 33],
      },
    };

    for (final entry in byAge.entries) {
      if (metrics.age <= entry.key) {
        return entry.value[_isFemale ? 'f' : 'm']!;
      }
    }
    return byAge[200]![_isFemale ? 'f' : 'm']!;
  }

  /// Mišićna masa ovisi o visini i spolu.
  List<double> get _muscleThresholds {
    final height = metrics.heightCm;
    if (_isFemale) {
      if (height >= 160) return const [36.5, 42.6];
      if (height >= 150) return const [32.9, 37.6];
      return const [29.1, 34.8];
    }
    if (height >= 170) return const [49.4, 59.5];
    if (height >= 160) return const [44, 52.5];
    return const [38.5, 46.6];
  }

  /// Optimalna masa kostiju ovisi o težini i spolu.
  double get _optimalBoneMass {
    final weight = metrics.weightKg;
    if (_isFemale) {
      if (weight >= 60) return 2.5;
      if (weight >= 45) return 2.2;
      return 1.8;
    }
    if (weight >= 75) return 3.0;
    return 2.5;
  }

  /// Donja granica bazalnog metabolizma: referentna potrošnja po kilogramu
  /// tjelesne mase za tu dob i spol (kcal/kg/dan).
  ///
  /// Ne koristi se koeficijent iz xiaomi_mi_scale (36 za muškarca srednje
  /// dobi) jer on daje ukupnu dnevnu potrošnju, a ne bazalnu — uz njega bi
  /// gotovo svako mjerenje ispalo "ispod prosjeka".
  double get _minimumBmr {
    final age = metrics.age;
    final double perKilogram;
    if (_isFemale) {
      perKilogram = age < 18
          ? 25.3
          : age < 30
              ? 23.6
              : age < 50
                  ? 21.7
                  : 20.7;
    } else {
      perKilogram = age < 18
          ? 27.0
          : age < 30
              ? 24.0
              : age < 50
                  ? 22.3
                  : 21.5;
    }
    return metrics.weightKg * perKilogram;
  }
}
