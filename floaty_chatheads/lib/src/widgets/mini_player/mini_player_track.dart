part of '../floaty_mini_player.dart';

final class _MiniPlayerTrack extends StatelessWidget {
  const _MiniPlayerTrack(this.player);

  final FloatyMiniPlayer player;

  @override
  Widget build(BuildContext context) {
    final fg = player._foreground;
    final accent = player._accent;
    final art = player.albumArt;
    final subtitle = player.subtitle;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (art != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(width: 48, height: 48, child: art),
            ),
          if (art == null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.music_note, color: accent),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.title,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(color: fg.withAlpha(153), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
