import 'package:flutter/material.dart';

import '../../models/todo_actions.dart';
import 'todo_survival_overlay_task_row.dart';

/// Task list of the todo survival overlay, or a hint while it is empty.
final class TodoSurvivalOverlayTaskList extends StatelessWidget {
  /// Creates the list for [items].
  const factory TodoSurvivalOverlayTaskList({
    required List<TodoItem> items,
    required void Function(TodoItem item) onToggle,
    required void Function(TodoItem item) onRemove,
    Key? key,
  }) = TodoSurvivalOverlayTaskList._;

  const TodoSurvivalOverlayTaskList._({
    required this.items,
    required this.onToggle,
    required this.onRemove,
    super.key,
  });

  /// Tasks to show.
  final List<TodoItem> items;

  /// Called with the task whose done state should flip.
  final void Function(TodoItem item) onToggle;

  /// Called with the task to remove.
  final void Function(TodoItem item) onRemove;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No tasks yet.\nTap + to add one!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 160),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return TodoSurvivalOverlayTaskRow(
            item: item,
            onToggle: () => onToggle(item),
            onRemove: () => onRemove(item),
          );
        },
      ),
    );
  }
}
