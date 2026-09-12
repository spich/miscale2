import 'dart:io';
import 'dart:ui';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/app_database.dart';
import 'measurement_csv.dart';

/// Sprema mjerenja u CSV i otvara sustavski izbornik dijeljenja.
///
/// Datoteka ide u privremeni direktorij jer je aplikacijin vlastiti spremnik
/// korisniku nedostupan na oba sustava — do podataka se dolazi dijeljenjem.
class MeasurementExporter {
  MeasurementExporter(this._db);

  final AppDatabase _db;

  /// Vraća broj izvezenih mjerenja; 0 znači da nije bilo što izvesti.
  Future<int> exportProfile(Profile profile, {Rect? shareOrigin}) async {
    final measurements = await _db.measurementsOf(profile.id);
    return _share(
      [for (final measurement in measurements) (profile, measurement)],
      MeasurementCsv.fileName(profileName: profile.name),
      shareOrigin,
    );
  }

  Future<int> exportAll({Rect? shareOrigin}) async {
    final rows = await _db.measurementsWithProfiles();
    return _share(rows, MeasurementCsv.fileName(), shareOrigin);
  }

  Future<int> _share(
    List<(Profile, Measurement)> rows,
    String fileName,
    Rect? shareOrigin,
  ) async {
    if (rows.isEmpty) return 0;

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(MeasurementCsv.build(rows), flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        fileNameOverrides: [fileName],
        subject: 'Mjerenja s vage',
        // iPad traži ishodište iz kojeg izbornik izlazi.
        sharePositionOrigin: shareOrigin,
      ),
    );
    return rows.length;
  }
}
