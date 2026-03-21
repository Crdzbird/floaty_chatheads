import 'package:floaty_chatheads/floaty_chatheads.dart';

// ---------------------------------------------------------------------------
// Typed actions for the todo survival example (used by FloatyActionRouter)
// ---------------------------------------------------------------------------

/// Adds a new task to the list.
class AddTodoAction extends FloatyAction {
  AddTodoAction({required this.id, required this.title});

  factory AddTodoAction.fromJson(Map<String, dynamic> json) => AddTodoAction(
        id: json['id'] as String,
        title: json['title'] as String,
      );

  final String id;
  final String title;

  @override
  String get type => 'add_todo';

  @override
  Map<String, dynamic> toJson() => {'id': id, 'title': title};

  @override
  String toString() => 'AddTodo("$title")';
}

/// Toggles the done state of an existing task.
class ToggleTodoAction extends FloatyAction {
  ToggleTodoAction({required this.id});

  factory ToggleTodoAction.fromJson(Map<String, dynamic> json) =>
      ToggleTodoAction(id: json['id'] as String);

  final String id;

  @override
  String get type => 'toggle_todo';

  @override
  Map<String, dynamic> toJson() => {'id': id};

  @override
  String toString() => 'ToggleTodo($id)';
}

/// Removes a task from the list.
class RemoveTodoAction extends FloatyAction {
  RemoveTodoAction({required this.id});

  factory RemoveTodoAction.fromJson(Map<String, dynamic> json) =>
      RemoveTodoAction(id: json['id'] as String);

  final String id;

  @override
  String get type => 'remove_todo';

  @override
  Map<String, dynamic> toJson() => {'id': id};

  @override
  String toString() => 'RemoveTodo($id)';
}

// ---------------------------------------------------------------------------
// Shared state for the todo survival example (used by FloatyStateChannel)
// ---------------------------------------------------------------------------

/// A single todo item.
class TodoItem {
  TodoItem({required this.id, required this.title, this.done = false});

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'] as String,
        title: json['title'] as String,
        done: json['done'] as bool? ?? false,
      );

  final String id;
  final String title;
  final bool done;

  TodoItem copyWith({bool? done}) =>
      TodoItem(id: id, title: title, done: done ?? this.done);

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'done': done};
}

/// Full state synced between main app and overlay.
class TodoState {
  TodoState({this.items = const [], this.label = 'Ready'});

  factory TodoState.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return TodoState(
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(TodoItem.fromJson)
          .toList(),
      label: json['label'] as String? ?? 'Ready',
    );
  }

  final List<TodoItem> items;
  final String label;

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'label': label,
      };
}
