import 'dart:async';

import 'package:floaty_chatheads/src/actions/action_key.dart';
import 'package:floaty_chatheads/src/actions/floaty_action.dart';
import 'package:floaty_chatheads/src/actions/floaty_action_handlers.dart';
import 'package:floaty_chatheads/src/actions/floaty_action_queue.dart';
import 'package:floaty_chatheads/src/actions/queue_overflow_strategy.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:floaty_chatheads/src/floaty_connection_state.dart';

export 'package:floaty_chatheads/src/actions/action_key.dart';
export 'package:floaty_chatheads/src/actions/floaty_action.dart';
export 'package:floaty_chatheads/src/actions/queue_overflow_strategy.dart';

/// Typed action dispatch between the main app and the overlay: register
/// handlers with [on] and an [ActionKey], send actions with [dispatch].
/// On the overlay side, actions are queued while the main app is away.
final class FloatyActionRouter {
  /// Creates an action router for the main app side.
  factory FloatyActionRouter({
    int maxQueueSize,
    QueueOverflowStrategy overflowStrategy,
  }) = FloatyActionRouter._main;

  /// Creates an action router for the overlay side, queueing up to
  /// [maxQueueSize] actions while the main app is disconnected.
  factory FloatyActionRouter.overlay({
    int maxQueueSize,
    QueueOverflowStrategy overflowStrategy,
  }) = FloatyActionRouter._overlay;

  FloatyActionRouter._main({
    this.maxQueueSize = 100,
    this.overflowStrategy = QueueOverflowStrategy.dropOldest,
  }) : _isOverlay = false {
    _init();
  }

  FloatyActionRouter._overlay({
    this.maxQueueSize = 100,
    this.overflowStrategy = QueueOverflowStrategy.dropOldest,
  }) : _isOverlay = true {
    _init();
  }

  static const _prefix = '_floaty_action';

  /// Maximum number of actions to queue while disconnected.
  final int maxQueueSize;

  /// Strategy for handling queue overflow.
  final QueueOverflowStrategy overflowStrategy;

  final bool _isOverlay;
  final FloatyActionHandlers _handlers = FloatyActionHandlers();
  late final FloatyActionQueue _queue = FloatyActionQueue(
    maxSize: maxQueueSize,
    strategy: overflowStrategy,
  );

  void _init() {
    FloatyChannel.registerHandler(_prefix, _handlers.handle);
    FloatyChannel.ensureListening();
    if (_isOverlay) _queue.flushOnReconnect(dispatch);
  }

  /// Registers [handler] for actions whose `type` matches `key.type`.
  void on<A extends FloatyAction>(
    ActionKey<A> key,
    FutureOr<void> Function(A action) handler,
  ) => _handlers.add<A>(key, handler);

  /// Removes the handler associated with [key].
  void off<A extends FloatyAction>(ActionKey<A> key) =>
      _handlers.remove(key.type);

  /// Dispatches an action to the other side, queueing it on the overlay
  /// side while the main app is disconnected.
  Future<void> dispatch(FloatyAction action) {
    if (_isOverlay && !FloatyConnectionState.isMainAppConnected) {
      _queue.add(action);
      return Future<void>.value();
    }
    return FloatyChannel.sendSystem(_prefix, {
      'type': action.type,
      'payload': action.toJson(),
    });
  }

  /// The number of actions currently queued (waiting for reconnection).
  int get queueLength => _queue.length;

  /// Releases resources and unregisters the channel handler.
  Future<void> dispose() async {
    FloatyChannel.unregisterHandler(_prefix);
    await _queue.dispose();
    _handlers.clear();
  }
}
