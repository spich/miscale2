import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/ble/scale_scanner.dart';
import '../../core/body/body_metrics.dart';
import '../../core/format.dart';
import '../../data/db/app_database.dart';
import '../../providers.dart';
import '../../widgets/metric_tile.dart';
import '../profiles/profile_editor_page.dart';
import 'scan_controller.dart';

class ScanPage extends ConsumerWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanControllerProvider);
    final controller = ref.read(scanControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Vaganje')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: switch (state) {
            ScanIdle() => _IdleView(onStart: controller.start),
            ScanWaiting() => _WaitingView(onCancel: controller.stop),
            ScanLive(:final weightKg, :final isStabilized) => _LiveView(
                weightKg: weightKg,
                isStabilized: isStabilized,
                onCancel: controller.stop,
              ),
            ScanNeedsProfile(:final reading, :final candidates) => _ProfilePicker(
                weightKg: reading.weightKg,
                profiles: candidates,
                onSelected: controller.chooseProfile,
                onCancel: controller.reset,
              ),
            ScanSaved(:final measurement, :final profile, :final metrics) =>
              _ResultView(
                measurement: measurement,
                profile: profile,
                metrics: metrics,
                onAgain: controller.reset,
              ),
            ScanFailed(:final message, :final status) => _FailureView(
                message: message,
                status: status,
                onRetry: controller.start,
              ),
          },
        ),
      ),
    );
  }
}

class _IdleView extends ConsumerWidget {
  const _IdleView({required this.onStart});
  final Future<void> Function() onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.monitor_weight_outlined,
          size: 96,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Xiaomi Body Composition Scale 2',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Vaga ne traži uparivanje. Pokreni mjerenje, stani bos na vagu '
          'i pričekaj da se težina umiri.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (profiles.isEmpty)
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProfileEditorPage(),
              ),
            ),
            icon: const Icon(Icons.person_add),
            label: const Text('Dodaj profil'),
          )
        else
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Započni mjerenje'),
          ),
      ],
    );
  }
}

class _WaitingView extends StatelessWidget {
  const _WaitingView({required this.onCancel});
  final Future<void> Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text('Tražim vagu…', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text(
          'Stani na vagu da se probudi.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextButton(onPressed: onCancel, child: const Text('Odustani')),
      ],
    );
  }
}

class _LiveView extends StatelessWidget {
  const _LiveView({
    required this.weightKg,
    required this.isStabilized,
    required this.onCancel,
  });

  final double weightKg;
  final bool isStabilized;
  final Future<void> Function() onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          formatWeight(weightKg),
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w300,
            color: theme.colorScheme.primary,
          ),
        ),
        Text('kg', style: theme.textTheme.titleLarge),
        const SizedBox(height: 24),
        Text(
          isStabilized
              ? 'Ostani na vagi, mjerim sastav tijela…'
              : 'Mjerim težinu…',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const LinearProgressIndicator(),
        const SizedBox(height: 24),
        TextButton(onPressed: onCancel, child: const Text('Prekini')),
      ],
    );
  }
}

class _ProfilePicker extends StatelessWidget {
  const _ProfilePicker({
    required this.weightKg,
    required this.profiles,
    required this.onSelected,
    required this.onCancel,
  });

  final double weightKg;
  final List<Profile> profiles;
  final Future<void> Function(Profile) onSelected;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          '${formatWeight(weightKg)} kg',
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Kome pripada ovo mjerenje?',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              for (final profile in profiles)
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(profile.name),
                  subtitle: Text(
                    'raspon ${formatDecimal(profile.minWeightKg)}'
                    '–${formatDecimal(profile.maxWeightKg)} kg',
                  ),
                  onTap: () => onSelected(profile),
                ),
            ],
          ),
        ),
        TextButton(onPressed: onCancel, child: const Text('Odbaci mjerenje')),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.measurement,
    required this.profile,
    required this.metrics,
    required this.onAgain,
  });

  final Measurement measurement;
  final Profile profile;
  final BodyMetrics? metrics;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        const SizedBox(height: 8),
        Text(
          profile.name,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        Text(
          formatWeight(measurement.weightKg),
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w300,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        Text('kg', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(
          formatDateTime(measurement.measuredAt),
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (profile.syncToHealth)
          Chip(
            avatar: Icon(
              measurement.syncedToHealth ? Icons.check : Icons.sync_problem,
              size: 18,
            ),
            label: Text(
              measurement.syncedToHealth
                  ? 'Zapisano u Health'
                  : 'Čeka upis u Health',
            ),
          ),
        const SizedBox(height: 16),
        if (metrics == null)
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Bez analize sastava tijela'),
              subtitle: Text(
                'Vaga nije izmjerila impedanciju. Stani bos na vagu, '
                's oba stopala na metalne elektrode.',
              ),
            ),
          )
        else
          MetricGrid(tiles: metricTilesFor(metrics!)),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onAgain,
          icon: const Icon(Icons.refresh),
          label: const Text('Novo mjerenje'),
        ),
      ],
    );
  }
}

List<MetricTile> metricTilesFor(BodyMetrics m) => [
      MetricTile(
        label: 'Tjelesna mast',
        value: formatDecimal(m.fatPercentage),
        unit: '%',
        icon: Icons.water_drop_outlined,
      ),
      MetricTile(
        label: 'Voda',
        value: formatDecimal(m.waterPercentage),
        unit: '%',
        icon: Icons.opacity,
      ),
      MetricTile(
        label: 'Mišićna masa',
        value: formatDecimal(m.muscleMassKg),
        unit: 'kg',
        icon: Icons.fitness_center,
      ),
      MetricTile(
        label: 'Kosti',
        value: formatDecimal(m.boneMassKg),
        unit: 'kg',
        icon: Icons.accessibility_new,
      ),
      MetricTile(
        label: 'BMI',
        value: formatDecimal(m.bmi),
        icon: Icons.straighten,
      ),
      MetricTile(
        label: 'Proteini',
        value: formatDecimal(m.proteinPercentage),
        unit: '%',
        icon: Icons.egg_outlined,
      ),
      MetricTile(
        label: 'Visceralna mast',
        value: formatDecimal(m.visceralFat),
        icon: Icons.donut_small,
      ),
      MetricTile(
        label: 'Bazalni metabolizam',
        value: formatInteger(m.basalMetabolicRate),
        unit: 'kcal',
        icon: Icons.local_fire_department_outlined,
      ),
      MetricTile(
        label: 'Metabolička dob',
        value: formatInteger(m.metabolicAge),
        unit: 'god.',
        icon: Icons.cake_outlined,
      ),
      MetricTile(
        label: 'Idealna težina',
        value: formatDecimal(m.idealWeightKg),
        unit: 'kg',
        icon: Icons.flag_outlined,
      ),
    ];

class _FailureView extends StatelessWidget {
  const _FailureView({
    required this.message,
    required this.status,
    required this.onRetry,
  });

  final String message;
  final ScannerStatus? status;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.bluetooth_disabled,
          size: 72,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        if (status == ScannerStatus.permissionDenied)
          OutlinedButton(
            onPressed: openAppSettings,
            child: const Text('Otvori postavke aplikacije'),
          ),
        FilledButton(onPressed: onRetry, child: const Text('Pokušaj ponovno')),
      ],
    );
  }
}
