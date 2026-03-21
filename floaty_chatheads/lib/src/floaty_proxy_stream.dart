import 'dart:async';

import 'package:floaty_chatheads/src/floaty_channel.dart';

/// {@template floaty_proxy_stream}
/// A typed, reactive, **unidirectional** stream that pushes values from the
/// main app to the overlay.
///
/// Unlike `FloatyStateChannel` (which is bidirectional and supports partial
/// updates), `FloatyProxyStream` is a simple main-to-overlay push pipe
/// optimised for high-frequency data such as GPS coordinates, sensor
/// readings, or media playback progress.
///
/// **Main app side:**
///
/// ```dart
/// final gps = FloatyProxyStream<LatLng>(
///   name: 'gps',
///   toJson: (p) => {'lat': p.lat, 'lng': p.lng},
/// );
///
/// positionStream.listen((pos) {
///   gps.add(LatLng(pos.latitude, pos.longitude));
/// });
/// ```
///
/// **Overlay side:**
///
/// ```dart
/// final gps = FloatyProxyStream<LatLng>.overlay(
///   name: 'gps',
///   fromJson: (j) => LatLng(j['lat'] as double, j['lng'] as double),
/// );
///
/// gps.stream.listen((pos) => updateMarker(pos));
/// print(gps.latest); // last received value, or null
/// ```
///
/// Each stream is identified by [name]; multiple independent streams can
/// coexist (e.g. `'gps'`, `'gyroscope'`, `'playback'`).
///
/// The class uses a dedicated channel prefix (`_floaty_pstream`) that does
/// not collide with `FloatyStateChannel`, `FloatyActionRouter`, or
/// `FloatyProxyHost`/`FloatyProxyClient`.
/// {@endtemplate}
final class FloatyProxyStream<T> {
  /// {@template floaty_proxy_stream.main}
  /// Creates a proxy stream for the **main app** side (producer).
  ///
  /// [name] identifies this stream (must match the overlay subscriber).
  /// [toJson] serializes each value for transmission over the platform
  /// channel.
  /// {@endtemplate}
  FloatyProxyStream({
    required this.name,
    required Map<String, dynamic> Function(T value) toJson,
  })  : _toJson = toJson,
        _fromJson = null {
    _Registry._register(this);
  }

  /// {@template floaty_proxy_stream.overlay}
  /// Creates a proxy stream for the **overlay** side (consumer).
  ///
  /// [name] must match the main-app producer's name.
  /// [fromJson] deserializes incoming values.
  /// {@endtemplate}
  FloatyProxyStream.overlay({
    required this.name,
    required T Function(Map<String, dynamic> json) fromJson,
  })  : _toJson = null,
        _fromJson = fromJson {
    _Registry._register(this);
  }

  static const _prefix = '_floaty_pstream';

  /// The name identifying this stream.
  final String name;

  final Map<String, dynamic> Function(T value)? _toJson;
  final T Function(Map<String, dynamic> json)? _fromJson;

  final StreamController<T> _controller = StreamController<T>.broadcast();

  /// The last value received (overlay side) or pushed (main app side).
  ///
  /// `null` until the first value arrives or is pushed.
  T? _latest;

  /// The last value received (overlay) or pushed (main app).
  ///
  /// Returns `null` before the first value.
  T? get latest => _latest;

  /// A broadcast stream of incoming values (overlay side).
  ///
  /// On the main-app side, this stream echoes values passed to [add]
  /// — useful for widget rebuilds in response to your own pushes.
  Stream<T> get stream => _controller.stream;

  /// Pushes a new value to the overlay.
  ///
  /// This should only be called on the **main app** side (the producer).
  /// On the overlay side it is a no-op.
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

  /// Called by the shared [_Registry] handler when a message with
  /// a matching [name] arrives.
  void _onMessage(Map<String, dynamic> data) {
    final fromJson = _fromJson;
    if (fromJson == null) return;

    try {
      final value = fromJson(data);
      _latest = value;
      _controller.add(value);
    } on Object {
      // Deserialization error — silently ignore to avoid crashing the
      // message loop.
    }
  }

  /// Releases resources and removes this instance from the shared
  /// registry. If this was the last instance, the channel handler is
  /// unregistered.
  void dispose() {
    _Registry._unregister(this);
    unawaited(_controller.close());
  }
}

/// Shared, single-handler registry that multiplexes incoming messages
/// to the correct [FloatyProxyStream] instance by `name`.
///
/// This avoids the problem of multiple instances overwriting each
/// other's [FloatyChannel.registerHandler] — only one handler is
/// registered for the `_floaty_pstream` prefix, and it fans out to all
/// active instances.
class _Registry {
  _Registry._(); // coverage:ignore-line

  static final Map<String, FloatyProxyStream<dynamic>> _streams = {};
  static bool _handlerRegistered = false;

  static void _register(FloatyProxyStream<dynamic> stream) {
    _streams[stream.name] = stream;
    if (!_handlerRegistered) {
      FloatyChannel.registerHandler(
        FloatyProxyStream._prefix,
        _onMessage,
      );
      FloatyChannel.ensureListening();
      _handlerRegistered = true;
    }
  }

  static void _unregister(FloatyProxyStream<dynamic> stream) {
    _streams.remove(stream.name);
    if (_streams.isEmpty && _handlerRegistered) {
      FloatyChannel.unregisterHandler(FloatyProxyStream._prefix);
      _handlerRegistered = false;
    }
  }

  static void _onMessage(Map<String, dynamic> envelope) {
    final msgName = envelope['name'] as String?;
    if (msgName == null) return;

    final raw = envelope['data'];
    if (raw is! Map) return;

    final stream = _streams[msgName];
    if (stream == null) return;

    stream._onMessage(raw.cast<String, dynamic>());
  }
}
