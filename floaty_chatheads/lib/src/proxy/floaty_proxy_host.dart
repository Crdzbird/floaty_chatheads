import 'dart:async';

import 'package:floaty_chatheads/src/floaty_channel.dart';

/// Main-app-side proxy host that registers service providers.
///
/// The overlay calls services registered here through
/// `FloatyProxyClient`. Each service receives a method name and
/// parameters and returns a JSON-compatible result:
///
/// ```dart
/// final host = FloatyProxyHost()
///   ..register('location', (method, params) async {
///     final pos = await Geolocator.getCurrentPosition();
///     return {'lat': pos.latitude, 'lng': pos.longitude};
///   });
/// ```
final class FloatyProxyHost {
  /// Creates a host and attaches it to the shared channel.
  factory FloatyProxyHost() = FloatyProxyHost._;

  FloatyProxyHost._() {
    FloatyChannel.registerHandler(_prefix, _onMessage);
    FloatyChannel.ensureListening();
  }

  static const _prefix = '_floaty_proxy';

  final Map<
    String,
    FutureOr<Object?> Function(String method, Map<String, dynamic> params)
  >
  _services = {};

  /// Registers [handler] as the provider for [service] (e.g. `'location'`).
  void register(
    String service,
    FutureOr<Object?> Function(String method, Map<String, dynamic> params)
    handler,
  ) {
    _services[service] = handler;
  }

  /// Removes a registered service provider.
  void unregister(String service) {
    _services.remove(service);
  }

  Future<void> _onMessage(Map<String, dynamic> envelope) async {
    final type = envelope['type'] as String?;
    if (type != 'request') return;
    final id = envelope['id'] as String?;
    final service = envelope['service'] as String?;
    final method = envelope['method'] as String?;
    final params =
        (envelope['params'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    if (id == null || service == null || method == null) return;
    final handler = _services[service];
    if (handler == null) {
      return await _respond(id, error: 'Unknown service: $service');
    }
    try {
      final result = await handler(method, params);
      await _respond(id, result: result);
    } on Object catch (e) {
      await _respond(id, error: e.toString());
    }
  }

  Future<void> _respond(String id, {Object? result, String? error}) =>
      FloatyChannel.sendSystem(_prefix, {
        'id': id,
        'type': 'response',
        'result': result,
        'error': error,
      });

  /// Releases resources and unregisters the channel handler.
  void dispose() {
    FloatyChannel.unregisterHandler(_prefix);
    _services.clear();
  }
}
