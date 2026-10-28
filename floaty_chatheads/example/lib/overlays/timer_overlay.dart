import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'timer/timer_overlay_close_link.dart';
import 'timer/timer_overlay_controls.dart';
import 'timer/timer_overlay_format.dart';
import 'timer/timer_overlay_laps.dart';

part 'timer/timer_overlay_logic.dart';
part 'timer/timer_overlay_state.dart';

/// Stopwatch overlay with start, pause and reset controls.
///
/// Streams elapsed time to the main app once per second. Tapping the
/// chathead toggles start and pause.
final class TimerOverlay extends StatefulWidget {
  /// Creates the stopwatch overlay.
  const factory TimerOverlay({Key? key}) = TimerOverlay._;

  const TimerOverlay._({super.key});

  @override
  State<TimerOverlay> createState() => _TimerOverlayState();
}
