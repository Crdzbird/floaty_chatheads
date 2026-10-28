import 'package:flutter/material.dart';

/// Header above the action log with a count and a clear button.
final class SurvivalLogHeader extends StatelessWidget {
  /// Creates the header for a log with [count] entries.
  const factory SurvivalLogHeader({
    required int count,
    required VoidCallback onClear,
    Key? key,
  }) = SurvivalLogHeader._;

  const SurvivalLogHeader._({
    required this.count,
    required this.onClear,
    super.key,
  });

  /// Number of log entries.
  final int count;

  /// Called when "Clear" is pressed.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      child: Row(
        children: [
          Text(
            'Action Log ($count)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          if (count > 0)
            TextButton(
              onPressed: onClear,
              child: const Text('Clear'),
            ),
        ],
      ),
    );
  }
}
