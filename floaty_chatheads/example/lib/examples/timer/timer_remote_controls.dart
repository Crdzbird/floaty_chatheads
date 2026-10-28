import 'package:flutter/material.dart';

/// Start or pause and reset buttons that remote control the overlay timer.
final class TimerRemoteControls extends StatelessWidget {
  /// Creates the controls for the given [isRunning] state.
  const factory TimerRemoteControls({
    required bool isRunning,
    required VoidCallback onToggle,
    required VoidCallback onReset,
    Key? key,
  }) = TimerRemoteControls._;

  const TimerRemoteControls._({
    required this.isRunning,
    required this.onToggle,
    required this.onReset,
    super.key,
  });

  /// Whether the stopwatch is running.
  final bool isRunning;

  /// Called when the start or pause button is pressed.
  final VoidCallback onToggle;

  /// Called when "Reset" is pressed.
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: onToggle,
          icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
          label: Text(isRunning ? 'Pause' : 'Start'),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.stop),
          label: const Text('Reset'),
        ),
      ],
    );
  }
}
