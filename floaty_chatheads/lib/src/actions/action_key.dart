import 'package:floaty_chatheads/src/actions/floaty_action.dart';
import 'package:flutter/foundation.dart' show immutable;

/// Compile-time link between an action [type] string and its payload
/// class [A].
///
/// Define the key as a `static const` on the action class so the routing
/// string lives with the type that owns it, and `router.on` calls cannot
/// pair the wrong `fromJson` with the wrong handler:
///
/// ```dart
/// static const key = ActionKey<PinAction>('pin', PinAction.fromJson);
///
/// router.on(PinAction.key, (a) => setPin(a.lat, a.lng));
/// ```
@immutable
final class ActionKey<A extends FloatyAction> {
  /// Creates a key for actions of [type], decoded with [fromJson].
  const factory ActionKey(
    String type,
    A Function(Map<String, dynamic> json) fromJson,
  ) = ActionKey<A>._;

  const ActionKey._(this.type, this.fromJson);

  /// Unique type string carried in the wire envelope.
  final String type;

  /// Deserializes the JSON payload back into an [A].
  final A Function(Map<String, dynamic> json) fromJson;
}
