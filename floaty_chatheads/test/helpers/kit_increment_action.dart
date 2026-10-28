import 'package:floaty_chatheads/floaty_chatheads.dart';

/// Action that increments a counter by [amount].
final class KitIncrementAction extends FloatyAction {
  /// Creates an action that increments by [amount].
  factory KitIncrementAction({required int amount}) = KitIncrementAction._;

  /// Restores an action from its JSON payload.
  factory KitIncrementAction.fromJson(Map<String, dynamic> json) =>
      KitIncrementAction(amount: json['amount'] as int);

  KitIncrementAction._({required this.amount});

  /// Routing key for this action.
  static const key = ActionKey<KitIncrementAction>(
    'increment',
    KitIncrementAction.fromJson,
  );

  /// The increment amount.
  final int amount;

  @override
  String get type => key.type;

  @override
  Map<String, dynamic> toJson() => {'amount': amount};
}
