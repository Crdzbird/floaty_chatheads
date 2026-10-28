import 'package:floaty_chatheads/floaty_chatheads.dart';

/// Simulated accelerometer reading.
final class AccelData {
  /// Creates a reading with the three axis values.
  const factory AccelData({
    required double x,
    required double y,
    required double z,
  }) = AccelData._;

  const AccelData._({required this.x, required this.y, required this.z});

  /// Decodes a reading sent over the proxy stream.
  factory AccelData.fromJson(Map<String, dynamic> json) => AccelData(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        z: (json['z'] as num).toDouble(),
      );

  /// Key of the `accel` proxy stream shared by the app and the overlay.
  static final streamKey = StreamKey<AccelData>(
    name: 'accel',
    toJson: (d) => d.toJson(),
    fromJson: AccelData.fromJson,
  );

  /// Acceleration on the X axis.
  final double x;

  /// Acceleration on the Y axis.
  final double y;

  /// Acceleration on the Z axis.
  final double z;

  /// Encodes the reading for the proxy stream.
  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'z': z};
}
