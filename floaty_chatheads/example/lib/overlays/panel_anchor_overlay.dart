import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'panel_anchor/panel_anchor_resize_chip.dart';
import 'panel_anchor/panel_anchor_status_box.dart';

part 'panel_anchor/panel_anchor_overlay_state.dart';

/// Overlay side of the Panel Anchor Playground.
///
/// Reports every expand and collapse to the main app together with the
/// window position the native side resolved, and offers resize buttons
/// so the anchored-resize behavior can be tested live (the panel edge
/// facing the bubble must stay glued while the panel grows or shrinks).
final class PanelAnchorOverlay extends StatefulWidget {
  /// Creates the panel anchor overlay.
  const factory PanelAnchorOverlay({Key? key}) = PanelAnchorOverlay._;

  const PanelAnchorOverlay._({super.key});

  @override
  State<PanelAnchorOverlay> createState() => _PanelAnchorOverlayState();
}
