import 'package:floaty_chatheads/floaty_chatheads.dart';

/// Action carrying a navigation [route].
final class RouterNavigateAction extends FloatyAction {
  /// Creates a navigate action for [route].
  factory RouterNavigateAction({required String route}) =
      RouterNavigateAction._;

  /// Restores an action from its JSON payload.
  factory RouterNavigateAction.fromJson(Map<String, dynamic> json) =>
      RouterNavigateAction(route: json['route'] as String);

  RouterNavigateAction._({required this.route});

  /// Routing key for this action.
  static const key = ActionKey<RouterNavigateAction>(
    'navigate',
    RouterNavigateAction.fromJson,
  );

  /// The target route.
  final String route;

  @override
  String get type => key.type;

  @override
  Map<String, dynamic> toJson() => {'route': route};
}
