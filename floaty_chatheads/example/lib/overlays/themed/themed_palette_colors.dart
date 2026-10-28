import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Palette colors with the themed overlay's fallbacks for when no palette
/// has been received yet.
extension ThemedPaletteColors on OverlayColorPalette? {
  /// Primary color, or a default purple.
  Color get primaryOrDefault => this?.primary ?? const Color(0xFF6200EE);

  /// Surface color, or white.
  Color get surfaceOrDefault => this?.surface ?? Colors.white;

  /// Color for content on primary, or white.
  Color get onPrimaryOrDefault => this?.onPrimary ?? Colors.white;

  /// Color for content on surface, or black87.
  Color get onSurfaceOrDefault => this?.onSurface ?? Colors.black87;
}
