import 'package:flutter/material.dart';

/// Expanded tinted button used for the counter increments.
final class SurvivalActionButton extends StatelessWidget {
  /// Creates a button showing [label] in [color].
  const factory SurvivalActionButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
    Key? key,
  }) = SurvivalActionButton._;

  const SurvivalActionButton._({
    required this.label,
    required this.onTap,
    required this.color,
    super.key,
  });

  /// Button text.
  final String label;

  /// Called when the button is tapped.
  final VoidCallback onTap;

  /// Tint for the text, fill and border.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
