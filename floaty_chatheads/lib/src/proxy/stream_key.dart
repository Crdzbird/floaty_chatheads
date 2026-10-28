import 'package:flutter/foundation.dart' show immutable;

/// Compile-time link between a stream [name], its payload type [T], and
/// the JSON converters used on both sides.
///
/// Define the key once (typically as a top-level `const`) and pass it to
/// both the main-app producer and the overlay consumer:
///
/// ```dart
/// const gpsKey = StreamKey<GpsCoord>(
///   name: 'gps',
///   toJson: GpsCoord.encode,
///   fromJson: GpsCoord.decode,
/// );
/// ```
@immutable
final class StreamKey<T> {
  /// Creates a key for the stream called [name].
  const factory StreamKey({
    required String name,
    required Map<String, dynamic> Function(T value) toJson,
    required T Function(Map<String, dynamic> json) fromJson,
  }) = StreamKey<T>._;

  const StreamKey._({
    required this.name,
    required this.toJson,
    required this.fromJson,
  });

  /// Stream identifier shared by producer and consumer.
  final String name;

  /// Serializes a value of [T] to a JSON-compatible map.
  final Map<String, dynamic> Function(T value) toJson;

  /// Deserializes a JSON-compatible map back into [T].
  final T Function(Map<String, dynamic> json) fromJson;
}
