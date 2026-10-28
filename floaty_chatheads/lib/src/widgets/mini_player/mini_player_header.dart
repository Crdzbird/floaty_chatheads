part of '../floaty_mini_player.dart';

final class _MiniPlayerHeader extends StatelessWidget {
  const _MiniPlayerHeader(this.player);

  final FloatyMiniPlayer player;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 4, top: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (player.onClose != null)
          IconButton(
            icon: Icon(Icons.close, color: player._foreground.withAlpha(153)),
            iconSize: 18,
            onPressed: player.onClose,
            tooltip: 'Close player',
          ),
      ],
    ),
  );
}
