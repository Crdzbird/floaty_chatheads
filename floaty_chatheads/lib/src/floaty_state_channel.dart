import 'dart:async';

import 'package:floaty_chatheads/src/floaty_channel.dart';

/// {@template floaty_state_channel}
/// A typed, auto-syncing state channel between the main app and overlay.
///
/// Instead of sending raw `Map<String, dynamic>` payloads, define a state
/// class with `toJson`/`fromJson` and let the channel keep both sides in sync.
///
/// **Main app side:**
///
/// ```dart
/// final channel = FloatyStateChannel<MyState>(
///   toJson: (s) => s.toJson(),
///   fromJson: MyState.fromJson,
///   initialState: MyState(),
/// );
///
/// // Full replace + sync.
/// await channel.setState(MyState(count: 1));
///
/// // Partial update (shallow merge).
/// await channel.updateState({'count': 2});
///
/// // Listen for changes from the overlay.
/// channel.onStateChanged.listen((state) => print(state));
/// ```
///
/// **Overlay side:**
///
/// ```dart
/// final channel = FloatyStateChannel<MyState>.overlay(
///   toJson: (s) => s.toJson(),
///   fromJson: MyState.fromJson,
///   initialState: MyState(),
/// );
/// ```
///
/// The state is serialized as JSON and transmitted through the shared data
/// channel. Both sides must use the same state type and serialization.
///
/// **Note:** [updateState] performs a **shallow** merge of top-level keys.
/// Nested objects are replaced, not recursively merged.
/// {@endtemplate}
final class FloatyStateChannel<S> {
  /// {@template floaty_state_channel.main}
  /// Creates a state channel for the **main app** side.
  /// {@endtemplate}
  FloatyStateChannel({
    required Map<String, dynamic> Function(S state) toJson,
    required S Function(Map<String, dynamic> json) fromJson,
    required S initialState,
  })  : _toJson = toJson,
        _fromJson = fromJson,
        _state = initialState {
    _init();
  }

  /// {@template floaty_state_channel.overlay}
  /// Creates a state channel for the **overlay** side.
  /// {@endtemplate}
  FloatyStateChannel.overlay({
    required Map<String, dynamic> Function(S state) toJson,
    required S Function(Map<String, dynamic> json) fromJson,
    required S initialState,
  })  : _toJson = toJson,
        _fromJson = fromJson,
        _state = initialState {
    _init();
  }

  static const _prefix = '_floaty_state';

  final Map<String, dynamic> Function(S state) _toJson;
  final S Function(Map<String, dynamic> json) _fromJson;
  final StreamController<S> _controller = StreamController<S>.broadcast();

  S _state;

  void _init() {
    FloatyChannel.registerHandler(_prefix, _onMessage);
    FloatyChannel.ensureListening();
  }

  /// The current state (synchronous read).
  S get state => _state;

  /// Stream of state changes from the other side.
  Stream<S> get onStateChanged => _controller.stream;

  /// Replaces the entire state and syncs to the other side.
  Future<void> setState(S newState) {
    _state = newState;
    return FloatyChannel.send({
      _prefix: {
        'full': true,
        'data': _toJson(newState),
      },
    });
  }

  /// Performs a shallow merge of [partial] into the current state's JSON
  /// representation, rebuilds the state, and syncs to the other side.
  ///
  /// Only top-level keys are merged; nested objects are replaced entirely.
  Future<void> updateState(Map<String, dynamic> partial) {
    final current = _toJson(_state)..addAll(partial);
    _state = _fromJson(current);
    return FloatyChannel.send({
      _prefix: {
        'full': false,
        'data': partial,
      },
    });
  }

  void _onMessage(Map<String, dynamic> envelope) {
    final isFull = envelope['full'] as bool? ?? true;
    final data = envelope['data'];
    if (data is! Map) return;
    final typed = data.cast<String, dynamic>();

    if (isFull) {
      _state = _fromJson(typed);
    } else {
      // Shallow merge.
      final current = _toJson(_state)..addAll(typed);
      _state = _fromJson(current);
    }
    _controller.add(_state);
  }

  /// Releases resources.
  void dispose() {
    FloatyChannel.unregisterHandler(_prefix);
    unawaited(_controller.close());
  }
}
