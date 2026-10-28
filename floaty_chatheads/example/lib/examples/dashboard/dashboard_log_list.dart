import 'package:flutter/material.dart';

/// Scrollable list of log entries as cards, or [emptyText] when empty.
final class DashboardLogList extends StatelessWidget {
  /// Creates the list for [entries], newest first.
  const factory DashboardLogList({
    required List<String> entries,
    required String emptyText,
    required double fontSize,
    Key? key,
  }) = DashboardLogList._;

  const DashboardLogList._({
    required this.entries,
    required this.emptyText,
    required this.fontSize,
    super.key,
  });

  /// Entries to show, newest first.
  final List<String> entries;

  /// Hint shown while there are no entries.
  final String emptyText;

  /// Font size of each entry.
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: entries.length,
      itemBuilder: (_, i) => Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(entries[i], style: TextStyle(fontSize: fontSize)),
        ),
      ),
    );
  }
}
