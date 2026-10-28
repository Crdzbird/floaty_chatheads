import 'package:flutter/material.dart';

/// Row showing the current shared counter value.
final class SurvivalCounterRow extends StatelessWidget {
  /// Creates the row for [counter].
  const factory SurvivalCounterRow({required int counter, Key? key}) =
      SurvivalCounterRow._;

  const SurvivalCounterRow._({required this.counter, super.key});

  /// The counter value to show.
  final int counter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.tag,
            color: Colors.deepOrange.shade300,
          ),
          const SizedBox(width: 8),
          Text(
            'Counter: $counter',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
