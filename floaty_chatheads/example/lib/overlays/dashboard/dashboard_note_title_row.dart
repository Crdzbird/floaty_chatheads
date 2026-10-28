import 'package:flutter/material.dart';

import 'dashboard_colors.dart';
import 'dashboard_note.dart';

/// Title line of a note card: optional pin, title and close icon.
final class DashboardNoteTitleRow extends StatelessWidget {
  /// Creates the title row for [note].
  const factory DashboardNoteTitleRow({
    required DashboardNote note,
    required VoidCallback onDismiss,
    Key? key,
  }) = DashboardNoteTitleRow._;

  const DashboardNoteTitleRow._({
    required this.note,
    required this.onDismiss,
    super.key,
  });

  /// The note whose title is shown.
  final DashboardNote note;

  /// Called when the close icon is tapped.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (note.pinned)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(Icons.push_pin_rounded, size: 12, color: note.color),
          ),
        Expanded(
          child: Text(
            note.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: note.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: onDismiss,
          child: const Icon(
            Icons.close_rounded,
            size: 16,
            color: dashboardTextSecondary,
          ),
        ),
      ],
    );
  }
}
