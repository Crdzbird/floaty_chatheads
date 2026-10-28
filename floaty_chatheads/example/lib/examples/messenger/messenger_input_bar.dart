import 'package:flutter/material.dart';

/// Text input and send button at the bottom of the messenger page.
final class MessengerInputBar extends StatelessWidget {
  /// Creates the input bar editing [controller]; [onSend] sends the text.
  const factory MessengerInputBar({
    required TextEditingController controller,
    required VoidCallback onSend,
    Key? key,
  }) = MessengerInputBar._;

  const MessengerInputBar._({
    required this.controller,
    required this.onSend,
    super.key,
  });

  /// Controller holding the message being typed.
  final TextEditingController controller;

  /// Called on submit or when the send button is pressed.
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: onSend,
            child: const Icon(Icons.send, size: 18),
          ),
        ],
      ),
    );
  }
}
