import 'package:flutter/material.dart';

/// Large counter value with the state label underneath.
final class SurvivalCounterDisplay extends StatelessWidget {
  /// Creates the display for [value] and [label].
  const factory SurvivalCounterDisplay({
    required int value,
    required String label,
    required bool connected,
    Key? key,
  }) = SurvivalCounterDisplay._;

  const SurvivalCounterDisplay._({
    required this.value,
    required this.label,
    required this.connected,
    super.key,
  });

  /// The counter value to show.
  final int value;

  /// The state label shown under the value.
  final String label;

  /// Whether the main app is connected; greys out the value when not.
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: connected ? Colors.deepOrange : Colors.grey,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
