import 'package:flutter/material.dart';

import 'dashboard_note_field.dart';

/// Form with a title, an optional body and a button that pushes the note
/// to the overlay.
final class DashboardNoteForm extends StatelessWidget {
  /// Creates the form bound to the given controllers.
  const factory DashboardNoteForm({
    required TextEditingController titleController,
    required TextEditingController bodyController,
    required VoidCallback onPush,
    Key? key,
  }) = DashboardNoteForm._;

  const DashboardNoteForm._({
    required this.titleController,
    required this.bodyController,
    required this.onPush,
    super.key,
  });

  /// Controller of the note title field.
  final TextEditingController titleController;

  /// Controller of the note body field.
  final TextEditingController bodyController;

  /// Called when "Push Note to Overlay" is pressed.
  final VoidCallback onPush;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Push a note to the overlay',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DashboardNoteField(controller: titleController, hint: 'Note title'),
          const SizedBox(height: 8),
          DashboardNoteField(
            controller: bodyController,
            hint: 'Note body (optional)',
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onPush,
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Push Note to Overlay'),
          ),
        ],
      ),
    );
  }
}
