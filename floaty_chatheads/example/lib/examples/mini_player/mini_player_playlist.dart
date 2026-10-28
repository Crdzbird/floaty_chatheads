import 'package:flutter/material.dart';

/// Tappable playlist that highlights the current track.
final class MiniPlayerPlaylist extends StatelessWidget {
  /// Creates the playlist for [tracks]; [onSelect] receives the index.
  const factory MiniPlayerPlaylist({
    required List<Map<String, String>> tracks,
    required int currentIndex,
    required bool isPlaying,
    required ValueChanged<int> onSelect,
    Key? key,
  }) = MiniPlayerPlaylist._;

  const MiniPlayerPlaylist._({
    required this.tracks,
    required this.currentIndex,
    required this.isPlaying,
    required this.onSelect,
    super.key,
  });

  /// Tracks with `title` and `artist` keys.
  final List<Map<String, String>> tracks;

  /// Index of the current track.
  final int currentIndex;

  /// Whether the current track is playing.
  final bool isPlaying;

  /// Called with the index of the tapped track.
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (_, i) {
        final track = tracks[i];
        final isCurrent = i == currentIndex;
        return ListTile(
          leading: Icon(
            isCurrent && isPlaying ? Icons.equalizer : Icons.music_note,
            color: isCurrent ? Colors.deepPurple : Colors.grey,
          ),
          title: Text(
            track['title']!,
            style: TextStyle(
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? Colors.deepPurple : null,
            ),
          ),
          subtitle: Text(track['artist']!),
          onTap: () => onSelect(i),
        );
      },
    );
  }
}
