import 'package:flutter/material.dart';

/// Header and up to fifteen of the newest events sent by the overlay.
final class AccessibilityEventLog extends StatelessWidget {
  /// Creates the log for [events], newest first.
  const factory AccessibilityEventLog({
    required List<String> events,
    Key? key,
  }) = AccessibilityEventLog._;

  const AccessibilityEventLog._({required this.events, super.key});

  /// Events received from the overlay, newest first.
  final List<String> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Overlay events (${events.length})',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (events.isEmpty)
          const Text(
            'Events from the overlay will appear here.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ...events
            .take(15)
            .map(
              (e) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(e, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ),
      ],
    );
  }
}
