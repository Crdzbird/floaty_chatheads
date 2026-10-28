import 'package:flutter/material.dart';

/// Previous, play/pause and next buttons of the main app player.
final class MiniPlayerTransport extends StatelessWidget {
  /// Creates the transport row.
  const factory MiniPlayerTransport({
    required bool isPlaying,
    required VoidCallback onPrev,
    required VoidCallback onToggle,
    required VoidCallback onNext,
    Key? key,
  }) = MiniPlayerTransport._;

  const MiniPlayerTransport._({
    required this.isPlaying,
    required this.onPrev,
    required this.onToggle,
    required this.onNext,
    super.key,
  });

  /// Whether the track is playing; picks the play or pause icon.
  final bool isPlaying;

  /// Called when "previous" is pressed.
  final VoidCallback onPrev;

  /// Called when play/pause is pressed.
  final VoidCallback onToggle;

  /// Called when "next" is pressed.
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous, size: 36),
          onPressed: onPrev,
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: Icon(
            isPlaying ? Icons.pause_circle : Icons.play_circle,
            size: 48,
          ),
          onPressed: onToggle,
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.skip_next, size: 36),
          onPressed: onNext,
        ),
      ],
    );
  }
}
