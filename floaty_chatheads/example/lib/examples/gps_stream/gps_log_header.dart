import 'package:flutter/material.dart';

/// Header above the push log with a count and a clear button.
final class GpsLogHeader extends StatelessWidget {
  /// Creates the header for a log of [count] entries.
  const factory GpsLogHeader({
    required int count,
    required VoidCallback onClear,
    Key? key,
  }) = GpsLogHeader._;

  const GpsLogHeader._({
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            'Push Log ($count)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          if (count > 0)
            TextButton(onPressed: onClear, child: const Text('Clear')),
        ],
      ),
    );
  }
}
