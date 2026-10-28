import 'package:flutter/material.dart';

/// Fixed-height lifecycle event log inside the features showcase overlay.
final class FeaturesOverlayEventLog extends StatelessWidget {
  /// Creates the log for [events], newest first.
  const factory FeaturesOverlayEventLog({
    required List<String> events,
    Key? key,
  }) = FeaturesOverlayEventLog._;

  const FeaturesOverlayEventLog._({required this.events, super.key});

  /// Log entries, newest first.
  final List<String> events;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: events.isEmpty
          ? const Center(
              child: Text(
                'Lifecycle events\nwill appear here',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white30, fontSize: 11),
              ),
            )
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Text(
                  events[i],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
    );
  }
}
