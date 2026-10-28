import 'package:flutter/material.dart';

import 'dashboard_colors.dart';

/// Empty state shown when the dashboard has no notes.
final class DashboardEmptyNotes extends StatelessWidget {
  /// Creates the empty state.
  const factory DashboardEmptyNotes({Key? key}) = DashboardEmptyNotes._;

  const DashboardEmptyNotes._({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_add_rounded, size: 48, color: dashboardTextSecondary),
          SizedBox(height: 12),
          Text(
            'No notes yet',
            style: TextStyle(color: dashboardTextSecondary, fontSize: 15),
          ),
          SizedBox(height: 4),
          Text(
            'Tap "New" to create one',
            style: TextStyle(color: dashboardTextSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
