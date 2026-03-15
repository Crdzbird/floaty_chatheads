import 'dart:async';

import 'package:flutter/services.dart';

/// Internal message router for the floaty_chatheads data channel.
///
/// All three high-level features (state channel, action router, proxy) plus
/// the existing theme interception share a single [BasicMessageChannel].
/// This router multiplexes incoming messages by examining reserved prefix
/// keys in the map and forwarding to the appropriate handler.
///
/// Messages without a registered prefix key are forwarded to [rawMessages],
/// which backs the existing `FloatyChatheads.onData` / `FloatyOverlay.onData`
/// streams.
///
/// This class is **internal** and not exported from the public barrel file.
final class FloatyChannel {
  FloatyChannel._(); // coverage:ignore-line

  /// The shared platform channel for main ↔ overlay communication.
  static const BasicMessageChannel<Object?> _messenger =
      BasicMessageChannel<Object?>(
        'ni.devotion.floaty_head/messenger',
        JSONMessageCodec(),
      );

  /// Prefix-keyed handlers. Each handler receives the inner value of the
  /// matched prefix key as a `Map<String, dynamic>`.
  static final Map<String, void Function(Map<String, dynamic>)> _handlers = {};

  /// Stream controller for messages that don't match any registered prefix.
  static final StreamController<Object?> _rawController =
      StreamController<Object?>.broadcast();

  static bool _isListening = false;

  // ---------------------------------------------------------------------------
  // Public API (package-internal)
  // ---------------------------------------------------------------------------

  /// Stream of raw (non-prefixed) messages — replaces the old
  /// `_dataController` in both `FloatyChatheads` and `FloatyOverlay`.
  static Stream<Object?> get rawMessages {
    ensureListening();
    return _rawController.stream;
  }

  /// Registers a prefix-based handler.
  ///
  /// When an incoming message is a [Map] containing [prefix] as a key,
  /// the value (cast to `Map<String, dynamic>`) is forwarded to [handler]
  /// instead of the raw stream.
  static void registerHandler(
    String prefix,
    void Function(Map<String, dynamic> data) handler,
  ) {
    _handlers[prefix] = handler;
  }

  /// Removes a previously registered handler.
  static void unregisterHandler(String prefix) {
    _handlers.remove(prefix);
  }

  /// Ensures the shared message handler is attached.
  ///
  /// Safe to call multiple times — only attaches once.
  static void ensureListening() {
    if (!_isListening) {
      _messenger.setMessageHandler(_onMessage);
      _isListening = true;
    }
  }

  /// Sends data through the shared channel.
  static Future<void> send(Object? data) => _messenger.send(data);

  /// Detaches the message handler and clears all prefix handlers.
  ///
  /// After calling, [ensureListening] will re-attach on next access.
  static void dispose() {
    _messenger.setMessageHandler(null);
    _isListening = false;
    _handlers.clear();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  static Future<Object?> _onMessage(Object? message) async {
    if (message is Map) {
      // Check each registered prefix.
      for (final entry in _handlers.entries) {
        if (message.containsKey(entry.key)) {
          final raw = message[entry.key];
          if (raw is Map) {
            entry.value(raw.cast<String, dynamic>());
            return message;
          }
        }
      }
    }

    // No prefix matched — forward to the raw stream.
    _rawController.add(message);
    return message;
  }
}
