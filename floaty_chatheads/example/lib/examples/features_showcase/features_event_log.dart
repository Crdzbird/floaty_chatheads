import 'package:flutter/material.dart';

/// Event log entries of the features showcase, or a hint when empty.
final class FeaturesEventLog extends StatelessWidget {
  /// Creates the log for [events], newest first.
  const factory FeaturesEventLog({required List<String> events, Key? key}) =
      FeaturesEventLog._;

  const FeaturesEventLog._({required this.events, super.key});

  /// Log entries, newest first.
  final List<String> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Show the chathead, then use the controls above.\n'
          'Lifecycle events will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final event in events)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(event, style: const TextStyle(fontSize: 13)),
          ),
      ],
    );
  }
}
