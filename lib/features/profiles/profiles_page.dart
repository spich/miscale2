import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/body/body_metrics.dart';
import '../../core/format.dart';
import '../../data/db/app_database.dart';
import '../../providers.dart';
import 'profile_editor_page.dart';

class ProfilesPage extends ConsumerWidget {
  const ProfilesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profili')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.person_add),
      ),
      body: profiles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Greška: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Još nema profila. Dodaj barem jedan da bi se mjerenja '
                  'mogla pripisati osobi.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final profile = items[index];
              return Dismissible(
                key: ValueKey(profile.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete_outline),
                ),
                confirmDismiss: (_) => _confirmDelete(context, profile),
                onDismissed: (_) =>
                    ref.read(databaseProvider).deleteProfile(profile.id),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      profile.sex == Sex.female.index ? Icons.female : Icons.male,
                    ),
                  ),
                  title: Text(profile.name),
                  subtitle: Text(
                    '${profile.heightCm} cm · rođen(a) '
                    '${formatDate(profile.birthDate)} · '
                    '${formatDecimal(profile.minWeightKg)}–'
                    '${formatDecimal(profile.maxWeightKg)} kg',
                  ),
                  trailing: profile.syncToHealth
                      ? const Icon(Icons.favorite, size: 18)
                      : null,
                  onTap: () => _openEditor(context, profile),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openEditor(BuildContext context, [Profile? profile]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileEditorPage(profile: profile),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, Profile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Obrisati profil ${profile.name}?'),
        content: const Text(
          'Brišu se i sva mjerenja tog profila. Podaci već poslani u Health '
          'ostaju ondje.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
