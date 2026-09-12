import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ble/scale_reading.dart';
import '../../core/ble/scale_scanner.dart';
import '../../core/body/body_metrics.dart';
import '../../data/db/app_database.dart';
import '../../providers.dart';

sealed class ScanState {
  const ScanState();
}

class ScanIdle extends ScanState {
  const ScanIdle();
}

/// Skeniranje traje, vaga se još nije javila.
class ScanWaiting extends ScanState {
  const ScanWaiting();
}

/// Vaga šalje težinu u realnom vremenu.
class ScanLive extends ScanState {
  const ScanLive(this.weightKg, {required this.isStabilized});
  final double weightKg;
  final bool isStabilized;
}

/// Težina je poznata, ali ne znamo kome pripada.
class ScanNeedsProfile extends ScanState {
  const ScanNeedsProfile(this.reading, this.candidates);
  final ScaleReading reading;
  final List<Profile> candidates;
}

class ScanSaved extends ScanState {
  const ScanSaved(this.measurement, this.profile, this.metrics);
  final Measurement measurement;
  final Profile profile;
  final BodyMetrics? metrics;
}

class ScanFailed extends ScanState {
  const ScanFailed(this.message, {this.status});
  final String message;
  final ScannerStatus? status;
}

/// Vodi jedno vaganje: od pokretanja skeniranja do spremljenog mjerenja.
class ScanController extends Notifier<ScanState> {
  StreamSubscription<ScaleReading>? _sub;
  Timer? _impedanceTimeout;
  ScaleReading? _pending;

  @override
  ScanState build() {
    ref.onDispose(_teardown);
    return const ScanIdle();
  }

  Future<void> start() async {
    if (state is ScanWaiting || state is ScanLive) return;
    _teardown();
    state = const ScanWaiting();

    final scanner = ref.read(scaleScannerProvider);
    _sub = scanner.start().listen(
      _onReading,
      onError: (Object error) {
        state = error is ScannerException
            ? ScanFailed(error.message, status: error.status)
            : ScanFailed('Greška pri skeniranju: $error');
        _teardown();
      },
    );
  }

  Future<void> stop() async {
    _teardown();
    state = const ScanIdle();
  }

  void _onReading(ScaleReading reading) {
    // Nakon spremanja čekamo da korisnik siđe s vage prije novog mjerenja.
    if (state is ScanSaved || state is ScanNeedsProfile) {
      return;
    }
    if (reading.isWeightRemoved || reading.weightKg <= 0) return;

    if (!reading.isStabilized) {
      state = ScanLive(reading.weightKg, isStabilized: false);
      return;
    }

    _pending = reading;
    if (reading.hasImpedance) {
      _impedanceTimeout?.cancel();
      unawaited(_resolveProfile(reading));
      return;
    }

    state = ScanLive(reading.weightKg, isStabilized: true);
    // Impedancija stigne sekundu-dvije nakon težine, ali izostane ako
    // korisnik nije bos. Nakon čekanja spremamo samo težinu.
    _impedanceTimeout ??= Timer(const Duration(seconds: 8), () {
      final pending = _pending;
      if (pending != null) unawaited(_resolveProfile(pending));
    });
  }

  Future<void> _resolveProfile(ScaleReading reading) async {
    _impedanceTimeout?.cancel();
    _impedanceTimeout = null;

    final repository = ref.read(measurementRepositoryProvider);
    final candidates = await repository.matchingProfiles(reading.weightKg);
    final all = ref.read(profilesProvider).value ?? const <Profile>[];

    if (all.isEmpty) {
      state = const ScanFailed(
        'Nema nijednog profila. Dodaj profil prije vaganja.',
      );
      _teardown();
      return;
    }
    if (candidates.length == 1) {
      await _save(candidates.single, reading);
      return;
    }
    // Nijedan ili više profila pokriva ovu težinu — neka korisnik odluči.
    state = ScanNeedsProfile(reading, candidates.isEmpty ? all : candidates);
  }

  /// Poziva se kad korisnik ručno odabere profil u [ScanNeedsProfile].
  Future<void> chooseProfile(Profile profile) async {
    final current = state;
    if (current is! ScanNeedsProfile) return;
    await _save(profile, current.reading);
  }

  Future<void> _save(Profile profile, ScaleReading reading) async {
    final repository = ref.read(measurementRepositoryProvider);
    try {
      final measurement = await repository.save(profile, reading);
      state = ScanSaved(
        measurement,
        profile,
        repository.metricsFor(profile, reading, measurement.measuredAt),
      );
    } catch (error) {
      state = ScanFailed('Spremanje mjerenja nije uspjelo: $error');
    } finally {
      _teardown();
    }
  }

  void reset() {
    _teardown();
    state = const ScanIdle();
  }

  void _teardown() {
    _impedanceTimeout?.cancel();
    _impedanceTimeout = null;
    _pending = null;
    _sub?.cancel();
    _sub = null;
    unawaited(ref.read(scaleScannerProvider).stop());
  }
}

final scanControllerProvider =
    NotifierProvider<ScanController, ScanState>(ScanController.new);
