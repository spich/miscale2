import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/ble/scale_scanner.dart';
import '../../core/body/body_metrics.dart';
import '../../core/body/body_rating.dart';
import '../../core/format.dart';
import '../../data/db/app_database.dart';
import '../../providers.dart';
import '../../widgets/metric_tile.dart';
import '../profiles/profile_editor_page.dart';
import 'scan_controller.dart';

/// Zaslon vaganja. Skeniranje se pokreće samo od sebe dok je zaslon otvoren i
/// aplikacija u prvom planu — korisnik ne mora ništa tapnuti — a prestaje čim
/// ode na drugu karticu ili u pozadinu, da vaga ne troši bateriju uzalud.
class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage>
    with WidgetsBindingObserver {
  /// Korisnik je sam prekinuo traženje; tada se ne pokreće ponovno dok to
  /// izričito ne zatraži ili se ne vrati na zaslon.
  bool _stoppedByUser = false;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final foreground = state == AppLifecycleState.resumed;
    if (foreground == _foreground) return;
    _foreground = foreground;
    if (foreground) _stoppedByUser = false;
    _syncScanning();
  }

  /// Usklađuje skener sa stanjem zaslona. Poziva se nakon svakog crtanja, pa
  /// pokriva i promjenu kartice i dolazak prvog profila.
  void _syncScanning() {
    if (!mounted) return;

    final controller = ref.read(scanControllerProvider.notifier);
    final state = ref.read(scanControllerProvider);
    final hasProfiles =
        (ref.read(profilesProvider).value ?? const <Profile>[]).isNotEmpty;
    final isVisible = ref.read(selectedTabProvider) == 0;
    final shouldScan =
        hasProfiles && isVisible && _foreground && !_stoppedByUser;

    if (shouldScan && state is ScanIdle) {
      unawaited(controller.start());
    } else if (!shouldScan && (state is ScanWaiting || state is ScanLive)) {
      unawaited(controller.stop());
    }
  }

  Future<void> _stopByUser() async {
    _stoppedByUser = true;
    await ref.read(scanControllerProvider.notifier).stop();
  }

  Future<void> _startByUser() async {
    _stoppedByUser = false;
    await ref.read(scanControllerProvider.notifier).start();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanControllerProvider);
    final controller = ref.read(scanControllerProvider.notifier);
    // Kartica i popis profila utječu na to smije li se skenirati.
    ref.watch(selectedTabProvider);
    ref.watch(profilesProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncScanning());

    return Scaffold(
      appBar: AppBar(title: const Text('Vaganje')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: switch (state) {
            ScanIdle() => _IdleView(onStart: _startByUser),
            ScanWaiting() => _WaitingView(onCancel: _stopByUser),
            ScanLive(:final weightKg, :final isStabilized) => _LiveView(
                weightKg: weightKg,
                isStabilized: isStabilized,
                onCancel: _stopByUser,
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
                onRetry: _startByUser,
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
        Text(
          profiles.isEmpty
              ? 'Vaga ne traži uparivanje, ali mjerenje mora imati kome '
                  'pripasti. Dodaj profil pa stani bos na vagu.'
              : 'Traženje je zaustavljeno. Nastavi pa stani bos na vagu i '
                  'pričekaj da se težina umiri.',
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
            label: const Text('Nastavi traženje'),
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

class _ResultView extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Redak se prati iz baze jer upis u Health teče usporedno s prikazom.
    final live = ref.watch(measurementProvider(measurement.id)).value ??
        measurement;

    return ListView(
      children: [
        const SizedBox(height: 8),
        Text(
          profile.name,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        Text(
          formatWeight(live.weightKg),
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w300,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        Text('kg', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(
          formatDateTime(live.measuredAt),
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (profile.syncToHealth)
          Center(
            child: live.syncedToHealth
                ? const Chip(
                    avatar: Icon(Icons.check, size: 18),
                    label: Text('Zapisano u Health'),
                  )
                : ActionChip(
                    avatar: const Icon(Icons.sync_problem, size: 18),
                    label: const Text('Nije zapisano — pokušaj ponovno'),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final sent = await ref
                          .read(measurementRepositoryProvider)
                          .syncPending(profile);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            sent > 0
                                ? 'Zapisano u Health.'
                                : 'Upis nije uspio — provjeri dozvolu u '
                                    'postavkama.',
                          ),
                        ),
                      );
                    },
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

List<MetricTile> metricTilesFor(BodyMetrics m) {
  final ratings = BodyRatings.of(m);

  return [
    MetricTile(
      label: 'Tjelesna mast',
      value: formatDecimal(m.fatPercentage),
      unit: '%',
      icon: Icons.water_drop_outlined,
      rating: ratings.fatPercentage,
    ),
    MetricTile(
      label: 'Voda',
      value: formatDecimal(m.waterPercentage),
      unit: '%',
      icon: Icons.opacity,
      rating: ratings.waterPercentage,
    ),
    MetricTile(
      label: 'Mišićna masa',
      value: formatDecimal(m.muscleMassKg),
      unit: 'kg',
      icon: Icons.fitness_center,
      rating: ratings.muscleMass,
    ),
    MetricTile(
      label: 'Kosti',
      value: formatDecimal(m.boneMassKg),
      unit: 'kg',
      icon: Icons.accessibility_new,
      rating: ratings.boneMass,
    ),
    MetricTile(
      label: 'BMI',
      value: formatDecimal(m.bmi),
      icon: Icons.straighten,
      rating: ratings.bmi,
    ),
    MetricTile(
      label: 'Proteini',
      value: formatDecimal(m.proteinPercentage),
      unit: '%',
      icon: Icons.egg_outlined,
      rating: ratings.proteinPercentage,
    ),
    MetricTile(
      label: 'Visceralna mast',
      value: formatDecimal(m.visceralFat),
      icon: Icons.donut_small,
      rating: ratings.visceralFat,
    ),
    MetricTile(
      label: 'Bazalni metabolizam',
      value: formatInteger(m.basalMetabolicRate),
      unit: 'kcal',
      icon: Icons.local_fire_department_outlined,
      rating: ratings.basalMetabolicRate,
    ),
    MetricTile(
      label: 'Metabolička dob',
      value: formatInteger(m.metabolicAge),
      unit: 'god.',
      icon: Icons.cake_outlined,
      rating: ratings.metabolicAge,
    ),
    MetricTile(
      label: 'Idealna težina',
      value: formatDecimal(m.idealWeightKg),
      unit: 'kg',
      icon: Icons.flag_outlined,
      rating: ratings.idealWeight,
    ),
  ];
}

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
