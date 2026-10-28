import 'package:flutter/material.dart';

import '../../models/todo_actions.dart';
import 'todo_survival_stat_chip.dart';

/// Row of total, pending and done counters for the todo list.
final class TodoSurvivalStatsBar extends StatelessWidget {
  /// Creates the stats row for [items].
  const factory TodoSurvivalStatsBar({
    required List<TodoItem> items,
    Key? key,
  }) = TodoSurvivalStatsBar._;

  const TodoSurvivalStatsBar._({required this.items, super.key});

  /// Tasks to count.
  final List<TodoItem> items;

  @override
  Widget build(BuildContext context) {
    final done = items.where((t) => t.done).length;
    final pending = items.length - done;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          TodoSurvivalStatChip(
            label: 'Total',
            value: '${items.length}',
            color: Colors.teal,
          ),
          const SizedBox(width: 8),
          TodoSurvivalStatChip(
            label: 'Pending',
            value: '$pending',
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          TodoSurvivalStatChip(
            label: 'Done',
            value: '$done',
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
