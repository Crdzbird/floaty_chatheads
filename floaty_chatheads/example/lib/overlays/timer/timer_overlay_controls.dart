import 'package:flutter/material.dart';

import 'timer_overlay_button.dart';

/// Row of start or pause, reset and lap buttons in the stopwatch overlay.
final class TimerOverlayControls extends StatelessWidget {
  /// Creates the controls for the given [isRunning] state.
  const factory TimerOverlayControls({
    required bool isRunning,
    required VoidCallback onToggle,
    required VoidCallback onReset,
    required VoidCallback onLap,
    Key? key,
  }) = TimerOverlayControls._;

  const TimerOverlayControls._({
    required this.isRunning,
    required this.onToggle,
    required this.onReset,
    required this.onLap,
    super.key,
  });

  /// Whether the stopwatch is running.
  final bool isRunning;

  /// Called by the start or pause button.
  final VoidCallback onToggle;

  /// Called by the reset button.
  final VoidCallback onReset;

  /// Called by the lap button.
  final VoidCallback onLap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TimerOverlayButton(
          icon: isRunning ? Icons.pause : Icons.play_arrow,
          onTap: onToggle,
        ),
        const SizedBox(width: 8),
        TimerOverlayButton(icon: Icons.stop, onTap: onReset),
        const SizedBox(width: 8),
        TimerOverlayButton(icon: Icons.flag, onTap: onLap),
      ],
    );
  }
}
