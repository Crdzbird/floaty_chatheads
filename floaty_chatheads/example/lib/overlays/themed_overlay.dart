import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'themed/themed_overlay_body.dart';
import 'themed/themed_overlay_header.dart';
import 'themed/themed_palette_colors.dart';

part 'themed/themed_overlay_state.dart';

/// Overlay that consumes the theme palette sent from the main app.
///
/// Uses [FloatyOverlay.palette] and [FloatyOverlay.onPaletteChanged] to
/// apply host-defined colors to the overlay UI.
final class ThemedOverlay extends StatefulWidget {
  /// Creates the themed overlay.
  const factory ThemedOverlay({Key? key}) = ThemedOverlay._;

  const ThemedOverlay._({super.key});

  @override
  State<ThemedOverlay> createState() => _ThemedOverlayState();
}
