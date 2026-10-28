import 'package:flutter/material.dart';

/// Header above the received messages with a count and a clear button.
final class ReceivedHeader extends StatelessWidget {
  /// Creates the header for [count] received messages.
  const factory ReceivedHeader({
    required int count,
    required VoidCallback onClear,
    Key? key,
  }) = ReceivedHeader._;

  const ReceivedHeader._({
    required this.count,
    required this.onClear,
    super.key,
  });

  /// Number of messages received so far.
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
            'Received from overlay ($count)',
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
