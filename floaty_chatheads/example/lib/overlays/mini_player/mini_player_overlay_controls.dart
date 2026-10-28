import 'package:flutter/material.dart';

import 'mini_player_control_button.dart';

/// Previous, play/pause and next buttons of the mini player overlay.
final class MiniPlayerOverlayControls extends StatelessWidget {
  /// Creates the controls; [onAction] receives `prev`, `toggle` or `next`.
  const factory MiniPlayerOverlayControls({
    required bool isPlaying,
    required ValueChanged<String> onAction,
    Key? key,
  }) = MiniPlayerOverlayControls._;

  const MiniPlayerOverlayControls._({
    required this.isPlaying,
    required this.onAction,
    super.key,
  });

  /// Whether the track is playing; picks the play or pause icon.
  final bool isPlaying;

  /// Called with the action name of the tapped button.
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MiniPlayerControlButton(
          icon: Icons.skip_previous,
          onTap: () => onAction('prev'),
        ),
        const SizedBox(width: 14),
        MiniPlayerControlButton(
          icon: isPlaying
              ? Icons.pause_circle_filled
              : Icons.play_circle_filled,
          size: 32,
          onTap: () => onAction('toggle'),
        ),
        const SizedBox(width: 14),
        MiniPlayerControlButton(
          icon: Icons.skip_next,
          onTap: () => onAction('next'),
        ),
      ],
    );
  }
}
