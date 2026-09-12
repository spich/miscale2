import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/ble/scale_scanner.dart';
import 'core/health/health_service.dart';
import 'data/db/app_database.dart';
import 'data/repositories/measurement_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final healthServiceProvider = Provider<HealthService>((ref) => HealthService());

final scaleScannerProvider = Provider<ScaleScanner>((ref) {
  final scanner = ScaleScanner();
  ref.onDispose(scanner.stop);
  return scanner;
});

final measurementRepositoryProvider = Provider<MeasurementRepository>(
  (ref) => MeasurementRepository(
    ref.watch(databaseProvider),
    ref.watch(healthServiceProvider),
  ),
);

final profilesProvider = StreamProvider<List<Profile>>(
  (ref) => ref.watch(databaseProvider).watchProfiles(),
);

/// Profil čija se povijest trenutno gleda; `null` znači "prvi dostupni".
final selectedProfileIdProvider = NotifierProvider<SelectedProfile, int?>(
  SelectedProfile.new,
);

class SelectedProfile extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? id) => state = id;
}

/// Trenutno odabrani profil, uz fallback na prvi u popisu.
final currentProfileProvider = Provider<Profile?>((ref) {
  final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
  if (profiles.isEmpty) return null;
  final id = ref.watch(selectedProfileIdProvider);
  return profiles.where((p) => p.id == id).firstOrNull ?? profiles.first;
});

final measurementsProvider =
    StreamProvider.family<List<Measurement>, int>((ref, profileId) {
  return ref.watch(databaseProvider).watchMeasurements(profileId);
});
