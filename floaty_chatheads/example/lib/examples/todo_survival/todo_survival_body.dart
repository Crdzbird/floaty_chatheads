import 'package:flutter/material.dart';

import '../../models/todo_actions.dart';
import 'todo_survival_instructions.dart';
import 'todo_survival_log_header.dart';
import 'todo_survival_log_list.dart';
import 'todo_survival_stats_bar.dart';
import 'todo_survival_task_list.dart';

/// Body of the todo survival example: instructions, stats, task list and
/// the action log.
final class TodoSurvivalBody extends StatelessWidget {
  /// Creates the body for [items] and [log] entries.
  const factory TodoSurvivalBody({
    required List<TodoItem> items,
    required List<String> log,
    required VoidCallback onClearLog,
    Key? key,
  }) = TodoSurvivalBody._;

  const TodoSurvivalBody._({
    required this.items,
    required this.log,
    required this.onClearLog,
    super.key,
  });

  /// Current task list.
  final List<TodoItem> items;

  /// Action log, newest first.
  final List<String> log;

  /// Called when the log "Clear" button is pressed.
  final VoidCallback onClearLog;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TodoSurvivalInstructions(),
        TodoSurvivalStatsBar(items: items),
        const Divider(height: 1),
        if (items.isNotEmpty) TodoSurvivalTaskList(items: items),
        const Divider(height: 1),
        TodoSurvivalLogHeader(count: log.length, onClear: onClearLog),
        Expanded(child: TodoSurvivalLogList(log: log)),
      ],
    );
  }
}
