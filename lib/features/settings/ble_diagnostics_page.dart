import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ble/ble_advertisement.dart';
import '../../core/ble/mi_scale_parser.dart';
import '../../core/ble/scale_scanner.dart';
import '../../providers.dart';

/// Ispisuje sve BLE advertisemente u dometu. Služi kad aplikacija ne
/// prepozna vagu: iz sirovog paketa se vidi pod kojim se servisom javlja i
/// je li format onaj koji parser očekuje.
class BleDiagnosticsPage extends ConsumerStatefulWidget {
  const BleDiagnosticsPage({super.key});

  @override
  ConsumerState<BleDiagnosticsPage> createState() => _BleDiagnosticsPageState();
}

class _BleDiagnosticsPageState extends ConsumerState<BleDiagnosticsPage> {
  final Map<String, BleAdvertisement> _devices = {};
  final Map<String, int> _packetCounts = {};
  StreamSubscription<BleAdvertisement>? _sub;
  String? _error;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _sub?.cancel();
    unawaited(ref.read(scaleScannerProvider).stop());
    super.dispose();
  }

  void _start() {
    setState(() {
      _error = null;
      _scanning = true;
      _devices.clear();
      _packetCounts.clear();
    });

    _sub?.cancel();
    _sub = ref.read(scaleScannerProvider).startRaw().listen(
      (advertisement) {
        if (!mounted) return;
        setState(() {
          _devices[advertisement.deviceId] = advertisement;
          _packetCounts.update(
            advertisement.deviceId,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _error = error is ScannerException ? error.message : '$error';
          _scanning = false;
        });
      },
      onDone: () {
        if (mounted) setState(() => _scanning = false);
      },
    );
  }

  Future<void> _stop() async {
    await _sub?.cancel();
    _sub = null;
    await ref.read(scaleScannerProvider).stop();
    if (mounted) setState(() => _scanning = false);
  }

  List<BleAdvertisement> get _sorted {
    final list = _devices.values.toList();
    list.sort((a, b) {
      final byRelevance = _relevance(b).compareTo(_relevance(a));
      return byRelevance != 0 ? byRelevance : b.rssi.compareTo(a.rssi);
    });
    return list;
  }

  /// Prvo prepoznata vaga, pa uređaj koji se zove kao Xiaomi vaga, pa svi
  /// koji uopće objavljuju service data — ostalo je šum iz okoline.
  static int _relevance(BleAdvertisement device) {
    if (device.isRecognizedScale) return 3;
    if (MiScaleParser.isKnownScaleName(device.name)) return 2;
    if (device.serviceData.isNotEmpty) return 1;
    return 0;
  }

  String _asText() {
    final buffer = StringBuffer('BLE dijagnostika\n');
    for (final device in _sorted) {
      buffer
        ..writeln('---')
        ..writeln('naziv: ${device.name.isEmpty ? '(bez imena)' : device.name}')
        ..writeln('id: ${device.deviceId}  rssi: ${device.rssi} dBm')
        ..writeln('paketa: ${_packetCounts[device.deviceId]}')
        ..writeln('servisi: ${device.serviceUuids.join(', ')}');
      device.serviceData.forEach((uuid, bytes) {
        buffer.writeln(
          'service data $uuid (${bytes.length} B): ${BleAdvertisement.hex(bytes)}',
        );
      });
      device.manufacturerData.forEach((id, bytes) {
        buffer.writeln(
          'manufacturer 0x${id.toRadixString(16)} (${bytes.length} B): '
          '${BleAdvertisement.hex(bytes)}',
        );
      });
      if (device.reading != null) {
        buffer.writeln('parsirano: ${device.reading}');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final devices = _sorted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE dijagnostika'),
        actions: [
          IconButton(
            tooltip: 'Kopiraj ispis',
            icon: const Icon(Icons.copy_all),
            onPressed: devices.isEmpty
                ? null
                : () async {
                    await Clipboard.setData(ClipboardData(text: _asText()));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ispis kopiran.')),
                      );
                    }
                  },
          ),
          IconButton(
            tooltip: _scanning ? 'Zaustavi' : 'Skeniraj',
            icon: Icon(_scanning ? Icons.stop : Icons.refresh),
            onPressed: _scanning ? _stop : _start,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_scanning) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _error ??
                  'Stani na vagu dok skeniranje traje. Traži uređaj čiji se '
                      'service data mijenja s težinom.',
              style: TextStyle(
                color: _error == null
                    ? null
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          Expanded(
            child: devices.isEmpty
                ? const Center(child: Text('Nema uređaja u dometu.'))
                : ListView.separated(
                    itemCount: devices.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) =>
                        _DeviceTile(
                      advertisement: devices[index],
                      packets: _packetCounts[devices[index].deviceId] ?? 0,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.advertisement, required this.packets});

  final BleAdvertisement advertisement;
  final int packets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monospace = theme.textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
    );

    final looksLikeScale = advertisement.isRecognizedScale ||
        MiScaleParser.isKnownScaleName(advertisement.name);

    return ExpansionTile(
      initiallyExpanded: looksLikeScale,
      leading: Icon(
        looksLikeScale ? Icons.monitor_weight : Icons.bluetooth,
        color: looksLikeScale ? theme.colorScheme.primary : null,
      ),
      title: Text(
        advertisement.name.isEmpty ? '(bez imena)' : advertisement.name,
      ),
      subtitle: Text(
        '${advertisement.deviceId} · ${advertisement.rssi} dBm · '
        '$packets paketa',
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (advertisement.serviceUuids.isNotEmpty)
          Text('servisi: ${advertisement.serviceUuids.join(', ')}',
              style: monospace),
        for (final entry in advertisement.serviceData.entries)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'service data ${entry.key} (${entry.value.length} B)\n'
              '${BleAdvertisement.hex(entry.value)}',
              style: monospace,
            ),
          ),
        for (final entry in advertisement.manufacturerData.entries)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'manufacturer 0x${entry.key.toRadixString(16)} '
              '(${entry.value.length} B)\n'
              '${BleAdvertisement.hex(entry.value)}',
              style: monospace,
            ),
          ),
        if (advertisement.serviceData.isEmpty &&
            advertisement.manufacturerData.isEmpty)
          Text('nema service ni manufacturer podataka', style: monospace),
        if (advertisement.reading != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'parsirano: ${advertisement.reading}',
              style: monospace?.copyWith(color: theme.colorScheme.primary),
            ),
          ),
      ],
    );
  }
}
