import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'dashboard_action_chip.dart';
import 'dashboard_colors.dart';

/// Header bar of the dashboard overlay with title, "New" chip and close.
final class DashboardHeader extends StatelessWidget {
  /// Creates the header; [onAdd] runs when "New" is tapped.
  const factory DashboardHeader({required VoidCallback onAdd, Key? key}) =
      DashboardHeader._;

  const DashboardHeader._({required this.onAdd, super.key});

  /// Called when the "New" chip is tapped.
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
      decoration: const BoxDecoration(
        color: dashboardSurface,
        border: Border(bottom: BorderSide(color: dashboardDivider)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.indigoAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Notes Dashboard',
              style: TextStyle(
                color: dashboardTextPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DashboardActionChip(
            icon: Icons.add_rounded,
            label: 'New',
            color: Colors.indigoAccent,
            onTap: onAdd,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => unawaited(FloatyOverlay.closeOverlay()),
            child: const Icon(
              Icons.close_rounded,
              color: dashboardTextSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
