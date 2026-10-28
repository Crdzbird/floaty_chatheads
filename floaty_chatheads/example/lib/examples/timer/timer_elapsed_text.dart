import 'package:flutter/material.dart';

/// Large mm:ss readout of the elapsed time synced from the overlay.
final class TimerElapsedText extends StatelessWidget {
  /// Creates the readout for [elapsedMs] milliseconds.
  const factory TimerElapsedText({required int elapsedMs, Key? key}) =
      TimerElapsedText._;

  const TimerElapsedText._({required this.elapsedMs, super.key});

  /// Elapsed time in milliseconds.
  final int elapsedMs;

  @override
  Widget build(BuildContext context) {
    final d = Duration(milliseconds: elapsedMs);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Text(
      '$m:$s',
      style: const TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.w300,
        fontFamily: 'monospace',
      ),
    );
  }
}
