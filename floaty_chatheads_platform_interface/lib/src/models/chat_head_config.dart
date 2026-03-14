import 'package:floaty_chatheads_platform_interface/src/models/chat_head_theme.dart';
import 'package:floaty_chatheads_platform_interface/src/models/content_size_preset.dart';
import 'package:floaty_chatheads_platform_interface/src/models/entrance_animation.dart';
import 'package:floaty_chatheads_platform_interface/src/models/notification_visibility.dart';
import 'package:floaty_chatheads_platform_interface/src/models/overlay_flag.dart';
import 'package:floaty_chatheads_platform_interface/src/models/snap_edge.dart';

/// {@template chat_head_config}
/// Configuration for showing a floating chathead.
///
/// Encapsulates every option needed by `FloatyChatheadsPlatform.showChatHead`,
/// including the overlay entry point, content panel dimensions, native assets,
/// theming, size presets, and debug mode.
/// {@endtemplate}
class ChatHeadConfig {
  /// {@macro chat_head_config}
  const ChatHeadConfig({
    this.entryPoint = 'overlayMain',
    this.contentWidth,
    this.contentHeight,
    this.chatheadIconAsset,
    this.closeIconAsset,
    this.closeBackgroundAsset,
    this.notificationTitle,
    this.notificationIconAsset,
    this.flag = OverlayFlag.defaultFlag,
    this.enableDrag = true,
    this.notificationVisibility = NotificationVisibility.visibilityPublic,
    this.snapEdge = SnapEdge.both,
    this.snapMargin = -10,
    this.persistPosition = false,
    this.entranceAnimation = EntranceAnimation.none,
    this.theme,
    this.sizePreset,
    this.debugMode = false,
  });

  /// {@template chat_head_config.entry_point}
  /// Name of the Dart function annotated with
  /// `@pragma("vm:entry-point")` that runs in the overlay isolate.
  ///
  /// Defaults to `"overlayMain"`.
  /// {@endtemplate}
  final String entryPoint;

  /// {@template chat_head_config.content_width}
  /// Width of the content panel in logical pixels.
  /// {@endtemplate}
  final int? contentWidth;

  /// {@template chat_head_config.content_height}
  /// Height of the content panel in logical pixels.
  /// {@endtemplate}
  final int? contentHeight;

  /// {@template chat_head_config.chathead_icon_asset}
  /// Flutter asset path for the chathead bubble icon (Android).
  /// {@endtemplate}
  final String? chatheadIconAsset;

  /// {@template chat_head_config.close_icon_asset}
  /// Flutter asset path for the close-button icon (Android).
  /// {@endtemplate}
  final String? closeIconAsset;

  /// {@template chat_head_config.close_background_asset}
  /// Flutter asset path for the close-button background (Android).
  /// {@endtemplate}
  final String? closeBackgroundAsset;

  /// {@template chat_head_config.notification_title}
  /// Title shown in the foreground-service notification (Android).
  /// {@endtemplate}
  final String? notificationTitle;

  /// {@template chat_head_config.notification_icon_asset}
  /// Flutter asset path for the notification icon (Android).
  /// {@endtemplate}
  final String? notificationIconAsset;

  /// {@template chat_head_config.flag}
  /// Window behavior flag.
  ///
  /// See [OverlayFlag] for available values.
  /// {@endtemplate}
  final OverlayFlag flag;

  /// {@template chat_head_config.enable_drag}
  /// Whether the chathead bubble can be dragged.
  ///
  /// Defaults to `true`.
  /// {@endtemplate}
  final bool enableDrag;

  /// {@template chat_head_config.notification_visibility}
  /// Notification visibility on the lock screen (Android).
  ///
  /// Defaults to [NotificationVisibility.visibilityPublic].
  /// {@endtemplate}
  final NotificationVisibility notificationVisibility;

  /// {@template chat_head_config.snap_edge}
  /// Which screen edge(s) the chathead snaps to after being released.
  ///
  /// Defaults to [SnapEdge.both].
  /// {@endtemplate}
  final SnapEdge snapEdge;

  /// {@template chat_head_config.snap_margin}
  /// Margin (in dp) from the screen edge when snapped.
  ///
  /// Negative values mean the bubble overlaps the edge (partially hidden).
  /// Defaults to `-10` (matching the classic chathead look).
  /// {@endtemplate}
  final double snapMargin;

  /// {@template chat_head_config.persist_position}
  /// Whether to save and restore the chathead position across sessions.
  ///
  /// Defaults to `false`.
  /// {@endtemplate}
  final bool persistPosition;

  /// {@template chat_head_config.entrance_animation}
  /// The entrance animation when the chathead first appears.
  ///
  /// Defaults to [EntranceAnimation.none].
  /// {@endtemplate}
  final EntranceAnimation entranceAnimation;

  /// {@template chat_head_config.theme}
  /// Optional theme configuration for badge colors, bubble border,
  /// shadow color, close tint, and overlay palette.
  ///
  /// See [ChatHeadTheme] for details.
  /// {@endtemplate}
  final ChatHeadTheme? theme;

  /// {@template chat_head_config.size_preset}
  /// Named size preset for the content panel.
  ///
  /// When set, overrides [contentWidth] and [contentHeight] with the
  /// preset's values. See [ContentSizePreset] for available options.
  /// {@endtemplate}
  final ContentSizePreset? sizePreset;

  /// {@template chat_head_config.debug_mode}
  /// Whether to enable the debug overlay inspector.
  ///
  /// When `true`, a transparent debug view is drawn on top of the overlay
  /// showing bounds, spring state, FPS, and Pigeon message log.
  /// Defaults to `false`.
  /// {@endtemplate}
  final bool debugMode;
}
