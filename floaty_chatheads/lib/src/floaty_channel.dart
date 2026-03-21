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
/// System messages that arrive before their handler is registered are
/// buffered (up to [_maxPendingPerPrefix]) and replayed when the handler
/// is attached. This prevents message loss during reconnection when the
/// overlay flushes queued actions before the main app has navigated back
/// to the page that registers handlers.
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

  /// Buffered system messages awaiting handler registration.
  static final Map<String, List<Map<String, dynamic>>> _pending = {};

  /// Prefixes that have been registered at least once. Messages are only
  /// buffered for prefixes that have never had a handler — once a handler
  /// is registered and later removed, we assume it was intentional and
  /// stop buffering for that prefix.
  static final Set<String> _everRegistered = {};

  /// Maximum buffered messages per prefix to avoid unbounded growth.
  static const _maxPendingPerPrefix = 200;

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
  ///
  /// Any system messages that arrived before this handler was registered
  /// are replayed immediately (in order).
  static void registerHandler(
    String prefix,
    void Function(Map<String, dynamic> data) handler,
  ) {
    _handlers[prefix] = handler;
    _everRegistered.add(prefix);

    // Replay buffered messages that arrived before this handler existed.
    final buffered = _pending.remove(prefix);
    if (buffered != null && buffered.isNotEmpty) {
      buffered.forEach(handler);
    }
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

  /// Sends raw user data through the shared channel.
  static Future<void> send(Object? data) => _messenger.send(data);

  /// Sends a system-prefixed message (for internal use only).
  ///
  /// Wraps [payload] in a dedicated envelope so that user data can never
  /// collide with system routing keys.
  static Future<void> sendSystem(
    String prefix,
    Map<String, dynamic> payload,
  ) =>
      _messenger.send(<String, Object?>{
        _systemEnvelope: prefix,
        prefix: payload,
      });

  /// Detaches the message handler and clears all prefix handlers.
  ///
  /// After calling, [ensureListening] will re-attach on next access.
  static void dispose() {
    _messenger.setMessageHandler(null);
    _isListening = false;
    _handlers.clear();
    _pending.clear();
    _everRegistered.clear();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  /// Dedicated envelope key used by [sendSystem] to distinguish system
  /// messages from arbitrary user data.  User payloads are forwarded to
  /// [rawMessages]; only messages containing this key are routed to
  /// prefix handlers.
  static const _systemEnvelope = '__floaty__';

  static Future<Object?> _onMessage(Object? message) async {
    if (message is Map && message.containsKey(_systemEnvelope)) {
      final prefix = message[_systemEnvelope] as String?;
      final raw = prefix != null ? message[prefix] : null;

      if (prefix != null && raw is Map) {
        final data = raw.cast<String, dynamic>();
        final handler = _handlers[prefix];

        if (handler != null) {
          handler(data);
          return message;
        }

        // No handler. If this prefix has NEVER been registered, buffer
        // the message so it can be replayed when the handler arrives
        // (e.g. queue-flush actions arriving before the widget tree
        // registers its handlers).  If the prefix WAS registered and
        // then removed, fall through to the raw stream — the caller
        // intentionally removed the handler.
        if (!_everRegistered.contains(prefix)) {
          final queue = _pending.putIfAbsent(prefix, () => []);
          if (queue.length < _maxPendingPerPrefix) {
            queue.add(data);
          }
          return message;
        }
      }

      // Malformed system message (non-map value, null prefix, or
      // previously-registered prefix with no current handler) — fall
      // through to the raw stream.
    }

    // No system envelope — forward to the raw stream.
    _rawController.add(message);
    return message;
  }
}
