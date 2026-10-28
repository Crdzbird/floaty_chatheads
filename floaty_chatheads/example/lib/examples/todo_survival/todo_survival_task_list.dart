import 'package:flutter/material.dart';

import '../../models/todo_actions.dart';

/// Fixed-height scrollable list of tasks with their done state.
final class TodoSurvivalTaskList extends StatelessWidget {
  /// Creates the task list for [items].
  const factory TodoSurvivalTaskList({
    required List<TodoItem> items,
    Key? key,
  }) = TodoSurvivalTaskList._;

  const TodoSurvivalTaskList._({required this.items, super.key});

  /// Tasks to show.
  final List<TodoItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return Row(
            children: [
              Icon(
                item.done ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 16,
                color: item.done ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13,
                    decoration: item.done ? TextDecoration.lineThrough : null,
                    color: item.done ? Colors.grey : null,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
