import 'package:flutter/material.dart';

import 'timer_overlay_format.dart';

/// Divider followed by a short scrollable list of recorded laps.
final class TimerOverlayLaps extends StatelessWidget {
  /// Creates the lap list for [laps].
  const factory TimerOverlayLaps({required List<Duration> laps, Key? key}) =
      TimerOverlayLaps._;

  const TimerOverlayLaps._({required this.laps, super.key});

  /// Recorded lap times, oldest first.
  final List<Duration> laps;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        const Divider(color: Colors.white24, height: 1),
        const SizedBox(height: 2),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 40),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: laps.length,
            itemBuilder: (_, i) => Text(
              'Lap ${i + 1}: ${formatTimerOverlay(laps[i])}',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
