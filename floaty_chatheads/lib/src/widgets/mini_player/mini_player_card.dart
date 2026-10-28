part of '../floaty_mini_player.dart';

final class _MiniPlayerCard extends StatelessWidget {
  const _MiniPlayerCard(this.player);

  final FloatyMiniPlayer player;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: player.backgroundColor ?? const Color(0xFF1E1E2E),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(77),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MiniPlayerHeader(player),
        _MiniPlayerTrack(player),
        _MiniPlayerProgress(player),
        _MiniPlayerControls(player),
      ],
    ),
  );
}
