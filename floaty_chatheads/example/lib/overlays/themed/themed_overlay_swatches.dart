import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'themed_overlay_swatch.dart';

/// Row of color swatches previewing the received palette.
final class ThemedOverlaySwatches extends StatelessWidget {
  /// Creates the swatch row for [palette].
  const factory ThemedOverlaySwatches({
    required OverlayColorPalette palette,
    Key? key,
  }) = ThemedOverlaySwatches._;

  const ThemedOverlaySwatches._({required this.palette, super.key});

  /// The palette to preview.
  final OverlayColorPalette palette;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ThemedOverlaySwatch(label: 'P', color: palette.primary),
        ThemedOverlaySwatch(label: 'S', color: palette.secondary),
        ThemedOverlaySwatch(label: 'Sf', color: palette.surface),
        ThemedOverlaySwatch(label: 'Bg', color: palette.background),
        ThemedOverlaySwatch(label: 'E', color: palette.error),
      ],
    );
  }
}
