import 'package:flutter/material.dart';

import 'fullscreen_bubble_avatar.dart';
import 'fullscreen_bubble_text.dart';
import 'fullscreen_chat_message.dart';
import 'fullscreen_colors.dart';

/// One message bubble, aligned right when sent and left when received.
final class FullscreenMessageBubble extends StatelessWidget {
  /// Creates a bubble for [msg]; [showAvatar] shows the small avatar.
  const factory FullscreenMessageBubble({
    required FullscreenChatMessage msg,
    required bool showAvatar,
    Key? key,
  }) = FullscreenMessageBubble._;

  const FullscreenMessageBubble._({
    required this.msg,
    required this.showAvatar,
    super.key,
  });

  /// The message to show.
  final FullscreenChatMessage msg;

  /// Whether to show the contact avatar next to a received bubble.
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 6,
        left: msg.isMe ? 48 : 0,
        right: msg.isMe ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment: msg.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMe)
            SizedBox(
              width: 30,
              child: showAvatar ? const FullscreenBubbleAvatar() : null,
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isMe
                    ? fullscreenMessengerBlue
                    : fullscreenReceivedBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isMe ? 18 : 4),
                  bottomRight: Radius.circular(msg.isMe ? 4 : 18),
                ),
              ),
              child: FullscreenBubbleText(msg: msg),
            ),
          ),
        ],
      ),
    );
  }
}
