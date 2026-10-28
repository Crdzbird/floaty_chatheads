import 'package:floaty_chatheads/floaty_chatheads.dart';

/// Toggles the done state of an existing task.
final class ToggleTodoAction extends FloatyAction {
  /// Creates an action that toggles the task [id].
  const factory ToggleTodoAction({required String id}) = ToggleTodoAction._;

  const ToggleTodoAction._({required this.id});

  /// Decodes the action from its JSON payload.
  factory ToggleTodoAction.fromJson(Map<String, dynamic> json) =>
      ToggleTodoAction(id: json['id'] as String);

  /// Routing key for this action.
  static const key =
      ActionKey<ToggleTodoAction>('toggle_todo', ToggleTodoAction.fromJson);

  /// Id of the task to toggle.
  final String id;

  @override
  String get type => key.type;

  @override
  Map<String, dynamic> toJson() => {'id': id};

  @override
  String toString() => 'ToggleTodo($id)';
}
