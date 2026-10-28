import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'mini_player/mini_player_overlay_controls.dart';

part 'mini_player/mini_player_overlay_state.dart';

/// Compact media-player overlay with transport controls.
///
/// Receives track info from the main app via [FloatyOverlay.onData]
/// and sends play/pause/next/prev actions back.
final class MiniPlayerOverlay extends StatefulWidget {
  /// Creates the mini player overlay.
  const factory MiniPlayerOverlay({Key? key}) = MiniPlayerOverlay._;

  const MiniPlayerOverlay._({super.key});

  @override
  State<MiniPlayerOverlay> createState() => _MiniPlayerOverlayState();
}
