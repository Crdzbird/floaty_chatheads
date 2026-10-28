import 'package:flutter/material.dart';

/// Status row showing the bubble count and which bubble is active.
final class MultiChatheadStatus extends StatelessWidget {
  /// Creates the status row.
  const factory MultiChatheadStatus({
    required int bubbleCount,
    String? activeId,
    Key? key,
  }) = MultiChatheadStatus._;

  const MultiChatheadStatus._({
    required this.bubbleCount,
    this.activeId,
    super.key,
  });

  /// Total number of bubbles, including the default one.
  final int bubbleCount;

  /// ID of the active bubble, if known.
  final String? activeId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Bubbles: $bubbleCount',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (activeId != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.cyan.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Active: $activeId',
                style: TextStyle(fontSize: 11, color: Colors.cyan.shade700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
