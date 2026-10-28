part of '../floaty_proxy_stream.dart';

/// Single channel handler that fans incoming messages out to the
/// [FloatyProxyStream] instance with the matching name, so instances never
/// overwrite each other's handler.
final class _Registry {
  static final Map<String, FloatyProxyStream<dynamic>> _streams = {};
  static bool _handlerRegistered = false;

  static void _register(FloatyProxyStream<dynamic> stream) {
    if (_streams.containsKey(stream.name)) {
      throw StateError(
        'A FloatyProxyStream named "${stream.name}" is already registered. '
        'Dispose the existing instance before creating a new one, or use a '
        'different name.',
      );
    }
    _streams[stream.name] = stream;
    if (_handlerRegistered) return;
    FloatyChannel.registerHandler(FloatyProxyStream._prefix, _onMessage);
    FloatyChannel.ensureListening();
    _handlerRegistered = true;
  }

  static void _unregister(FloatyProxyStream<dynamic> stream) {
    _streams.remove(stream.name);
    if (_streams.isNotEmpty || !_handlerRegistered) return;
    FloatyChannel.unregisterHandler(FloatyProxyStream._prefix);
    _handlerRegistered = false;
  }

  static void _onMessage(Map<String, dynamic> envelope) {
    final raw = envelope['data'];
    final stream = _streams[envelope['name'] as String?];
    if (raw is! Map || stream == null) return;
    stream._onMessage(raw.cast<String, dynamic>());
  }
}
