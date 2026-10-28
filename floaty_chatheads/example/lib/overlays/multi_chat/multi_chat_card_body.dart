import 'package:flutter/material.dart';

import 'multi_chat_send_button.dart';

/// Content of the multi-chat overlay card: active bubble id, hint, send
/// button and close link.
final class MultiChatCardBody extends StatelessWidget {
  /// Creates the card body for the bubble [activeId].
  const factory MultiChatCardBody({
    required String activeId,
    required VoidCallback onSend,
    required VoidCallback onClose,
    Key? key,
  }) = MultiChatCardBody._;

  const MultiChatCardBody._({
    required this.activeId,
    required this.onSend,
    required this.onClose,
    super.key,
  });

  /// ID of the bubble whose content is shown.
  final String activeId;

  /// Called when "Send to Main" is tapped.
  final VoidCallback onSend;

  /// Called when "Close" is tapped.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.chat_bubble, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          activeId,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          'Tap another bubble to switch',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        MultiChatSendButton(onTap: onSend),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onClose,
          child: Text(
            'Close',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
