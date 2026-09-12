import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/health/health_service.dart';
import '../../providers.dart';

final healthAvailabilityProvider = FutureProvider<HealthAvailability>(
  (ref) => ref.watch(healthServiceProvider).availability(),
);

final healthPermissionProvider = FutureProvider<bool>(
  (ref) => ref.watch(healthServiceProvider).hasPermissions(),
);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availability = ref.watch(healthAvailabilityProvider);
    final granted = ref.watch(healthPermissionProvider);
    final profile = ref.watch(currentProfileProvider);
    final healthName = Platform.isIOS ? 'Apple Health' : 'Health Connect';

    return Scaffold(
      appBar: AppBar(title: const Text('Postavke')),
      body: ListView(
        children: [
          ListTile(
            title: Text(healthName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              switch (availability.value) {
                HealthAvailability.available => 'Dostupno na ovom uređaju',
                HealthAvailability.notInstalled =>
                  'Health Connect nije instaliran',
                HealthAvailability.needsUpdate =>
                  'Health Connect treba ažurirati',
                HealthAvailability.unsupported =>
                  'Platforma ne podržava zdravstvene podatke',
                null => 'Provjeravam…',
              },
            ),
          ),
          if (availability.value == HealthAvailability.notInstalled ||
              availability.value == HealthAvailability.needsUpdate)
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Instaliraj Health Connect'),
              onTap: () async {
                await ref.read(healthServiceProvider).installHealthConnect();
                ref.invalidate(healthAvailabilityProvider);
              },
            ),
          SwitchListTile(
            secondary: const Icon(Icons.favorite_outline),
            title: Text('Dozvola za upis u $healthName'),
            subtitle: Text(
              granted.value == true
                  ? 'Odobreno'
                  : 'Potrebna za slanje mjerenja',
            ),
            value: granted.value ?? false,
            onChanged: granted.value == true
                ? null
                : (_) async {
                    await ref.read(healthServiceProvider).requestPermissions();
                    ref.invalidate(healthPermissionProvider);
                  },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Pošalji neposlana mjerenja'),
            subtitle: Text(
              profile == null
                  ? 'Nema profila'
                  : profile.syncToHealth
                      ? 'Profil: ${profile.name}'
                      : 'Profil ${profile.name} nije povezan s Healthom',
            ),
            enabled: profile != null && profile.syncToHealth,
            onTap: profile == null || !profile.syncToHealth
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final count = await ref
                        .read(measurementRepositoryProvider)
                        .syncPending(profile);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          count == 0
                              ? 'Nema mjerenja za slanje.'
                              : 'Poslano mjerenja: $count',
                        ),
                      ),
                    );
                  },
          ),
          const Divider(),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: 'Mi Scale 2',
            applicationVersion: '1.0.0',
            aboutBoxChildren: [
              Text(
                'Čita Xiaomi Body Composition Scale 2 preko BLE advertisementa '
                'i zapisuje mjerenja u Apple Health odnosno Health Connect.\n\n'
                'Sastav tijela računa se reverzno inženjeriranim Xiaomi '
                'algoritmom (openScale, xiaomi_mi_scale) i procjena je, '
                'a ne medicinski mjerni podatak.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
