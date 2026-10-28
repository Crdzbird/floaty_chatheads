import 'package:flutter/material.dart';

import '../../models/todo_actions.dart';

/// One task in the overlay list with toggle and remove controls.
final class TodoSurvivalOverlayTaskRow extends StatelessWidget {
  /// Creates the row for [item].
  const factory TodoSurvivalOverlayTaskRow({
    required TodoItem item,
    required VoidCallback onToggle,
    required VoidCallback onRemove,
    Key? key,
  }) = TodoSurvivalOverlayTaskRow._;

  const TodoSurvivalOverlayTaskRow._({
    required this.item,
    required this.onToggle,
    required this.onRemove,
    super.key,
  });

  /// The task shown in this row.
  final TodoItem item;

  /// Called when the done icon is tapped.
  final VoidCallback onToggle;

  /// Called when the remove icon is tapped.
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              item.done ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: item.done ? Colors.green : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                fontSize: 11,
                decoration: item.done ? TextDecoration.lineThrough : null,
                color: item.done ? Colors.grey : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: Colors.red.shade300),
          ),
        ],
      ),
    );
  }
}
