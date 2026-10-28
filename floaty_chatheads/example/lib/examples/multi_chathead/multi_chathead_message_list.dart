import 'package:flutter/material.dart';

/// Messages received from the overlay bubbles, or a hint when empty.
final class MultiChatheadMessageList extends StatelessWidget {
  /// Creates the list for [messages], newest first.
  const factory MultiChatheadMessageList({
    required List<String> messages,
    Key? key,
  }) = MultiChatheadMessageList._;

  const MultiChatheadMessageList._({required this.messages, super.key});

  /// Messages to show, newest first.
  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Show the chathead, add bubbles,\n'
            'then expand and tap "Send to Main"\n'
            'in the overlay.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (_, i) => Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(messages[i], style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
}
