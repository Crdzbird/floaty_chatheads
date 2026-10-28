import 'package:floaty_chatheads/floaty_chatheads.dart';

/// Simulated GPS coordinate with heading and speed.
final class GpsCoord {
  /// Creates a coordinate reading.
  const factory GpsCoord({
    required double lat,
    required double lng,
    required double heading,
    required double speed,
  }) = GpsCoord._;

  const GpsCoord._({
    required this.lat,
    required this.lng,
    required this.heading,
    required this.speed,
  });

  /// Decodes a coordinate sent over the proxy stream.
  factory GpsCoord.fromJson(Map<String, dynamic> json) => GpsCoord(
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    heading: (json['heading'] as num).toDouble(),
    speed: (json['speed'] as num).toDouble(),
  );

  /// Key of the `gps` proxy stream shared by the app and the overlay.
  static final streamKey = StreamKey<GpsCoord>(
    name: 'gps',
    toJson: (c) => c.toJson(),
    fromJson: GpsCoord.fromJson,
  );

  /// Latitude in degrees.
  final double lat;

  /// Longitude in degrees.
  final double lng;

  /// Heading in degrees, 0 to 360.
  final double heading;

  /// Speed in km/h.
  final double speed;

  /// Encodes the coordinate for the proxy stream.
  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    'heading': heading,
    'speed': speed,
  };
}
