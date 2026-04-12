import 'dart:async';

import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:floaty_chatheads/src/floaty_connection_state.dart';

/// {@template floaty_proxy_exception}
/// Base exception for proxy call failures.
/// {@endtemplate}
abstract class FloatyProxyException implements Exception {
  /// {@macro floaty_proxy_exception}
  const FloatyProxyException(this.message);

  /// Description of the failure.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// {@template floaty_proxy_timeout_exception}
/// Thrown when a proxy call exceeds its timeout.
/// {@endtemplate}
class FloatyProxyTimeoutException extends FloatyProxyException {
  /// {@macro floaty_proxy_timeout_exception}
  const FloatyProxyTimeoutException(String service, String method)
      : super('Proxy call to $service.$method timed out');
}

/// {@template floaty_proxy_error_exception}
/// Thrown when the host-side handler threw an exception.
/// {@endtemplate}
class FloatyProxyErrorException extends FloatyProxyException {
  /// {@macro floaty_proxy_error_exception}
  const FloatyProxyErrorException(super.message);
}

/// {@template floaty_proxy_disconnected_exception}
/// Thrown when a proxy call is attempted while the main app is
/// disconnected.
///
/// This avoids a full timeout wait when the main app is known to be
/// unavailable. Use the optional `fallback` parameter on
/// [FloatyProxyClient.call] to provide a default value instead of
/// throwing.
/// {@endtemplate}
class FloatyProxyDisconnectedException extends FloatyProxyException {
  /// {@macro floaty_proxy_disconnected_exception}
  const FloatyProxyDisconnectedException(String service, String method)
      : super(
          'Main app is disconnected — '
          'cannot call $service.$method',
        );
}

/// {@template floaty_proxy_host}
/// Main-app-side proxy host that registers service providers.
///
/// The overlay can call services registered here via
/// [FloatyProxyClient]. Each service exposes named methods that accept
/// parameters and return results — all serialized as JSON through the
/// shared data channel.
///
/// ```dart
/// final host = FloatyProxyHost();
///
/// host.register('location', (method, params) async {
///   if (method == 'getCurrentPosition') {
///     final pos = await Geolocator.getCurrentPosition();
///     return {'lat': pos.latitude, 'lng': pos.longitude};
///   }
///   return null;
/// });
/// ```
/// {@endtemplate}
final class FloatyProxyHost {
  /// {@macro floaty_proxy_host}
  FloatyProxyHost() {
    FloatyChannel.registerHandler(_prefix, _onMessage);
    FloatyChannel.ensureListening();
  }

  static const _prefix = '_floaty_proxy';

  final Map<
    String,
    FutureOr<Object?> Function(
      String method,
      Map<String, dynamic> params,
    )
  > _services = {};

  /// Registers a service provider.
  ///
  /// [service] is a name string (e.g. `'location'`, `'prefs'`).
  /// [handler] receives the method name and parameters, and returns
  /// the result.
  void register(
    String service,
    FutureOr<Object?> Function(
      String method,
      Map<String, dynamic> params,
    ) handler,
  ) {
    _services[service] = handler;
  }

  /// Removes a registered service provider.
  void unregister(String service) {
    _services.remove(service);
  }

