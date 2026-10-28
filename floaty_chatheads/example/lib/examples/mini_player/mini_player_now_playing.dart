import 'package:flutter/material.dart';

/// Large play state icon with the current track title and artist.
final class MiniPlayerNowPlaying extends StatelessWidget {
  /// Creates the now playing block.
  const factory MiniPlayerNowPlaying({
    required String title,
    required String artist,
    required bool isPlaying,
    Key? key,
  }) = MiniPlayerNowPlaying._;

  const MiniPlayerNowPlaying._({
    required this.title,
    required this.artist,
    required this.isPlaying,
    super.key,
  });

  /// Title of the current track.
  final String title;

  /// Artist of the current track.
  final String artist;

  /// Whether the track is playing.
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          isPlaying ? Icons.pause_circle : Icons.play_circle,
          size: 80,
          color: Colors.deepPurple,
        ),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        Text(
          artist,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
