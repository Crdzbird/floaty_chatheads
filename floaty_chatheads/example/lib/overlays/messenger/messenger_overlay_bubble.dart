import 'package:flutter/material.dart';

import '../../examples/messenger/messenger_message.dart';

/// A compact chat bubble in the overlay, aligned right for the overlay's
/// own messages and left for the app's.
final class MessengerOverlayBubble extends StatelessWidget {
  /// Creates a bubble for [message].
  const factory MessengerOverlayBubble({
    required MessengerMessage message,
    Key? key,
  }) = MessengerOverlayBubble._;

  const MessengerOverlayBubble._({required this.message, super.key});

  /// The message to show.
  final MessengerMessage message;

  @override
  Widget build(BuildContext context) {
    final isMe = message.sender == 'overlay';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isMe ? Colors.indigo : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
