import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/body/body_metrics.dart';
import '../../core/format.dart';
import '../../data/db/app_database.dart';
import '../../providers.dart';

class ProfileEditorPage extends ConsumerStatefulWidget {
  const ProfileEditorPage({super.key, this.profile});

  final Profile? profile;

  @override
  ConsumerState<ProfileEditorPage> createState() => _ProfileEditorPageState();
}

class _ProfileEditorPageState extends ConsumerState<ProfileEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _height;
  late final TextEditingController _minWeight;
  late final TextEditingController _maxWeight;
  late Sex _sex;
  late DateTime _birthDate;
  late bool _syncToHealth;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _name = TextEditingController(text: profile?.name ?? '');
    _height = TextEditingController(text: profile?.heightCm.toString() ?? '175');
    _minWeight = TextEditingController(
      text: formatDecimal(profile?.minWeightKg ?? 50),
    );
    _maxWeight = TextEditingController(
      text: formatDecimal(profile?.maxWeightKg ?? 100),
    );
    _sex = profile == null ? Sex.male : Sex.values[profile.sex];
    _birthDate = profile?.birthDate ?? DateTime(1990, 1, 1);
    _syncToHealth = profile?.syncToHealth ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    _minWeight.dispose();
    _maxWeight.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      helpText: 'Datum rođenja',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final db = ref.read(databaseProvider);
    await db.upsertProfile(
      ProfilesCompanion(
        id: widget.profile == null
            ? const Value.absent()
            : Value(widget.profile!.id),
        name: Value(_name.text.trim()),
        sex: Value(_sex.index),
        birthDate: Value(_birthDate),
        heightCm: Value(int.parse(_height.text)),
        minWeightKg: Value(_parseWeight(_minWeight.text)!),
        maxWeightKg: Value(_parseWeight(_maxWeight.text)!),
        syncToHealth: Value(_syncToHealth),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Novi profil' : 'Uredi profil'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
            tooltip: 'Spremi',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Ime',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Upiši ime' : null,
            ),
            const SizedBox(height: 16),
            SegmentedButton<Sex>(
              segments: const [
                ButtonSegment(value: Sex.male, label: Text('Muško')),
                ButtonSegment(value: Sex.female, label: Text('Žensko')),
              ],
              selected: {_sex},
              onSelectionChanged: (value) => setState(() => _sex = value.first),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cake_outlined),
              title: const Text('Datum rođenja'),
              subtitle: Text(formatDate(_birthDate)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _pickBirthDate,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _height,
              decoration: const InputDecoration(
                labelText: 'Visina',
                suffixText: 'cm',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final height = int.tryParse(value ?? '');
                if (height == null || height < 90 || height > 220) {
                  return 'Upiši visinu između 90 i 220 cm';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Raspon težine',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Text(
              'Po ovom rasponu aplikacija prepoznaje kome pripada mjerenje. '
              'Rasponi različitih profila ne smiju se preklapati.',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minWeight,
                    decoration: const InputDecoration(
                      labelText: 'Od',
                      suffixText: 'kg',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _validateWeight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _maxWeight,
                    decoration: const InputDecoration(
                      labelText: 'Do',
                      suffixText: 'kg',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final basic = _validateWeight(value);
                      if (basic != null) return basic;
                      final min = _parseWeight(_minWeight.text);
                      final max = _parseWeight(value);
                      if (min != null && max != null && max <= min) {
                        return 'Mora biti veće od donje granice';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _syncToHealth,
              onChanged: (value) => setState(() => _syncToHealth = value),
              title: const Text('Šalji u Apple Health / Health Connect'),
              subtitle: const Text(
                'Samo jedan profil može pisati u Health, jer je to zdravstveni '
                'karton vlasnika telefona.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String? _validateWeight(String? value) {
    final weight = _parseWeight(value);
    if (weight == null || weight < 10 || weight > 200) {
      return 'Upiši težinu između 10 i 200 kg';
    }
    return null;
  }

  /// Prihvaća i zarez i točku kao decimalni separator.
  static double? _parseWeight(String? value) =>
      double.tryParse((value ?? '').trim().replaceAll(',', '.'));
}
