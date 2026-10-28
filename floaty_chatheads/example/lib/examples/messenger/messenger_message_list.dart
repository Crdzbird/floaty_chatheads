import 'package:flutter/material.dart';

import 'messenger_chat_bubble.dart';
import 'messenger_message.dart';

/// Scrollable list of chat messages in the main app, or a hint when empty.
final class MessengerMessageList extends StatelessWidget {
  /// Creates the list for [messages], scrolled by [controller].
  const factory MessengerMessageList({
    required List<MessengerMessage> messages,
    required ScrollController controller,
    Key? key,
  }) = MessengerMessageList._;

  const MessengerMessageList._({
    required this.messages,
    required this.controller,
    super.key,
  });

  /// Messages to show, oldest first.
  final List<MessengerMessage> messages;

  /// Controller that drives the list scroll position.
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet.\nSend a message below!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (_, i) => MessengerChatBubble(message: messages[i]),
    );
  }
}
