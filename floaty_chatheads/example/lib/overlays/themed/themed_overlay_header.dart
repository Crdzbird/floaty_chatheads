import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'themed_palette_colors.dart';

/// Primary-colored title bar of the themed overlay.
final class ThemedOverlayHeader extends StatelessWidget {
  /// Creates the header colored from [palette].
  const factory ThemedOverlayHeader({
    required OverlayColorPalette? palette,
    Key? key,
  }) = ThemedOverlayHeader._;

  const ThemedOverlayHeader._({required this.palette, super.key});

  /// The palette received from the main app, if any.
  final OverlayColorPalette? palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.primaryOrDefault,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Text(
        'Themed Overlay',
        style: TextStyle(
          color: palette.onPrimaryOrDefault,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
