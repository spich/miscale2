/// Sirovo očitanje s Xiaomi vage, onako kako ga vaga emitira u BLE
/// advertisementu (prije izračuna sastava tijela).
class ScaleReading {
  const ScaleReading({
    required this.weightKg,
    required this.impedance,
    required this.isStabilized,
    required this.isWeightRemoved,
    required this.unit,
    required this.scaleTimestamp,
    required this.deviceId,
  });

  /// Težina uvijek u kilogramima, neovisno o jedinici postavljenoj na vagi.
  final double weightKg;

  /// Bio-impedancija u ohmima; `null` ako je vaga još nije izmjerila.
  final int? impedance;

  /// Mjerenje je stabilizirano (korisnik mirno stoji na vagi).
  final bool isStabilized;

  /// Korisnik je sišao s vage.
  final bool isWeightRemoved;

  /// Jedinica prikazana na vagi.
  final ScaleUnit unit;

  /// Vrijeme koje javlja sama vaga (njezin interni sat zna odlutati).
  final DateTime? scaleTimestamp;

  /// BLE identifikator vage (MAC na Androidu, UUID na iOS-u).
  final String deviceId;

  bool get hasImpedance => impedance != null;

  /// Mjerenje spremno za pohranu: stabilizirano, s impedancijom i
  /// smislenom težinom.
  bool get isComplete =>
      isStabilized && !isWeightRemoved && hasImpedance && weightKg > 0;

  @override
  String toString() =>
      'ScaleReading(${weightKg.toStringAsFixed(2)} kg, imp: $impedance, '
      'stabilized: $isStabilized, removed: $isWeightRemoved)';
}

enum ScaleUnit { kg, lbs, catty }
