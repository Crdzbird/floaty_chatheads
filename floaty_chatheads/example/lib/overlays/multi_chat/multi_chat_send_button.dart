import 'package:flutter/material.dart';

/// Pill shaped "Send to Main" button of the multi-chat overlay.
final class MultiChatSendButton extends StatelessWidget {
  /// Creates the button; [onTap] sends the message.
  const factory MultiChatSendButton({
    required VoidCallback onTap,
    Key? key,
  }) = MultiChatSendButton._;

  const MultiChatSendButton._({required this.onTap, super.key});

  /// Called when the button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.send, size: 14, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Send to Main',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
