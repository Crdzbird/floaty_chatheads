import 'package:flutter/material.dart';

/// Header above the action log with a count and a clear button.
final class TodoSurvivalLogHeader extends StatelessWidget {
  /// Creates the header for [count] log entries.
  const factory TodoSurvivalLogHeader({
    required int count,
    required VoidCallback onClear,
    Key? key,
  }) = TodoSurvivalLogHeader._;

  const TodoSurvivalLogHeader._({
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
