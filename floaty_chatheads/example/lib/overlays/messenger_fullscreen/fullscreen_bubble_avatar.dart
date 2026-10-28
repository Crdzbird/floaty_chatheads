import 'package:flutter/material.dart';

import 'fullscreen_colors.dart';

/// Small round avatar shown beside received bubbles.
final class FullscreenBubbleAvatar extends StatelessWidget {
  /// Creates the small avatar.
  const factory FullscreenBubbleAvatar({Key? key}) = FullscreenBubbleAvatar._;

  const FullscreenBubbleAvatar._({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: fullscreenMessengerBlue,
      ),
      child: const Center(
        child: Text(
          'A',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
