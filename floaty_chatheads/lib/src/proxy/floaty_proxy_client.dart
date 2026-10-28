import 'dart:async';

import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:floaty_chatheads/src/floaty_connection_state.dart';
import 'package:floaty_chatheads/src/proxy/floaty_proxy_disconnected_exception.dart';
import 'package:floaty_chatheads/src/proxy/floaty_proxy_error_exception.dart';
import 'package:floaty_chatheads/src/proxy/floaty_proxy_timeout_exception.dart';

/// Overlay-side proxy client that calls services on the main app, e.g.
/// `await FloatyProxyClient().call('location', 'getCurrentPosition')`.
///
/// Throws [FloatyProxyDisconnectedException] when the main app is not
/// connected (unless a `fallback` is given), [FloatyProxyTimeoutException]
/// when the call takes longer than [timeout], and
/// [FloatyProxyErrorException] when the host handler threw.
final class FloatyProxyClient {
  /// Creates a client whose calls time out after [timeout].
  factory FloatyProxyClient({Duration timeout}) = FloatyProxyClient._;

  FloatyProxyClient._({this.timeout = const Duration(seconds: 10)}) {
    FloatyChannel.registerHandler(_prefix, _onMessage);
    FloatyChannel.ensureListening();
  }

  static const _prefix = '_floaty_proxy';

  /// Default timeout for each proxy call.
  final Duration timeout;

  final Map<String, Completer<Object?>> _pending = {};
  final Map<String, Timer> _timers = {};
  int _nextId = 0;

  /// Calls [method] of [service] on the main app and returns its result.
  ///
  /// When the main app is disconnected, returns [fallback]'s value if
  /// given, and throws [FloatyProxyDisconnectedException] otherwise.
  Future<Object?> call(
    String service,
    String method, {
    Map<String, dynamic> params = const {},
    Object? Function()? fallback,
  }) async {
    if (!FloatyConnectionState.isMainAppConnected) {
      if (fallback != null) return fallback();
      throw FloatyProxyDisconnectedException(service, method);
    }
    final id = '${_nextId++}';
    final completer = Completer<Object?>();
    _pending[id] = completer;
    _timers[id] = Timer(timeout, () {
      _pending.remove(id);
      _timers.remove(id);
      if (completer.isCompleted) return;
      completer.completeError(FloatyProxyTimeoutException(service, method));
    });
    final sent = FloatyChannel.sendSystem(_prefix, {
      'id': id,
      'type': 'request',
      'service': service,
      'method': method,
      'params': params,
    });
    final results = await Future.wait<Object?>([
      completer.future,
      sent,
    ], eagerError: true);
    return results.first;
  }

  void _onMessage(Map<String, dynamic> envelope) {
    final type = envelope['type'] as String?;
    final id = envelope['id'] as String?;
    if (type != 'response' || id == null) return;
    final completer = _pending.remove(id);
    if (completer == null) return;
    _timers.remove(id)?.cancel();
    final error = envelope['error'];
    if (error != null) {
      completer.completeError(FloatyProxyErrorException(error.toString()));
      return;
    }
    completer.complete(envelope['result']);
  }

  /// Releases resources and cancels all pending requests.
  void dispose() {
    FloatyChannel.unregisterHandler(_prefix);
    _timers.values.forEach(_cancel);
    _timers.clear();
    _pending.values.where((c) => !c.isCompleted).forEach(_fail);
    _pending.clear();
  }

  static void _cancel(Timer timer) => timer.cancel();

  static void _fail(Completer<Object?> completer) => completer.completeError(
    const FloatyProxyErrorException('Client disposed'),
  );
}
