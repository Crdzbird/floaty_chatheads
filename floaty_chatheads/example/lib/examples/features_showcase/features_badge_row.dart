import 'package:flutter/material.dart';

/// Badge +1 and Clear buttons of the features showcase.
final class FeaturesBadgeRow extends StatelessWidget {
  /// Creates the row; [count] is shown on the increment button.
  const factory FeaturesBadgeRow({
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onClear,
    Key? key,
  }) = FeaturesBadgeRow._;

  const FeaturesBadgeRow._({
    required this.count,
    required this.onIncrement,
    required this.onClear,
    super.key,
  });

  /// Current badge count.
  final int count;

  /// Called when "Badge +1" is pressed.
  final VoidCallback onIncrement;

  /// Called when "Clear" is pressed.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onIncrement,
            icon: const Icon(Icons.add_circle),
            label: Text('Badge +1  ($count)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: onClear,
          child: const Text('Clear'),
        ),
      ],
    );
  }
}
