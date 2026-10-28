import 'package:flutter/material.dart';

import 'dashboard_colors.dart';

/// A circled icon above a big value and a small label.
final class DashboardStatBadge extends StatelessWidget {
  /// Creates a badge showing [value] under [icon].
  const factory DashboardStatBadge({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    Key? key,
  }) = DashboardStatBadge._;

  const DashboardStatBadge._({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
  });

  /// Caption under the value.
  final String label;

  /// The counter value.
  final String value;

  /// Icon in the circle.
  final IconData icon;

  /// Tint of the icon, circle and value.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: dashboardTextSecondary, fontSize: 10),
        ),
      ],
    );
  }
}
