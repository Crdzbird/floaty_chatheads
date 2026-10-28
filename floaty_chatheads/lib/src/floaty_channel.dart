import 'dart:async';

import 'package:floaty_chatheads/src/channel/floaty_handler_registry.dart';
import 'package:floaty_chatheads/src/channel/floaty_raw_buffer.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

/// Internal message router for the floaty_chatheads data channel.
///
/// The state channel, action router, proxy and theme delivery share one
/// [BasicMessageChannel]. Messages wrapped in the system envelope are
/// routed by prefix to registered handlers; everything else is forwarded
/// to [rawMessages].
///
/// System messages that arrive before their handler is registered are
/// buffered and replayed on registration. Raw messages that arrive before
/// the first listener are buffered the same way.
///
/// This class is internal and not exported from the public barrel file.
final class FloatyChannel {
  FloatyChannel._();

  static const BasicMessageChannel<Object?> _messenger =
      BasicMessageChannel<Object?>(
        FloatyChannels.messenger,
        JSONMessageCodec(),
      );

  static final FloatyHandlerRegistry _registry = FloatyHandlerRegistry();

  static final FloatyRawBuffer _raw = FloatyRawBuffer();

  static bool _isListening = false;

  /// Stream of raw messages that carry no system envelope.
  static Stream<Object?> get rawMessages {
    ensureListening();
    return _raw.stream;
  }

  /// Routes system messages carrying [prefix] to [handler].
  ///
  /// Messages buffered for [prefix] before this call are replayed in
  /// order.
  static void registerHandler(
    String prefix,
    void Function(Map<String, dynamic> data) handler,
  ) => _registry.register(prefix, handler);

  /// Removes the handler registered for [prefix].
  static void unregisterHandler(String prefix) => _registry.unregister(prefix);

  /// Attaches the shared message handler. Safe to call more than once.
  static void ensureListening() {
    if (_isListening) return;
    _messenger.setMessageHandler(_onMessage);
    _isListening = true;
  }

  /// Sends raw user data through the shared channel.
  static Future<void> send(Object? data) => _messenger.send(data);

  /// Sends [payload] wrapped in the system envelope for [prefix], so user
  /// data can never collide with system routing keys.
  static Future<void> sendSystem(String prefix, Map<String, dynamic> payload) =>
      _messenger.send(<String, Object?>{
        FloatyChannels.envelope: prefix,
        prefix: payload,
      });

  /// Detaches the message handler and forgets every prefix handler and
  /// buffered message. Only for tests: in an app, components remove their
  /// own handlers so they never disconnect each other.
  @visibleForTesting
  static void reset() {
    _messenger.setMessageHandler(null);
    _isListening = false;
    _registry.clear();
    _raw.reset();
  }

  static Future<Object?> _onMessage(Object? message) async {
    if (message is Map &&
        message[FloatyChannels.envelope] == FloatyChannels.ping) {
      return FloatyChannels.pong;
    }
    if (message is Map && _registry.route(message)) return message;
    _raw.emit(message);
    return message;
  }
}
