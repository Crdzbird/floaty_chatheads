import 'package:floaty_chatheads/floaty_chatheads.dart';

/// Removes a task from the list.
final class RemoveTodoAction extends FloatyAction {
  /// Creates an action that removes the task [id].
  const factory RemoveTodoAction({required String id}) = RemoveTodoAction._;

  const RemoveTodoAction._({required this.id});

  /// Decodes the action from its JSON payload.
  factory RemoveTodoAction.fromJson(Map<String, dynamic> json) =>
      RemoveTodoAction(id: json['id'] as String);

  /// Routing key for this action.
  static const key =
      ActionKey<RemoveTodoAction>('remove_todo', RemoveTodoAction.fromJson);

  /// Id of the task to remove.
  final String id;

  @override
  String get type => key.type;

  @override
  Map<String, dynamic> toJson() => {'id': id};

  @override
  String toString() => 'RemoveTodo($id)';
}
