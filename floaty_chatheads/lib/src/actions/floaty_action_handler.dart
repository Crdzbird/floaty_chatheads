import 'dart:async';

import 'package:floaty_chatheads/src/actions/floaty_action.dart';

/// A registered action handler entry.
///
/// [handle] deserializes and dispatches inside the generic context where
/// [A] is known, so entries can be stored in a map of mixed action types.
final class FloatyActionHandler<A extends FloatyAction> {
  /// Creates an entry that decodes with [fromJson] and runs [handler].
  factory FloatyActionHandler({
    required A Function(Map<String, dynamic> json) fromJson,
    required FutureOr<void> Function(A action) handler,
  }) = FloatyActionHandler<A>._;

  FloatyActionHandler._({required this.fromJson, required this.handler});

  /// Decodes the payload into an [A].
  final A Function(Map<String, dynamic> json) fromJson;

  /// Runs for each decoded action.
  final FutureOr<void> Function(A action) handler;

  /// Deserializes [payload] and calls [handler] in a type-safe context.
  FutureOr<void> handle(Map<String, dynamic> payload) =>
      handler(fromJson(payload));
}
