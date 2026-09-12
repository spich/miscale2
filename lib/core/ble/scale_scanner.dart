import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'mi_scale_parser.dart';
import 'scale_reading.dart';

enum ScannerStatus { idle, unsupported, permissionDenied, bluetoothOff, scanning }

class ScannerException implements Exception {
  ScannerException(this.status, this.message);
  final ScannerStatus status;
  final String message;
  @override
  String toString() => message;
}

/// Skenira BLE okolinu i pretvara advertisemente Xiaomi vaga u [ScaleReading].
///
/// Vaga se ne spaja niti upari — sve podatke emitira u advertisementu, pa je
/// dovoljno slušati. Zato skener radi samo dok je zaslon za vaganje otvoren.
class ScaleScanner {
  StreamController<ScaleReading>? _controller;
  StreamSubscription<List<ScanResult>>? _resultsSub;

  bool get isScanning => _controller != null;

  /// Stream očitanja; zatvara se pozivom [stop]. Baca [ScannerException] ako
  /// Bluetooth nije dostupan ili dozvole nisu odobrene.
  Stream<ScaleReading> start() {
    stop();
    final controller = StreamController<ScaleReading>.broadcast(
      onCancel: stop,
    );
    _controller = controller;

    unawaited(_run(controller));
    return controller.stream;
  }

  Future<void> _run(StreamController<ScaleReading> controller) async {
    try {
      if (!await FlutterBluePlus.isSupported) {
        throw ScannerException(
          ScannerStatus.unsupported,
          'Ovaj uređaj nema Bluetooth Low Energy.',
        );
      }
      await _ensurePermissions();

      if (Platform.isAndroid &&
          FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
        await FlutterBluePlus.turnOn();
      }
      final state = await FlutterBluePlus.adapterState
          .firstWhere((s) => s != BluetoothAdapterState.turningOn)
          .timeout(const Duration(seconds: 10),
              onTimeout: () => BluetoothAdapterState.unknown);
      if (state != BluetoothAdapterState.on) {
        throw ScannerException(
          ScannerStatus.bluetoothOff,
          'Uključi Bluetooth pa pokušaj ponovno.',
        );
      }

      _resultsSub = FlutterBluePlus.onScanResults.listen((results) {
        for (final result in results) {
          final reading = MiScaleParser.parse(
            {
              for (final entry in result.advertisementData.serviceData.entries)
                entry.key.str: entry.value,
            },
            deviceId: result.device.remoteId.str,
          );
          if (reading != null && !controller.isClosed) {
            controller.add(reading);
          }
        }
      }, onError: controller.addError);

      await FlutterBluePlus.startScan(
        // Vaga ponavlja advertisement sa svakim novim očitanjem; bez ovoga
        // flutter_blue_plus prijavi uređaj samo jednom.
        continuousUpdates: true,
        androidScanMode: AndroidScanMode.lowLatency,
      );
    } catch (error, stack) {
      if (!controller.isClosed) controller.addError(error, stack);
      await stop();
    }
  }

  Future<void> _ensurePermissions() async {
    final needed = Platform.isAndroid
        ? [
            Permission.bluetoothScan,
            Permission.bluetoothConnect,
            // Android 11 i stariji traže lokaciju za BLE skeniranje.
            Permission.locationWhenInUse,
          ]
        : [Permission.bluetooth];

    final statuses = await needed.request();
    final denied = statuses.entries
        .where((e) => e.value.isPermanentlyDenied || e.value.isDenied)
        .map((e) => e.key)
        .toList();

    // Na Androidu 12+ lokacija nije potrebna ako je bluetoothScan odobren.
    final blocking = denied
        .where((p) =>
            p != Permission.locationWhenInUse ||
            statuses[Permission.bluetoothScan]?.isGranted != true)
        .toList();

    if (blocking.isNotEmpty) {
      throw ScannerException(
        ScannerStatus.permissionDenied,
        'Aplikacija treba dozvolu za Bluetooth kako bi pronašla vagu.',
      );
    }
  }

  Future<void> stop() async {
    await _resultsSub?.cancel();
    _resultsSub = null;
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
    final controller = _controller;
    _controller = null;
    await controller?.close();
  }
}
