import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'themed_palette_colors.dart';

/// Primary-colored "Send to Main" pill of the themed overlay.
final class ThemedOverlaySendButton extends StatelessWidget {
  /// Creates the pill colored from [palette].
  const factory ThemedOverlaySendButton({
    required OverlayColorPalette? palette,
    required VoidCallback onTap,
    Key? key,
  }) = ThemedOverlaySendButton._;

  const ThemedOverlaySendButton._({
    required this.palette,
    required this.onTap,
    super.key,
  });

  /// The palette received from the main app, if any.
  final OverlayColorPalette? palette;

  /// Called when the pill is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: palette.primaryOrDefault,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Send to Main',
          style: TextStyle(
            color: palette.onPrimaryOrDefault,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
