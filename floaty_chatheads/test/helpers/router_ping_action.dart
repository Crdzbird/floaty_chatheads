import 'package:floaty_chatheads/floaty_chatheads.dart';

/// Action carrying a ping [value].
final class RouterPingAction extends FloatyAction {
  /// Creates a ping action with [value].
  factory RouterPingAction({required String value}) = RouterPingAction._;

  /// Restores an action from its JSON payload.
  factory RouterPingAction.fromJson(Map<String, dynamic> json) =>
      RouterPingAction(value: json['value'] as String);

  RouterPingAction._({required this.value});

  /// Routing key for this action.
  static const key = ActionKey<RouterPingAction>(
    'ping',
    RouterPingAction.fromJson,
  );

  /// The ping value.
  final String value;

  @override
  String get type => key.type;

  @override
  Map<String, dynamic> toJson() => {'value': value};
}
