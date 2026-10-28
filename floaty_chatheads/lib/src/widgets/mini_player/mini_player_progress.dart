part of '../floaty_mini_player.dart';

final class _MiniPlayerProgress extends StatelessWidget {
  const _MiniPlayerProgress(this.player);

  final FloatyMiniPlayer player;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: player.progress.clamp(0, 1),
        backgroundColor: player._foreground.withAlpha(26),
        valueColor: AlwaysStoppedAnimation(player._accent),
        minHeight: 3,
      ),
    ),
  );
}
