import 'package:flutter/material.dart';

/// The action log list, or a hint while it is empty.
final class TodoSurvivalLogList extends StatelessWidget {
  /// Creates the list for [log] entries, newest first.
  const factory TodoSurvivalLogList({required List<String> log, Key? key}) =
      TodoSurvivalLogList._;

  const TodoSurvivalLogList._({required this.log, super.key});

  /// Log entries, newest first.
  final List<String> log;

  @override
  Widget build(BuildContext context) {
    if (log.isEmpty) {
      return const Center(
        child: Text(
          'Actions from the overlay will appear here.\n'
          'Try killing the app and managing\n'
          'tasks from the overlay!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: log.length,
      itemBuilder: (_, i) => Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            log[i],
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}
