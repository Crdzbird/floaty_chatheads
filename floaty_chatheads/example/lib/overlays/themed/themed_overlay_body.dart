import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'themed_overlay_message_box.dart';
import 'themed_overlay_send_button.dart';
import 'themed_overlay_swatches.dart';
import 'themed_palette_colors.dart';

/// Body of the themed overlay: palette status, swatches, last message,
/// send and close actions.
final class ThemedOverlayBody extends StatelessWidget {
  /// Creates the body colored from [palette].
  const factory ThemedOverlayBody({
    required OverlayColorPalette? palette,
    required String lastMessage,
    required VoidCallback onSend,
    required VoidCallback onClose,
    Key? key,
  }) = ThemedOverlayBody._;

  const ThemedOverlayBody._({
    required this.palette,
    required this.lastMessage,
    required this.onSend,
    required this.onClose,
    super.key,
  });

  /// The palette received from the main app, if any.
  final OverlayColorPalette? palette;

  /// Last payload received from the main app.
  final String lastMessage;

  /// Called when "Send to Main" is tapped.
  final VoidCallback onSend;

  /// Called when "Close" is tapped.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final received = palette;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            received != null ? 'Palette received!' : 'No palette yet',
            style: TextStyle(color: palette.onSurfaceOrDefault, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (received != null) ThemedOverlaySwatches(palette: received),
          const SizedBox(height: 8),
          ThemedOverlayMessageBox(palette: palette, message: lastMessage),
          const SizedBox(height: 8),
          ThemedOverlaySendButton(palette: palette, onTap: onSend),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onClose,
            child: Text(
              'Close',
              style: TextStyle(
                color: palette.onSurfaceOrDefault.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
