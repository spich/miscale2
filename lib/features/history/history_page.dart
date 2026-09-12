import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/db/app_database.dart';
import '../../providers.dart';
import 'measurement_details.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final profile = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Povijest'),
        actions: [
          if (profiles.length > 1 && profile != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: DropdownButton<int>(
                value: profile.id,
                underline: const SizedBox.shrink(),
                onChanged: (id) =>
                    ref.read(selectedProfileIdProvider.notifier).select(id),
                items: [
                  for (final item in profiles)
                    DropdownMenuItem(value: item.id, child: Text(item.name)),
                ],
              ),
            ),
        ],
      ),
      body: profile == null
          ? const Center(child: Text('Dodaj profil da bi vidio povijest.'))
          : _ProfileHistory(profile: profile),
    );
  }
}

class _ProfileHistory extends ConsumerWidget {
  const _ProfileHistory({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurements = ref.watch(measurementsProvider(profile.id));

    return measurements.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Greška: $error')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Nema mjerenja za ovaj profil.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                child: SizedBox(
                  height: 200,
                  child: _WeightChart(measurements: items),
                ),
              );
            }
            final measurement = items[index - 1];
            final previous =
                index < items.length ? items[index] : null;
            return _MeasurementTile(
              measurement: measurement,
              previous: previous,
              profile: profile,
            );
          },
        );
      },
    );
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.measurements});

  /// Mjerenja su poredana od najnovijeg prema starijem.
  final List<Measurement> measurements;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Zadnjih 30 mjerenja, kronološki.
    final data = measurements.take(30).toList().reversed.toList();
    if (data.length < 2) {
      return Center(
        child: Text(
          'Graf se pojavljuje nakon drugog mjerenja.',
          style: theme.textTheme.bodySmall,
        ),
      );
    }

    final spots = [
      for (var i = 0; i < data.length; i++)
        FlSpot(i.toDouble(), data[i].weightKg),
    ];
    final weights = data.map((m) => m.weightKg);
    final min = weights.reduce((a, b) => a < b ? a : b);
    final max = weights.reduce((a, b) => a > b ? a : b);
    final padding = ((max - min) * 0.2).clamp(0.5, 5.0);

    return LineChart(
      LineChartData(
        minY: min - padding,
        maxY: max + padding,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                formatDecimal(value),
                style: theme.textTheme.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: (data.length / 5).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  formatShortDate(data[index].measuredAt),
                  style: theme.textTheme.labelSmall,
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            color: theme.colorScheme.primary,
            barWidth: 2,
            dotData: FlDotData(show: data.length <= 15),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementTile extends ConsumerWidget {
  const _MeasurementTile({
    required this.measurement,
    required this.previous,
    required this.profile,
  });

  final Measurement measurement;
  final Measurement? previous;
  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final difference = previous == null
        ? null
        : measurement.weightKg - previous!.weightKg;
    // Razlika manja od dekagrama je šum vage, ne promjena težine.
    final delta = difference != null && difference.abs() >= 0.05
        ? difference
        : null;

    return Dismissible(
      key: ValueKey(measurement.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline),
      ),
      onDismissed: (_) =>
          ref.read(databaseProvider).deleteMeasurement(measurement.id),
      child: ListTile(
        title: Text('${formatWeight(measurement.weightKg)} kg'),
        subtitle: Text(formatDateTime(measurement.measuredAt)),
        trailing: delta == null
            ? (difference == null
                ? null
                : Text(
                    'bez promjene',
                    style: Theme.of(context).textTheme.labelSmall,
                  ))
            : Text(
                '${delta >= 0 ? '+' : '−'}${formatDecimal(delta.abs())} kg',
                style: TextStyle(
                  color: delta >= 0
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
        onTap: () => showMeasurementDetails(context, measurement, profile),
      ),
    );
  }
}
