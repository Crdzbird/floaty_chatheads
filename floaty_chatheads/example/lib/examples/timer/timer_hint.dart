import 'package:flutter/material.dart';

/// Grey hint explaining that the timer runs inside the overlay.
final class TimerHint extends StatelessWidget {
  /// Creates the hint text.
  const factory TimerHint({Key? key}) = TimerHint._;

  const TimerHint._({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'The timer runs inside the overlay.\n'
        'Use these buttons to control it remotely,\n'
        'or tap the chathead bubble to toggle.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      ),
    );
  }
}
