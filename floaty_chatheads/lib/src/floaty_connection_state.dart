import 'dart:async';

import 'package:floaty_chatheads/src/floaty_channel.dart';

/// {@template floaty_connection_state}
/// Tracks whether the main app is currently connected to the overlay.
///
/// When the main app is killed or backgrounded, the native service sends
/// a `_floaty_connection` message with `{"connected": false}`. When the
/// app restarts and reconnects, it sends `{"connected": true}`.
///
/// **Overlay side usage:**
///
/// ```dart
/// FloatyConnectionState.setUp();
///
/// // Synchronous check.
/// if (FloatyConnectionState.isMainAppConnected) { ... }
///
/// // Reactive stream.
/// FloatyConnectionState.onConnectionChanged.listen((connected) {
///   if (!connected) showDisconnectedBanner();
/// });
/// ```
///
/// This is an overlay-only utility. On the main app side, the app is
/// always "connected" to itself.
/// {@endtemplate}
final class FloatyConnectionState {
  FloatyConnectionState._(); // coverage:ignore-line

  static const _prefix = '_floaty_connection';

  static final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  static bool _connected = true;
  static bool _isSetUp = false;

  /// Whether the main app is currently connected.
  ///
  /// Defaults to `true` because the overlay is always created while
  /// the main app is alive.
  static bool get isMainAppConnected => _connected;

  /// Stream that emits whenever the connection state changes.
  static Stream<bool> get onConnectionChanged => _controller.stream;

  /// Initializes the connection state listener.
  ///
  /// Safe to call multiple times — only registers once.
  static void setUp() {
    if (_isSetUp) return;
    FloatyChannel.registerHandler(_prefix, _onMessage);
    FloatyChannel.ensureListening();
    _isSetUp = true;
  }

  static void _onMessage(Map<String, dynamic> data) {
    final connected = data['connected'] as bool? ?? true;
    if (connected != _connected) {
      _connected = connected;
      _controller.add(connected);
    }
  }

  /// Resets the connection state (for testing).
  static void dispose() {
    FloatyChannel.unregisterHandler(_prefix);
    _connected = true;
    _isSetUp = false;
  }
}
