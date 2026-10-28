import 'package:flutter/material.dart';

/// Header above the overlay responses with a count and a clear button.
final class ThemedResponsesHeader extends StatelessWidget {
  /// Creates the header for [count] responses.
  const factory ThemedResponsesHeader({
    required int count,
    required VoidCallback onClear,
    Key? key,
  }) = ThemedResponsesHeader._;

  const ThemedResponsesHeader._({
    required this.count,
    required this.onClear,
    super.key,
  });

  /// Number of responses received.
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
            'Overlay responses ($count)',
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
