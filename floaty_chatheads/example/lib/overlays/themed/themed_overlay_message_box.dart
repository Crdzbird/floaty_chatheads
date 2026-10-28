import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'themed_palette_colors.dart';

/// Tinted box showing the last message received from the main app.
final class ThemedOverlayMessageBox extends StatelessWidget {
  /// Creates the box showing [message], colored from [palette].
  const factory ThemedOverlayMessageBox({
    required OverlayColorPalette? palette,
    required String message,
    Key? key,
  }) = ThemedOverlayMessageBox._;

  const ThemedOverlayMessageBox._({
    required this.palette,
    required this.message,
    super.key,
  });

  /// The palette received from the main app, if any.
  final OverlayColorPalette? palette;

  /// The message to show, clipped to two lines.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: palette.primaryOrDefault.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        message,
        style: TextStyle(color: palette.onSurfaceOrDefault, fontSize: 10),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
