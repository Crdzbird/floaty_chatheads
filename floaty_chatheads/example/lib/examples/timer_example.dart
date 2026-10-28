import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'timer/timer_elapsed_text.dart';
import 'timer/timer_hint.dart';
import 'timer/timer_remote_controls.dart';
import 'timer/timer_status_pill.dart';

part 'timer/timer_example_state.dart';

/// Timer example: the stopwatch runs inside the overlay, and the main app
/// displays the synced elapsed time and remote controls.
final class TimerExample extends StatefulWidget {
  /// Creates the timer example page.
  const factory TimerExample({Key? key}) = TimerExample._;

  const TimerExample._({super.key});

  @override
  State<TimerExample> createState() => _TimerExampleState();
}
