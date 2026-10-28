import 'package:flutter/material.dart';

import 'dashboard_colors.dart';
import 'dashboard_stat_badge.dart';

/// Row of total, pinned and added note counters.
final class DashboardStatsRow extends StatelessWidget {
  /// Creates the row from the three counters.
  const factory DashboardStatsRow({
    required int total,
    required int pinned,
    required int added,
    Key? key,
  }) = DashboardStatsRow._;

  const DashboardStatsRow._({
    required this.total,
    required this.pinned,
    required this.added,
    super.key,
  });

  /// Number of notes shown.
  final int total;

  /// Number of pinned notes.
  final int pinned;

  /// Number of notes created from the overlay.
  final int added;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: dashboardBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DashboardStatBadge(
            label: 'Total',
            value: '$total',
            icon: Icons.note_rounded,
            color: Colors.indigoAccent,
          ),
          DashboardStatBadge(
            label: 'Pinned',
            value: '$pinned',
            icon: Icons.push_pin_rounded,
            color: Colors.amber,
          ),
          DashboardStatBadge(
            label: 'Added',
            value: '$added',
            icon: Icons.add_circle_outline_rounded,
            color: Colors.greenAccent,
          ),
        ],
      ),
    );
  }
}
