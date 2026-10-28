import 'dart:async';

import 'package:floaty_chatheads/src/actions/floaty_action.dart';
import 'package:floaty_chatheads/src/actions/queue_overflow_strategy.dart';
import 'package:floaty_chatheads/src/floaty_connection_state.dart';

/// Bounded queue of actions dispatched while the main app is disconnected,
/// flushed through a send callback when the connection comes back.
final class FloatyActionQueue {
  /// Creates a queue holding at most [maxSize] actions.
  factory FloatyActionQueue({
    required int maxSize,
    required QueueOverflowStrategy strategy,
  }) = FloatyActionQueue._;

  FloatyActionQueue._({required this.maxSize, required this.strategy});

  /// Maximum number of queued actions.
  final int maxSize;

  /// What to drop when the queue is full.
  final QueueOverflowStrategy strategy;

  final List<FloatyAction> _items = [];
  StreamSubscription<bool>? _connectionSub;

  /// The number of queued actions.
  int get length => _items.length;

  /// Queues [action], applying [strategy] when the queue is full.
  void add(FloatyAction action) {
    if (_items.length >= maxSize) {
      switch (strategy) {
        case QueueOverflowStrategy.dropOldest:
          _items.removeAt(0);
        case QueueOverflowStrategy.dropNewest:
          return;
      }
    }
    _items.add(action);
  }

  /// Sends every queued action through [send] each time the main app
  /// reconnects.
  void flushOnReconnect(Future<void> Function(FloatyAction action) send) {
    _connectionSub = FloatyConnectionState.onConnectionChanged.listen((
      connected,
    ) async {
      if (connected) await _flush(send);
    });
  }

  Future<void> _flush(Future<void> Function(FloatyAction action) send) async {
    final queued = List<FloatyAction>.of(_items);
    _items.clear();
    for (final action in queued) {
      await send(action);
    }
  }

  /// Stops listening for reconnection and drops every queued action.
  Future<void> dispose() async {
    await _connectionSub?.cancel();
    _connectionSub = null;
    _items.clear();
  }
}
