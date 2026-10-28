import 'dart:async';

import 'package:floaty_chatheads/src/actions/action_key.dart';
import 'package:floaty_chatheads/src/actions/floaty_action.dart';
import 'package:floaty_chatheads/src/actions/floaty_action_handler.dart';

/// Action handlers keyed by action type.
final class FloatyActionHandlers {
  /// Creates an empty handler table.
  factory FloatyActionHandlers() = FloatyActionHandlers._;

  FloatyActionHandlers._();

  final Map<String, FloatyActionHandler<dynamic>> _handlers = {};

  /// Registers [handler] for actions whose type matches `key.type`.
  void add<A extends FloatyAction>(
    ActionKey<A> key,
    FutureOr<void> Function(A action) handler,
  ) {
    _handlers[key.type] = FloatyActionHandler<A>(
      fromJson: key.fromJson,
      handler: handler,
    );
  }

  /// Removes the handler registered under [type].
  void remove(String type) => _handlers.remove(type);

  /// Decodes [envelope] and runs the matching handler.
  ///
  /// Unknown types, malformed payloads and handler errors are ignored so
  /// they never break the message loop.
  Future<void> handle(Map<String, dynamic> envelope) async {
    final entry = _handlers[envelope['type'] as String?];
    final payload = envelope['payload'];
    if (entry == null || payload is! Map) return;
    try {
      await entry.handle(payload.cast<String, dynamic>());
    } on Object {
      return;
    }
  }

  /// Removes every handler.
  void clear() => _handlers.clear();
}
