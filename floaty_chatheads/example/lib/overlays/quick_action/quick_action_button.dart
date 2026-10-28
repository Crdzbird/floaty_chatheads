import 'package:flutter/material.dart';

/// Round colored button used for each quick action.
final class QuickActionButton extends StatelessWidget {
  /// Creates a round button with [icon] on a [color] circle.
  const factory QuickActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    Key? key,
  }) = QuickActionButton._;

  const QuickActionButton._({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    super.key,
  });

  /// Icon drawn in the circle.
  final IconData icon;

  /// Circle color.
  final Color color;

  /// Action name this button stands for.
  final String label;

  /// Called when the button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
