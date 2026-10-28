/// A single todo item.
final class TodoItem {
  /// Creates a task [id] titled [title], open unless [done].
  const factory TodoItem({
    required String id,
    required String title,
    bool done,
  }) = TodoItem._;

  const TodoItem._({required this.id, required this.title, this.done = false});

  /// Decodes a task from JSON; a missing `done` means open.
  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'] as String,
        title: json['title'] as String,
        done: json['done'] as bool? ?? false,
      );

  /// Unique id of the task.
  final String id;

  /// Title shown in the list.
  final String title;

  /// Whether the task is completed.
  final bool done;

  /// Returns a copy with [done] replaced when given.
  TodoItem copyWith({bool? done}) =>
      TodoItem(id: id, title: title, done: done ?? this.done);

  /// Encodes the task as JSON.
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'done': done};
}
