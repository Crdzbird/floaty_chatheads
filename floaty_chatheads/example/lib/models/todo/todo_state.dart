import 'todo_item.dart';

/// Full state synced between main app and overlay.
final class TodoState {
  /// Creates a state with [items] and a status [label].
  const factory TodoState({List<TodoItem> items, String label}) = TodoState._;

  const TodoState._({this.items = const [], this.label = 'Ready'});

  /// Decodes the state from JSON, ignoring malformed items.
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

  /// The task list.
  final List<TodoItem> items;

  /// Short status label describing the last change.
  final String label;

  /// Encodes the state as JSON.
  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'label': label,
      };
}
