import 'package:flutter/material.dart';

/// Rounded message field with a small send button.
final class MessengerFullscreenComposer extends StatelessWidget {
  /// Creates the composer bound to [controller].
  const factory MessengerFullscreenComposer({
    required TextEditingController controller,
    required VoidCallback onSend,
    Key? key,
  }) = MessengerFullscreenComposer._;

  const MessengerFullscreenComposer._({
    required this.controller,
    required this.onSend,
    super.key,
  });

  /// Controller holding the message text.
  final TextEditingController controller;

  /// Called on submit or when the send button is pressed.
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Send a message to overlay...',
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
