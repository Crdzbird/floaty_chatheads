import 'package:flutter/material.dart';

/// Scrollable list of messages received from the overlay, or a hint when
/// nothing has arrived yet.
final class ReceivedList extends StatelessWidget {
  /// Creates the list for [messages], newest first.
  const factory ReceivedList({required List<String> messages, Key? key}) =
      ReceivedList._;

  const ReceivedList._({required this.messages, super.key});

  /// Messages to show, newest first.
  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'Tap the chathead, then press\n"Send to Main" in the overlay',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: messages.length,
      itemBuilder: (_, i) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(messages[i], style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
}
