import 'package:flutter/material.dart';

import 'fullscreen_colors.dart';

/// Blue pill that sends its text as a reply when tapped.
final class FullscreenQuickReplyChip extends StatelessWidget {
  /// Creates a chip labelled [text].
  const factory FullscreenQuickReplyChip({
    required String text,
    required VoidCallback onTap,
    Key? key,
  }) = FullscreenQuickReplyChip._;

  const FullscreenQuickReplyChip._({
    required this.text,
    required this.onTap,
    super.key,
  });

  /// Reply text.
  final String text;

  /// Called when the chip is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: fullscreenMessengerBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
