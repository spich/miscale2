import '../db/app_database.dart';

/// Slaže CSV iz mjerenja.
///
/// Točka-zarez kao razdjelnik i zarez kao decimalni znak, jer se datoteka
/// otvara u hrvatski postavljenom Excelu. Zapis počinje BOM-om, inače Excel
/// pokvari dijakritike.
class MeasurementCsv {
  static const String delimiter = ';';
  static const String byteOrderMark = '﻿';

  static const List<String> header = [
    'Datum i vrijeme',
    'Profil',
    'Težina (kg)',
    'Impedancija (Ω)',
    'BMI',
    'Tjelesna mast (%)',
    'Voda (%)',
    'Mišićna masa (kg)',
    'Kosti (kg)',
    'Nemasna masa (kg)',
    'Proteini (%)',
    'Visceralna mast',
    'Bazalni metabolizam (kcal)',
    'Metabolička dob',
    'Zapisano u Health',
  ];

  /// [rows] se ispisuju kronološki, od najstarijeg.
  static String build(Iterable<(Profile, Measurement)> rows) {
    final sorted = rows.toList()
      ..sort((a, b) => a.$2.measuredAt.compareTo(b.$2.measuredAt));

    final buffer = StringBuffer(byteOrderMark)
      ..writeln(header.map(_escape).join(delimiter));

    for (final (profile, measurement) in sorted) {
      buffer.writeln(
        [
          _timestamp(measurement.measuredAt),
          profile.name,
          _number(measurement.weightKg, 2),
          measurement.impedance?.toString() ?? '',
          _number(measurement.bmi, 1),
          _number(measurement.fatPercentage, 1),
          _number(measurement.waterPercentage, 1),
          _number(measurement.muscleMassKg, 1),
          _number(measurement.boneMassKg, 1),
          _number(measurement.leanBodyMassKg, 1),
          _number(measurement.proteinPercentage, 1),
          _number(measurement.visceralFat, 1),
          _number(measurement.basalMetabolicRate, 0),
          _number(measurement.metabolicAge, 0),
          measurement.syncedToHealth ? 'da' : 'ne',
        ].map(_escape).join(delimiter),
      );
    }

    return buffer.toString();
  }

  /// Naziv datoteke s datumom izvoza; [profileName] izostaje za sve profile.
  static String fileName({String? profileName, DateTime? now}) {
    final date = now ?? DateTime.now();
    final stamp = '${date.year}-${_pad(date.month)}-${_pad(date.day)}';
    final who = profileName == null ? 'svi-profili' : _slug(profileName);
    return 'mjerenja-$who-$stamp.csv';
  }

  static String _timestamp(DateTime moment) =>
      '${moment.year}-${_pad(moment.month)}-${_pad(moment.day)} '
      '${_pad(moment.hour)}:${_pad(moment.minute)}:${_pad(moment.second)}';

  static String _number(double? value, int decimals) =>
      value == null ? '' : value.toStringAsFixed(decimals).replaceAll('.', ',');

  static String _pad(int value) => value.toString().padLeft(2, '0');

  static String _escape(String value) {
    if (!value.contains(delimiter) &&
        !value.contains('"') &&
        !value.contains('\n')) {
      return value;
    }
    return '"${value.replaceAll('"', '""')}"';
  }

  static String _slug(String value) {
    const replacements = {
      'č': 'c', 'ć': 'c', 'ž': 'z', 'š': 's', 'đ': 'd',
      'Č': 'c', 'Ć': 'c', 'Ž': 'z', 'Š': 's', 'Đ': 'd',
    };
    var slug = value.toLowerCase();
    replacements.forEach((from, to) => slug = slug.replaceAll(from, to));
    return slug.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(
          RegExp(r'^-+|-+$'),
          '',
        );
  }
}
