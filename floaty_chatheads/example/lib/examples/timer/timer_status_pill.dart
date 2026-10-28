import 'package:flutter/material.dart';

/// Rounded pill showing whether the overlay stopwatch is running.
final class TimerStatusPill extends StatelessWidget {
  /// Creates the pill for the given [isRunning] state.
  const factory TimerStatusPill({required bool isRunning, Key? key}) =
      TimerStatusPill._;

  const TimerStatusPill._({required this.isRunning, super.key});

  /// Whether the stopwatch is running.
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final color = isRunning ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isRunning ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRunning ? Icons.play_arrow : Icons.pause,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isRunning ? 'Running' : 'Stopped',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
