import 'package:flutter/material.dart';

import 'fullscreen_colors.dart';
import 'fullscreen_quick_reply_chip.dart';

/// Bottom bar with a "Quick replies" caption and one chip per reply.
final class FullscreenQuickReplies extends StatelessWidget {
  /// Creates the bar; [onReply] gets the text of the tapped chip.
  const factory FullscreenQuickReplies({
    required List<String> replies,
    required ValueChanged<String> onReply,
    Key? key,
  }) = FullscreenQuickReplies._;

  const FullscreenQuickReplies._({
    required this.replies,
    required this.onReply,
    super.key,
  });

  /// Reply texts, one chip each.
  final List<String> replies;

  /// Called with the text of the tapped reply.
  final ValueChanged<String> onReply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: fullscreenHeaderBg,
        border: Border(top: BorderSide(color: fullscreenBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick replies',
            style: TextStyle(
              color: fullscreenTextLight,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final text in replies)
                FullscreenQuickReplyChip(
                  text: text,
                  onTap: () => onReply(text),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
