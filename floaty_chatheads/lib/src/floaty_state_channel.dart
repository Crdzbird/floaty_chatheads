import 'dart:async';

import 'package:floaty_chatheads/src/floaty_channel.dart';

/// A typed, auto-syncing state channel between the main app and overlay.
///
/// Define a state class with `toJson`/`fromJson` and let the channel keep
/// both sides in sync:
///
/// ```dart
/// final channel = FloatyStateChannel<MyState>(
///   toJson: (s) => s.toJson(),
///   fromJson: MyState.fromJson,
///   initialState: MyState(),
/// );
/// await channel.setState(MyState(count: 1));
/// await channel.updateState({'count': 2});
/// channel.onStateChanged.listen(print);
/// ```
///
/// Use [FloatyStateChannel.overlay] on the overlay side. Both sides must
/// use the same state type and serialization. [updateState] performs a
/// shallow merge of top-level keys; nested objects are replaced.
final class FloatyStateChannel<S> {
  /// Creates a state channel for the main app side.
  factory FloatyStateChannel({
    required Map<String, dynamic> Function(S state) toJson,
    required S Function(Map<String, dynamic> json) fromJson,
    required S initialState,
  }) = FloatyStateChannel<S>._;

  /// Creates a state channel for the overlay side.
  ///
  /// Functionally identical to the unnamed constructor; the named variant
  /// exists for symmetry with `FloatyActionRouter.overlay()`.
  factory FloatyStateChannel.overlay({
    required Map<String, dynamic> Function(S state) toJson,
    required S Function(Map<String, dynamic> json) fromJson,
    required S initialState,
  }) = FloatyStateChannel<S>._;

  FloatyStateChannel._({
    required this._toJson,
    required this._fromJson,
    required S initialState,
  }) : _state = initialState {
    FloatyChannel.registerHandler(_prefix, _onMessage);
    FloatyChannel.ensureListening();
  }

  static const _prefix = '_floaty_state';

  final Map<String, dynamic> Function(S state) _toJson;
  final S Function(Map<String, dynamic> json) _fromJson;
  final StreamController<S> _controller = StreamController<S>.broadcast();

  S _state;

  /// The current state (synchronous read).
  S get state => _state;

  /// Stream of state changes from the other side.
  Stream<S> get onStateChanged => _controller.stream;

  /// Replaces the entire state and syncs to the other side.
  Future<void> setState(S newState) {
    _state = newState;
    return FloatyChannel.sendSystem(_prefix, {
      'full': true,
      'data': _toJson(newState),
    });
  }

  /// Shallow-merges [partial] into the current state's JSON, rebuilds the
  /// state, and syncs to the other side.
  Future<void> updateState(Map<String, dynamic> partial) {
    _state = _merged(partial);
    return FloatyChannel.sendSystem(_prefix, {'full': false, 'data': partial});
  }

  S _merged(Map<String, dynamic> partial) =>
      _fromJson(_toJson(_state)..addAll(partial));

  void _onMessage(Map<String, dynamic> envelope) {
    final isFull = envelope['full'] as bool? ?? true;
    final data = envelope['data'];
    if (data is! Map) return;
    final typed = data.cast<String, dynamic>();
    _state = isFull ? _fromJson(typed) : _merged(typed);
    _controller.add(_state);
  }

  /// Releases resources.
  Future<void> dispose() async {
    FloatyChannel.unregisterHandler(_prefix);
    await _controller.close();
  }
}
