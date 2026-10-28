part of '../floaty_mini_player.dart';

final class _MiniPlayerControls extends StatelessWidget {
  const _MiniPlayerControls(this.player);

  final FloatyMiniPlayer player;

  @override
  Widget build(BuildContext context) {
    final fg = player._foreground;
    final playing = player.isPlaying;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.skip_previous_rounded, color: fg),
            onPressed: player.onPrevious,
            tooltip: 'Previous',
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: player._accent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
              ),
              onPressed: player.onPlayPause,
              tooltip: playing ? 'Pause' : 'Play',
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.skip_next_rounded, color: fg),
            onPressed: player.onNext,
            tooltip: 'Next',
          ),
        ],
      ),
    );
  }
}
