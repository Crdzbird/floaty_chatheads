import 'package:flutter/material.dart';

/// List of overlay responses, or a hint when nothing has arrived yet.
final class ThemedResponsesList extends StatelessWidget {
  /// Creates the list for [responses], newest first.
  const factory ThemedResponsesList({
    required List<String> responses,
    Key? key,
  }) = ThemedResponsesList._;

  const ThemedResponsesList._({required this.responses, super.key});

  /// Responses to show, newest first.
  final List<String> responses;

  @override
  Widget build(BuildContext context) {
    if (responses.isEmpty) {
      return const Center(
        child: Text(
          'Launch a themed chathead and interact with the overlay',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: responses.length,
      itemBuilder: (_, i) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(responses[i], style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
