import 'package:flutter/material.dart';

import '../../core/body/body_metrics.dart';
import '../../core/format.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/measurement_repository.dart';
import '../../widgets/metric_tile.dart';
import '../scan/scan_page.dart' show metricTilesFor;

/// Prikazuje detalje jednog mjerenja iz povijesti.
Future<void> showMeasurementDetails(
  BuildContext context,
  Measurement measurement,
  Profile profile,
) {
  final impedance = measurement.impedance;
  // Vrijednosti se preračunavaju iz pohranjene težine i impedancije, uz
  // profil kakav je bio u trenutku mjerenja (dob se računa na taj datum).
  final metrics = impedance == null
      ? null
      : BodyMetrics(
          weightKg: measurement.weightKg,
          heightCm: profile.heightCm.toDouble(),
          age: profile.ageAt(measurement.measuredAt),
          sex: profile.sexValue,
          impedance: impedance,
        );

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Text(
            '${formatWeight(measurement.weightKg)} kg',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            formatDateTime(measurement.measuredAt),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (metrics == null || !metrics.isPlausible)
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Bez analize sastava tijela'),
                subtitle: Text('Mjerenje nema podatak o impedanciji.'),
              ),
            )
          else
            MetricGrid(tiles: metricTilesFor(metrics)),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(
              measurement.syncedToHealth ? Icons.favorite : Icons.favorite_border,
            ),
            title: Text(
              measurement.syncedToHealth
                  ? 'Zapisano u Health'
                  : 'Nije zapisano u Health',
            ),
            subtitle: impedance == null
                ? null
                : Text('Impedancija: $impedance Ω'),
          ),
        ],
      ),
    ),
  );
}
