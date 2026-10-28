import 'package:flutter/material.dart';

/// Scrollable action log, or a hint when the log is empty.
final class SurvivalLogList extends StatelessWidget {
  /// Creates the list for [entries], newest first.
  const factory SurvivalLogList({required List<String> entries, Key? key}) =
      SurvivalLogList._;

  const SurvivalLogList._({required this.entries, super.key});

  /// Log entries to show, newest first.
  final List<String> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'Actions from the overlay will appear here.\n'
          'Try killing the app and sending\n'
          'actions from the overlay!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      itemCount: entries.length,
      itemBuilder: (_, i) => Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            entries[i],
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}
