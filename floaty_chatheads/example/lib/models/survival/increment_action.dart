import 'package:floaty_chatheads/floaty_chatheads.dart';

/// Increments a shared counter.
final class IncrementAction extends FloatyAction {
  /// Creates an action that adds [amount] to the counter.
  const factory IncrementAction({required int amount}) = IncrementAction._;

  const IncrementAction._({required this.amount});

  /// Decodes an action from its JSON payload.
  factory IncrementAction.fromJson(Map<String, dynamic> json) =>
      IncrementAction(amount: json['amount'] as int);

  /// Routing key for this action type.
  static const key =
      ActionKey<IncrementAction>('increment', IncrementAction.fromJson);

  /// How much to add to the counter.
  final int amount;

  @override
  String get type => key.type;

  @override
  Map<String, dynamic> toJson() => {'amount': amount};

  @override
  String toString() => 'Increment(+$amount)';
}
