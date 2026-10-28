import 'package:flutter/material.dart';

/// Expanded tinted tile showing one counter value and its label.
final class TodoSurvivalStatChip extends StatelessWidget {
  /// Creates a chip showing [value] above [label] in [color].
  const factory TodoSurvivalStatChip({
    required String label,
    required String value,
    required Color color,
    Key? key,
  }) = TodoSurvivalStatChip._;

  const TodoSurvivalStatChip._({
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  /// Caption under the value.
  final String label;

  /// The counter value.
  final String value;

  /// Accent color of the chip.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }
}
