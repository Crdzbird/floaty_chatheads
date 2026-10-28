import 'package:flutter/material.dart';

/// Dense outlined text field used by the note form.
final class DashboardNoteField extends StatelessWidget {
  /// Creates a field bound to [controller] showing [hint].
  const factory DashboardNoteField({
    required TextEditingController controller,
    required String hint,
    int maxLines,
    Key? key,
  }) = DashboardNoteField._;

  const DashboardNoteField._({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    super.key,
  });

  /// Controller holding the field text.
  final TextEditingController controller;

  /// Hint text shown while empty.
  final String hint;

  /// Number of visible lines.
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
      ),
    );
  }
}
