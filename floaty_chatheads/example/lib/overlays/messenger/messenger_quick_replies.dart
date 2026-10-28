import 'package:flutter/material.dart';

import 'messenger_quick_reply_chip.dart';

/// Row of tap-to-send quick reply chips at the bottom of the overlay.
final class MessengerQuickReplies extends StatelessWidget {
  /// Creates chips for [replies]; [onReply] receives the tapped text.
  const factory MessengerQuickReplies({
    required List<String> replies,
    required ValueChanged<String> onReply,
    Key? key,
  }) = MessengerQuickReplies._;

  const MessengerQuickReplies._({
    required this.replies,
    required this.onReply,
    super.key,
  });

  /// The reply texts to offer.
  final List<String> replies;

  /// Called with the text of the tapped chip.
  final ValueChanged<String> onReply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: replies
            .map(
              (text) => MessengerQuickReplyChip(
                text: text,
                onTap: () => onReply(text),
              ),
            )
            .toList(),
      ),
    );
  }
}
