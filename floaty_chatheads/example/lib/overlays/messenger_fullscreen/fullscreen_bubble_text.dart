import 'package:flutter/material.dart';

import 'fullscreen_chat_message.dart';
import 'fullscreen_colors.dart';

/// Message text with its time underneath, colored for sent or received.
final class FullscreenBubbleText extends StatelessWidget {
  /// Creates the bubble content for [msg].
  const factory FullscreenBubbleText({
    required FullscreenChatMessage msg,
    Key? key,
  }) = FullscreenBubbleText._;

  const FullscreenBubbleText._({required this.msg, super.key});

  /// The message to show.
  final FullscreenChatMessage msg;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          msg.text,
          style: TextStyle(
            color: msg.isMe ? Colors.white : fullscreenTextDark,
            fontSize: 15,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          msg.time,
          style: TextStyle(
            color: msg.isMe
                ? Colors.white.withValues(alpha: 0.6)
                : fullscreenTextLight,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
