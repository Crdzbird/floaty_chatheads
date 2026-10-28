import 'package:flutter/material.dart';

import 'fullscreen_chat_message.dart';
import 'fullscreen_message_bubble.dart';

/// Scrollable conversation; shows the contact avatar on the first message
/// of each received run.
final class FullscreenMessageList extends StatelessWidget {
  /// Creates the list for [messages], scrolled by [controller].
  const factory FullscreenMessageList({
    required ScrollController controller,
    required List<FullscreenChatMessage> messages,
    Key? key,
  }) = FullscreenMessageList._;

  const FullscreenMessageList._({
    required this.controller,
    required this.messages,
    super.key,
  });

  /// Scroll controller of the list.
  final ScrollController controller;

  /// Messages in chronological order.
  final List<FullscreenChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final msg = messages[i];
        final showAvatar = !msg.isMe && (i == 0 || messages[i - 1].isMe);
        return FullscreenMessageBubble(msg: msg, showAvatar: showAvatar);
      },
    );
  }
}
