import 'package:flutter/material.dart';

/// Monospace list of pushed GPS updates, or a hint when it is empty.
final class GpsLogList extends StatelessWidget {
  /// Creates the list for [entries], newest first.
  const factory GpsLogList({required List<String> entries, Key? key}) =
      GpsLogList._;

  const GpsLogList._({required this.entries, super.key});

  /// Log lines, newest first.
  final List<String> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'GPS updates will appear here\n'
          'once the overlay is launched.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: entries.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          entries[i],
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
        ),
      ),
    );
  }
}
