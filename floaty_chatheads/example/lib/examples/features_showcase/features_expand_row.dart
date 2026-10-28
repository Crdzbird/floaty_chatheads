import 'package:flutter/material.dart';

/// Expand and Collapse buttons of the features showcase.
final class FeaturesExpandRow extends StatelessWidget {
  /// Creates the row with its two callbacks.
  const factory FeaturesExpandRow({
    required VoidCallback onExpand,
    required VoidCallback onCollapse,
    Key? key,
  }) = FeaturesExpandRow._;

  const FeaturesExpandRow._({
    required this.onExpand,
    required this.onCollapse,
    super.key,
  });

  /// Called when "Expand" is pressed.
  final VoidCallback onExpand;

  /// Called when "Collapse" is pressed.
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onExpand,
            icon: const Icon(Icons.open_in_full),
            label: const Text('Expand'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onCollapse,
            icon: const Icon(Icons.close_fullscreen),
            label: const Text('Collapse'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
