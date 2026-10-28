import 'package:flutter/material.dart';

/// Small tinted pill with an icon and a label.
final class DashboardActionChip extends StatelessWidget {
  /// Creates a chip that calls [onTap] when tapped.
  const factory DashboardActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    Key? key,
  }) = DashboardActionChip._;

  const DashboardActionChip._({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    super.key,
  });

  /// Leading icon.
  final IconData icon;

  /// Chip label.
  final String label;

  /// Tint of the icon, label and background.
  final Color color;

  /// Called when the chip is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
