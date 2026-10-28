import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'panel_anchor/panel_anchor_anchor_picker.dart';
import 'panel_anchor/panel_anchor_controls.dart';
import 'panel_anchor/panel_anchor_event_log.dart';
import 'panel_anchor/panel_anchor_intro_card.dart';
import 'panel_anchor/panel_anchor_size.dart';
import 'panel_anchor/panel_anchor_size_picker.dart';

part 'panel_anchor/panel_anchor_example_state.dart';

/// Playground for the `PanelAnchor` feature (v2.1.0): pick where the
/// expanded panel opens relative to the bubble (below, above or auto),
/// combine it with different panel sizes, and watch the native side
/// report back the resolved window position.
final class PanelAnchorExample extends StatefulWidget {
  /// Creates the panel anchor playground page.
  const factory PanelAnchorExample({Key? key}) = PanelAnchorExample._;

  const PanelAnchorExample._({super.key});

  @override
  State<PanelAnchorExample> createState() => _PanelAnchorExampleState();
}
