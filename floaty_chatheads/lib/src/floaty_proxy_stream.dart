import 'dart:async';

import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:floaty_chatheads/src/proxy/stream_key.dart';

export 'package:floaty_chatheads/src/proxy/stream_key.dart';

part 'proxy/floaty_proxy_stream_registry.dart';

/// A typed, unidirectional stream that pushes values from the main app to
/// the overlay, for high-frequency data such as GPS coordinates, sensor
/// readings or playback progress.
///
/// ```dart
/// final gps = FloatyProxyStream(gpsKey);           // main app
/// await gps.add(GpsCoord(lat, lng));
///
/// final gps = FloatyProxyStream.overlay(gpsKey);   // overlay
/// gps.stream.listen(updateMarker);
/// ```
///
/// Each stream is identified by its [StreamKey], so several independent
/// streams can coexist. The `_floaty_pstream` channel prefix does not
/// collide with the state channel, action router or proxy.
final class FloatyProxyStream<T> {
  /// Creates the main app side (producer) for [key].
  factory FloatyProxyStream(StreamKey<T> key) = FloatyProxyStream<T>._producer;

  /// Creates the overlay side (consumer) for [key].
  factory FloatyProxyStream.overlay(StreamKey<T> key) =
      FloatyProxyStream<T>._consumer;

  FloatyProxyStream._producer(this._key)
    : _toJson = _key.toJson,
      _fromJson = null {
    _Registry._register(this);
  }

  FloatyProxyStream._consumer(this._key)
    : _toJson = null,
      _fromJson = _key.fromJson {
    _Registry._register(this);
  }

  static const _prefix = '_floaty_pstream';

  final StreamKey<T> _key;
  final Map<String, dynamic> Function(T value)? _toJson;
  final T Function(Map<String, dynamic> json)? _fromJson;
  final StreamController<T> _controller = StreamController<T>.broadcast();
  T? _latest;

  /// The name identifying this stream.
  String get name => _key.name;

  /// The last value received (overlay) or pushed (main app), or `null`
  /// before the first value.
  T? get latest => _latest;

  /// A broadcast stream of incoming values. On the main app side it echoes
  /// the values passed to [add].
  Stream<T> get stream => _controller.stream;

  /// Pushes a new value to the overlay. A no-op on the overlay side.
  Future<void> add(T value) {
    final toJson = _toJson;
    if (toJson == null) return Future<void>.value();
    _latest = value;
    _controller.add(value);
    return FloatyChannel.sendSystem(_prefix, {
      'name': name,
      'data': toJson(value),
    });
  }

  void _onMessage(Map<String, dynamic> data) {
    final fromJson = _fromJson;
    if (fromJson == null) return;
    try {
      final value = fromJson(data);
      _latest = value;
      _controller.add(value);
    } on Object {
      return;
    }
  }

  /// Releases resources and leaves the shared registry. The last instance
  /// to leave unregisters the channel handler.
  Future<void> dispose() async {
    _Registry._unregister(this);
    await _controller.close();
  }
}
