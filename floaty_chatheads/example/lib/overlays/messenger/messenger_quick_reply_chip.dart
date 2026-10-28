import 'package:flutter/material.dart';

/// A rounded tap target that sends one quick reply.
final class MessengerQuickReplyChip extends StatelessWidget {
  /// Creates a chip labelled [text] that calls [onTap].
  const factory MessengerQuickReplyChip({
    required String text,
    required VoidCallback onTap,
    Key? key,
  }) = MessengerQuickReplyChip._;

  const MessengerQuickReplyChip._({
    required this.text,
    required this.onTap,
    super.key,
  });

  /// The reply text.
  final String text;

  /// Called when the chip is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.indigo.shade200),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.indigo.shade700),
        ),
      ),
    );
  }
}
