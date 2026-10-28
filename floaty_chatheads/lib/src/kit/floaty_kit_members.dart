import 'dart:async';

import 'package:floaty_chatheads/src/floaty_action_router.dart';
import 'package:floaty_chatheads/src/floaty_state_channel.dart';

/// Action and state delegates shared by `FloatyHostKit` and
/// `FloatyOverlayKit`.
mixin FloatyKitMembers<S> {
  /// The underlying action router.
  FloatyActionRouter get router;

  /// The underlying state channel.
  FloatyStateChannel<S> get stateChannel;

  /// Registers a handler for the action identified by [key].
  void onAction<A extends FloatyAction>(
    ActionKey<A> key,
    FutureOr<void> Function(A action) handler,
  ) => router.on<A>(key, handler);

  /// Removes the handler registered for [key].
  void offAction<A extends FloatyAction>(ActionKey<A> key) =>
      router.off<A>(key);

  /// Dispatches an action to the other side. On the overlay side the
  /// action is queued while the main app is disconnected.
  Future<void> dispatch(FloatyAction action) => router.dispatch(action);

  /// The number of actions currently queued (always 0 on the host side).
  int get queueLength => router.queueLength;

  /// The current state (synchronous read).
  S get state => stateChannel.state;

  /// Stream of state changes from the other side.
  Stream<S> get onStateChanged => stateChannel.onStateChanged;

  /// Replaces the entire state and syncs to the other side.
  Future<void> setState(S newState) => stateChannel.setState(newState);

  /// Shallow-merges [partial] into the current state and syncs.
  Future<void> updateState(Map<String, dynamic> partial) =>
      stateChannel.updateState(partial);
}
