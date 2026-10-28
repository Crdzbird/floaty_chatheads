import 'package:flutter/material.dart';

/// Event log title with an entry count and a clear button.
final class FeaturesEventLogHeader extends StatelessWidget {
  /// Creates the header for a log of [count] entries.
  const factory FeaturesEventLogHeader({
    required int count,
    required VoidCallback onClear,
    Key? key,
  }) = FeaturesEventLogHeader._;

  const FeaturesEventLogHeader._({
    required this.count,
    required this.onClear,
    super.key,
  });

  /// Number of entries in the log.
  final int count;

  /// Called when "Clear" is pressed.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Event Log ($count)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const Spacer(),
        if (count > 0)
          TextButton(onPressed: onClear, child: const Text('Clear')),
      ],
    );
  }
}
