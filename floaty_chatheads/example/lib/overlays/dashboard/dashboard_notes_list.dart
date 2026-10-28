import 'package:flutter/material.dart';

import 'dashboard_empty_notes.dart';
import 'dashboard_note.dart';
import 'dashboard_note_card.dart';

/// Scrollable list of note cards, or an empty state when there are none.
final class DashboardNotesList extends StatelessWidget {
  /// Creates the list; [onRemove] gets the index of a dismissed note.
  const factory DashboardNotesList({
    required List<DashboardNote> notes,
    required ValueChanged<int> onRemove,
    Key? key,
  }) = DashboardNotesList._;

  const DashboardNotesList._({
    required this.notes,
    required this.onRemove,
    super.key,
  });

  /// Notes to show.
  final List<DashboardNote> notes;

  /// Called with the index of the note whose close icon was tapped.
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const DashboardEmptyNotes();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: notes.length,
      itemBuilder: (context, index) => DashboardNoteCard(
        note: notes[index],
        onDismiss: () => onRemove(index),
      ),
    );
  }
}
