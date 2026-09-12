import 'scale_reading.dart';

/// Sirovi BLE advertisement, onakav kakav stigne s uređaja. Služi
/// dijagnostici: po njemu se vidi kojim servisom i u kojem formatu se vaga
/// javlja ako je standardni parser ne prepozna.
class BleAdvertisement {
  BleAdvertisement({
    required this.deviceId,
    required this.name,
    required this.rssi,
    required this.serviceUuids,
    required this.serviceData,
    required this.manufacturerData,
    required this.seenAt,
    required this.reading,
  });

  final String deviceId;
  final String name;
  final int rssi;
  final List<String> serviceUuids;
  final Map<String, List<int>> serviceData;
  final Map<int, List<int>> manufacturerData;
  final DateTime seenAt;

  /// Rezultat parsiranja, ako je advertisement prepoznat kao vaga.
  final ScaleReading? reading;

  bool get isRecognizedScale => reading != null;

  static String hex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
}
