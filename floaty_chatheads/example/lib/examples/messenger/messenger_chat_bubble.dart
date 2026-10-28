import 'package:flutter/material.dart';

import 'messenger_message.dart';

/// A chat bubble in the main app, aligned right for the app's own
/// messages and left for the overlay's.
final class MessengerChatBubble extends StatelessWidget {
  /// Creates a bubble for [message].
  const factory MessengerChatBubble({
    required MessengerMessage message,
    Key? key,
  }) = MessengerChatBubble._;

  const MessengerChatBubble._({required this.message, super.key});

  /// The message to show.
  final MessengerMessage message;

  @override
  Widget build(BuildContext context) {
    final isApp = message.sender == 'app';
    return Align(
      alignment: isApp ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isApp ? Colors.indigo : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isApp ? 'You' : 'Overlay',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isApp ? Colors.white70 : Colors.black45,
              ),
            ),
            Text(
              message.text,
              style: TextStyle(color: isApp ? Colors.white : Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
