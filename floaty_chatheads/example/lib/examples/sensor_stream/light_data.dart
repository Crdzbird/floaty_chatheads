import 'package:floaty_chatheads/floaty_chatheads.dart';

/// Simulated light sensor reading.
final class LightData {
  /// Creates a reading of [lux] with a human readable [label].
  const factory LightData({required double lux, required String label}) =
      LightData._;

  const LightData._({required this.lux, required this.label});

  /// Decodes a reading sent over the proxy stream.
  factory LightData.fromJson(Map<String, dynamic> json) => LightData(
        lux: (json['lux'] as num).toDouble(),
        label: json['label'] as String,
      );

  /// Key of the `light` proxy stream shared by the app and the overlay.
  static final streamKey = StreamKey<LightData>(
    name: 'light',
    toJson: (d) => d.toJson(),
    fromJson: LightData.fromJson,
  );

  /// Illuminance in lux.
  final double lux;

  /// Label such as Dark, Indoor or Bright.
  final String label;

  /// Encodes the reading for the proxy stream.
  Map<String, dynamic> toJson() => {'lux': lux, 'label': label};
}
