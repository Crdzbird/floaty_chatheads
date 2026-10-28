import 'package:floaty_chatheads/floaty_chatheads.dart';

/// Adds a new task to the list.
final class AddTodoAction extends FloatyAction {
  /// Creates an action that adds the task [id] titled [title].
  const factory AddTodoAction({required String id, required String title}) =
      AddTodoAction._;

  const AddTodoAction._({required this.id, required this.title});

  /// Decodes the action from its JSON payload.
  factory AddTodoAction.fromJson(Map<String, dynamic> json) =>
      AddTodoAction(id: json['id'] as String, title: json['title'] as String);

  /// Routing key for this action.
  static const key = ActionKey<AddTodoAction>(
    'add_todo',
    AddTodoAction.fromJson,
  );

  /// Id of the new task.
  final String id;

  /// Title of the new task.
  final String title;

  @override
  String get type => key.type;

  @override
  Map<String, dynamic> toJson() => {'id': id, 'title': title};

  @override
  String toString() => 'AddTodo("$title")';
}
