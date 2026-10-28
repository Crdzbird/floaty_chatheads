import 'package:flutter/material.dart';

import '../../examples/messenger/messenger_message.dart';
import 'messenger_overlay_bubble.dart';

/// Shrink-wrapped message list of the messenger overlay, or a hint when
/// there are no messages yet.
final class MessengerOverlayMessageList extends StatelessWidget {
  /// Creates the list for [messages], scrolled by [controller].
  const factory MessengerOverlayMessageList({
    required List<MessengerMessage> messages,
    required ScrollController controller,
    Key? key,
  }) = MessengerOverlayMessageList._;

  const MessengerOverlayMessageList._({
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
      return Center(
        child: Text(
          'Messages appear here',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
      );
    }
    return ListView.builder(
      controller: controller,
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      itemCount: messages.length,
      itemBuilder: (_, i) => MessengerOverlayBubble(message: messages[i]),
    );
  }
}
