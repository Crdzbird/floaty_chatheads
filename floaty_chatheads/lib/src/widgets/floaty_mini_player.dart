import 'package:flutter/material.dart';

/// {@template floaty_mini_player}
/// A pre-built mini player overlay widget for music/video playback.
///
/// Drop this into your overlay entry point for an instant media player UI:
///
/// ```dart
/// @pragma('vm:entry-point')
/// void playerOverlay() => FloatyOverlayApp.run(
///   FloatyMiniPlayer(
///     title: 'Now Playing',
///     subtitle: 'Artist Name',
///     isPlaying: true,
///     onPlayPause: () => FloatyOverlay.shareData({'action': 'togglePlay'}),
///     onNext: () => FloatyOverlay.shareData({'action': 'next'}),
///     onPrevious: () => FloatyOverlay.shareData({'action': 'previous'}),
///     onClose: FloatyOverlay.closeOverlay,
///   ),
/// );
/// ```
/// {@endtemplate}
class FloatyMiniPlayer extends StatelessWidget {
  /// {@macro floaty_mini_player}
  const FloatyMiniPlayer({
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

  /// {@template floaty_mini_player.title}
  /// The track title displayed in the player.
  /// {@endtemplate}
  final String title;

  /// {@template floaty_mini_player.subtitle}
  /// The artist or album name (secondary text).
  /// {@endtemplate}
  final String? subtitle;

  /// {@template floaty_mini_player.album_art}
  /// Optional album artwork widget (e.g. an [Image]).
  /// {@endtemplate}
  final Widget? albumArt;

  /// {@template floaty_mini_player.is_playing}
  /// Whether the player is currently playing.
  /// {@endtemplate}
  final bool isPlaying;

  /// {@template floaty_mini_player.progress}
  /// Playback progress from 0.0 to 1.0.
  /// {@endtemplate}
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

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? const Color(0xFF1E1E2E);
    final fg = foregroundColor ?? Colors.white;
    final accent = accentColor ?? const Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button.
            Padding(
              padding: const EdgeInsets.only(right: 4, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onClose != null)
                    IconButton(
                      icon: Icon(Icons.close, color: fg.withValues(alpha: 0.6)),
                      iconSize: 18,
                      onPressed: onClose,
                      tooltip: 'Close player',
                    ),
                ],
              ),
            ),
            // Album art + track info.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (albumArt != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(width: 48, height: 48, child: albumArt),
                    )
                  else
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.2),
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
                          title,
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
                            subtitle!,
                            style: TextStyle(
                              color: fg.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  backgroundColor: fg.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(accent),
                  minHeight: 3,
                ),
              ),
            ),
            // Controls.
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous_rounded, color: fg),
                    onPressed: onPrevious,
                    tooltip: 'Previous',
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                      onPressed: onPlayPause,
                      tooltip: isPlaying ? 'Pause' : 'Play',
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.skip_next_rounded, color: fg),
                    onPressed: onNext,
                    tooltip: 'Next',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