  Future<void> _onMessage(Map<String, dynamic> envelope) async {
    final type = envelope['type'] as String?;
    if (type != 'request') return; // Only handle requests.

    final id = envelope['id'] as String?;
    final service = envelope['service'] as String?;
    final method = envelope['method'] as String?;
    final params =
        (envelope['params'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    if (id == null || service == null || method == null) return;

    final handler = _services[service];
    if (handler == null) {
      await FloatyChannel.sendSystem(_prefix, {
        'id': id,
        'type': 'response',
        'result': null,
        'error': 'Unknown service: $service',
      });
      return;
    }

    try {
      final result = await handler(method, params);
      await FloatyChannel.sendSystem(_prefix, {
        'id': id,
        'type': 'response',
        'result': result,
        'error': null,
      });
    } on Object catch (e) {
      await FloatyChannel.sendSystem(_prefix, {
        'id': id,
        'type': 'response',
        'result': null,
        'error': e.toString(),
      });
    }
  }

  /// Releases resources and unregisters the channel handler.
  void dispose() {
    FloatyChannel.unregisterHandler(_prefix);
    _services.clear();
  }
}

/// {@template floaty_proxy_client}
/// Overlay-side proxy client that calls services on the main app.
///
/// Send requests to service providers registered on [FloatyProxyHost]
/// and await results.
///
/// ```dart
/// final client = FloatyProxyClient();
///
/// final result = await client.call('location', 'getCurrentPosition');
/// // result == {'lat': 12.0, 'lng': -86.0}
/// ```
///
/// Throws [FloatyProxyDisconnectedException] if the main app is not
/// connected (unless a `fallback` is provided),
/// [FloatyProxyTimeoutException] if the call takes longer than
/// [timeout], and [FloatyProxyErrorException] if the host handler
/// threw.
/// {@endtemplate}
final class FloatyProxyClient {
  /// {@macro floaty_proxy_client}
  FloatyProxyClient({this.timeout = const Duration(seconds: 10)}) {
    FloatyChannel.registerHandler(_prefix, _onMessage);
    FloatyChannel.ensureListening();
  }

  static const _prefix = '_floaty_proxy';

  /// Default timeout for each proxy call.
  final Duration timeout;

  final Map<String, Completer<Object?>> _pending = {};
  final Map<String, Timer> _timers = {};
  int _nextId = 0;

  /// Calls a service method on the main app.
  ///
  /// Returns the result, or throws:
  /// - [FloatyProxyDisconnectedException] if the main app is not
  ///   connected (unless [fallback] is provided).
  /// - [FloatyProxyTimeoutException] on timeout.
  /// - [FloatyProxyErrorException] if the host handler threw.
  ///
  /// If [fallback] is provided and the main app is disconnected,
  /// the fallback value is returned instead of throwing.
  Future<Object?> call(
    String service,
    String method, {
    Map<String, dynamic> params = const {},
    Object? Function()? fallback,
  }) {
    // Fail fast if the main app is disconnected.
    if (!FloatyConnectionState.isMainAppConnected) {
      if (fallback != null) {
        return Future<Object?>.value(fallback());
      }
      return Future<Object?>.error(
        FloatyProxyDisconnectedException(service, method),
      );
    }

    final id = '${_nextId++}';
    final completer = Completer<Object?>();
    _pending[id] = completer;

    // Set up timeout.
    _timers[id] = Timer(timeout, () {
      _pending.remove(id);
      _timers.remove(id);
      if (!completer.isCompleted) {
        completer.completeError(
          FloatyProxyTimeoutException(service, method),
        );
      }
    });

    // Intentionally not awaited — the result arrives via the completer
    // when the host responds. The send itself is fire-and-forget.
    unawaited(
      FloatyChannel.sendSystem(_prefix, {
        'id': id,
        'type': 'request',
        'service': service,
        'method': method,
        'params': params,
      }),
    );

    return completer.future;
  }

  void _onMessage(Map<String, dynamic> envelope) {
    final type = envelope['type'] as String?;
    if (type != 'response') return; // Only handle responses.

    final id = envelope['id'] as String?;
    if (id == null) return;

    final completer = _pending.remove(id);
    if (completer == null) return; // Already timed out or unknown.

    _timers.remove(id)?.cancel();

    final error = envelope['error'];
    if (error != null) {
      completer.completeError(
        FloatyProxyErrorException(error.toString()),
      );
    } else {
      completer.complete(envelope['result']);
    }
  }

  /// Releases resources and cancels all pending requests.
  void dispose() {
    FloatyChannel.unregisterHandler(_prefix);
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    for (final completer in _pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(
          const FloatyProxyErrorException('Client disposed'),
        );
      }
    }
    _pending.clear();
  }
}
