import 'package:flutter/material.dart';

import 'fullscreen_colors.dart';

/// Large gradient avatar with the contact initial.
final class FullscreenHeaderAvatar extends StatelessWidget {
  /// Creates the header avatar.
  const factory FullscreenHeaderAvatar({Key? key}) = FullscreenHeaderAvatar._;

  const FullscreenHeaderAvatar._({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            fullscreenMessengerBlue,
            fullscreenMessengerBlue.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: const Center(
        child: Text(
          'A',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
