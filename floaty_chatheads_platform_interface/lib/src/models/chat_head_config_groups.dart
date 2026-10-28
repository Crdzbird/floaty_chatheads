part of 'chat_head_config.dart';

/// Appearance and grouped options inherited by [ChatHeadConfig].
@immutable
abstract class _ChatHeadConfigGroups {
  const _ChatHeadConfigGroups({
    this.theme,
    this.sizePreset,
    this.assets,
    this.notification,
    this.snap,
  });

  /// Optional badge, border, shadow, close tint and overlay palette colors.
  final ChatHeadTheme? theme;

  /// Named panel size that overrides the raw content width and height.
  final ContentSizePreset? sizePreset;

  /// Icon sources for the bubble, close icon and close background.
  final ChatHeadAssets? assets;

  /// Foreground-service notification settings.
  final NotificationConfig? notification;

  /// Snap edge, margin and position persistence settings.
  final SnapConfig? snap;
}
