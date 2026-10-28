import 'package:flutter/material.dart';

import 'todo_survival_overlay_add_button.dart';

/// Header row of the todo survival overlay with task counts and an add
/// button.
final class TodoSurvivalOverlayHeader extends StatelessWidget {
  /// Creates the header for [taskCount] tasks, [doneCount] of them done.
  const factory TodoSurvivalOverlayHeader({
    required int taskCount,
    required int doneCount,
    required bool connected,
    required VoidCallback onAdd,
    Key? key,
  }) = TodoSurvivalOverlayHeader._;

  const TodoSurvivalOverlayHeader._({
    required this.taskCount,
    required this.doneCount,
    required this.connected,
    required this.onAdd,
    super.key,
  });

  /// Number of tasks in the list.
  final int taskCount;

  /// Number of completed tasks.
  final int doneCount;

  /// Whether the main app is connected; greys the header when not.
  final bool connected;

  /// Called when the add button is tapped.
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          Icon(
            Icons.checklist,
            size: 18,
            color: connected ? Colors.teal : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            '$taskCount tasks ($doneCount done)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: connected ? Colors.teal.shade700 : Colors.grey,
            ),
          ),
          const Spacer(),
          TodoSurvivalOverlayAddButton(onTap: onAdd),
        ],
      ),
    );
  }
}
