import 'package:flutter/material.dart';

part 'mini_player/mini_player_card.dart';
part 'mini_player/mini_player_controls.dart';
part 'mini_player/mini_player_header.dart';
part 'mini_player/mini_player_progress.dart';
part 'mini_player/mini_player_track.dart';

/// A pre-built mini player overlay for music or video playback, with
/// track info, a progress bar and previous, play/pause and next buttons.
///
/// ```dart
/// FloatyOverlayApp.run(
///   FloatyMiniPlayer(title: 'Now Playing', isPlaying: true, onClose: close),
/// );
/// ```
final class FloatyMiniPlayer extends StatelessWidget {
  /// Creates a mini player showing [title].
  const factory FloatyMiniPlayer({
    required String title,
    Key? key,
    String? subtitle,
    Widget? albumArt,
    bool isPlaying,
    double progress,
    VoidCallback? onPlayPause,
    VoidCallback? onNext,
    VoidCallback? onPrevious,
    VoidCallback? onClose,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? accentColor,
  }) = FloatyMiniPlayer._;

  const FloatyMiniPlayer._({
    required this.title,
    super.key,
    this.subtitle,
    this.albumArt,
    this.isPlaying = false,
    this.progress = 0,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.onClose,
    this.backgroundColor,
    this.foregroundColor,
    this.accentColor,
  });

  /// The track title displayed in the player.
  final String title;

  /// The artist or album name (secondary text).
  final String? subtitle;

  /// Optional album artwork widget (e.g. an [Image]).
  final Widget? albumArt;

  /// Whether the player is currently playing.
  final bool isPlaying;

  /// Playback progress from 0.0 to 1.0.
  final double progress;

  /// Called when play/pause is tapped.
  final VoidCallback? onPlayPause;

  /// Called when next is tapped.
  final VoidCallback? onNext;

  /// Called when previous is tapped.
  final VoidCallback? onPrevious;

  /// Called when the close button is tapped.
  final VoidCallback? onClose;

  /// Background color of the player card.
  final Color? backgroundColor;

  /// Color for text and icons.
  final Color? foregroundColor;

  /// Accent color for the progress bar and play button.
  final Color? accentColor;

  Color get _foreground => foregroundColor ?? Colors.white;

  Color get _accent => accentColor ?? const Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: _MiniPlayerCard(this),
  );
}
