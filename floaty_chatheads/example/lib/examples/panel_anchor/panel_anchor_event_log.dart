import 'package:flutter/material.dart';

/// Event header with a clear button followed by the reported events, or a
/// hint when nothing has been reported yet.
final class PanelAnchorEventLog extends StatelessWidget {
  /// Creates the log for [events], newest first.
  const factory PanelAnchorEventLog({
    required List<String> events,
    required VoidCallback onClear,
    Key? key,
  }) = PanelAnchorEventLog._;

  const PanelAnchorEventLog._({
    required this.events,
    required this.onClear,
    super.key,
  });

  /// Events to list, newest first.
  final List<String> events;

  /// Called when "Clear" is pressed.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Events (${events.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            if (events.isNotEmpty)
              TextButton(onPressed: onClear, child: const Text('Clear')),
          ],
        ),
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Show the chathead, then tap the bubble to expand it.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        for (final event in events)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(event, style: const TextStyle(fontSize: 13)),
            ),
          ),
      ],
    );
  }
}
