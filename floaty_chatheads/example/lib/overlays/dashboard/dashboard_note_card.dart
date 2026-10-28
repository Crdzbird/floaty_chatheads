import 'package:flutter/material.dart';

import 'dashboard_colors.dart';
import 'dashboard_note.dart';
import 'dashboard_note_title_row.dart';

/// Card for one note with a colored accent strip on the left.
final class DashboardNoteCard extends StatelessWidget {
  /// Creates a card for [note]; [onDismiss] runs when its close icon is
  /// tapped.
  const factory DashboardNoteCard({
    required DashboardNote note,
    required VoidCallback onDismiss,
    Key? key,
  }) = DashboardNoteCard._;

  const DashboardNoteCard._({
    required this.note,
    required this.onDismiss,
    super.key,
  });

  /// The note to show.
  final DashboardNote note;

  /// Called when the close icon is tapped.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: dashboardSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, color: note.color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardNoteTitleRow(note: note, onDismiss: onDismiss),
                    const SizedBox(height: 6),
                    Text(
                      note.body,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: dashboardTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
