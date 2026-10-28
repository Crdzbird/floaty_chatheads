import 'package:flutter/material.dart';

/// Red badge showing how many actions are queued while disconnected.
final class SurvivalQueueBadge extends StatelessWidget {
  /// Creates the badge for [count] queued actions.
  const factory SurvivalQueueBadge({required int count, Key? key}) =
      SurvivalQueueBadge._;

  const SurvivalQueueBadge._({required this.count, super.key});

  /// Number of queued actions.
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.queue,
            size: 12,
            color: Colors.red.shade400,
          ),
          const SizedBox(width: 4),
          Text(
            '$count queued',
            style: TextStyle(
              fontSize: 10,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
