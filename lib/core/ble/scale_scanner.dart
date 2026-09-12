import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ble_advertisement.dart';
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
  _ScanSession? _session;

  bool get isScanning => _session != null;

  /// Stream očitanja s prepoznate vage; zatvara se pozivom [stop]. Baca
  /// [ScannerException] ako Bluetooth nije dostupan ili dozvole nisu odobrene.
  Stream<ScaleReading> start() => startRaw()
      .map((advertisement) => advertisement.reading)
      .where((reading) => reading != null)
      .cast<ScaleReading>();

  /// Svi advertisementi u dometu, neovisno o tome je li riječ o vagi.
  /// Koristi ga dijagnostički zaslon.
  Stream<BleAdvertisement> startRaw() {
    final previous = _session;
    final session = _ScanSession(_toAdvertisement);
    _session = session;

    // Gašenje prethodnog skeniranja mora se dovršiti prije pokretanja novog,
    // inače bi ono zatvorilo tek otvoreni stream.
    unawaited(() async {
      await previous?.dispose();
      if (!identical(_session, session)) return;
      await session.run();
    }());

    session.controller.onCancel = () => _disposeIfCurrent(session);
    return session.controller.stream;
  }

  Future<void> stop() async {
    final session = _session;
    _session = null;
    await session?.dispose();
  }

  Future<void> _disposeIfCurrent(_ScanSession session) async {
    if (identical(_session, session)) _session = null;
    await session.dispose();
  }

  BleAdvertisement _toAdvertisement(ScanResult result) {
    final advertisement = result.advertisementData;
    final serviceData = {
      for (final entry in advertisement.serviceData.entries)
        entry.key.str: entry.value,
    };
    final deviceId = result.device.remoteId.str;
    final name = advertisement.advName.isNotEmpty
        ? advertisement.advName
        : result.device.platformName;

    return BleAdvertisement(
      deviceId: deviceId,
      name: name,
      rssi: result.rssi,
      serviceUuids: advertisement.serviceUuids.map((g) => g.str).toList(),
      serviceData: serviceData,
      manufacturerData: advertisement.manufacturerData,
      seenAt: DateTime.now(),
      reading: MiScaleParser.parse(
        serviceData,
        deviceId: deviceId,
        deviceName: name,
      ),
    );
  }
}

/// Jedno skeniranje: vlastiti stream i pretplata, da se dva uzastopna
/// pokretanja ne mogu ispreplesti.
class _ScanSession {
  _ScanSession(this._convert);

  final BleAdvertisement Function(ScanResult) _convert;
  final StreamController<BleAdvertisement> controller =
      StreamController<BleAdvertisement>.broadcast();

  StreamSubscription<List<ScanResult>>? _resultsSub;
  bool _disposed = false;

  Future<void> run() async {
    try {
      if (!await FlutterBluePlus.isSupported) {
        throw ScannerException(
          ScannerStatus.unsupported,
          'Ovaj uređaj nema Bluetooth Low Energy.',
        );
      }
      await _ensurePermissions();
      if (_disposed) return;

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
      if (_disposed) return;

      // Pretplata mora postojati prije startScan, inače se propuste prvi
      // paketi; onScanResults ionako preskače rezultate prethodnog skeniranja.
      _resultsSub = FlutterBluePlus.onScanResults.listen((results) {
        if (_disposed || controller.isClosed) return;
        for (final result in results) {
          controller.add(_convert(result));
        }
      }, onError: (Object error, StackTrace stack) {
        if (!controller.isClosed) controller.addError(error, stack);
      });

      await FlutterBluePlus.startScan(
        // Vaga ponavlja advertisement sa svakim novim očitanjem; bez ovoga
        // flutter_blue_plus prijavi uređaj samo jednom.
        continuousUpdates: true,
        androidScanMode: AndroidScanMode.lowLatency,
      );
    } catch (error, stack) {
      if (!controller.isClosed) controller.addError(error, stack);
      await dispose();
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

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _resultsSub?.cancel();
    _resultsSub = null;
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
    if (!controller.isClosed) await controller.close();
  }
}
