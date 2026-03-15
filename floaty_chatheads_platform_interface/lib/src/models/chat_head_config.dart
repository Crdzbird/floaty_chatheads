import 'package:floaty_chatheads_platform_interface/src/models/chat_head_assets.dart';
import 'package:floaty_chatheads_platform_interface/src/models/chat_head_theme.dart';
import 'package:floaty_chatheads_platform_interface/src/models/content_size_preset.dart';
import 'package:floaty_chatheads_platform_interface/src/models/entrance_animation.dart';
import 'package:floaty_chatheads_platform_interface/src/models/notification_config.dart';
import 'package:floaty_chatheads_platform_interface/src/models/notification_visibility.dart';
import 'package:floaty_chatheads_platform_interface/src/models/overlay_flag.dart';
import 'package:floaty_chatheads_platform_interface/src/models/snap_config.dart';
import 'package:floaty_chatheads_platform_interface/src/models/snap_edge.dart';

/// {@template chat_head_config}
/// Configuration for showing a floating chathead.
///
/// Encapsulates every option needed by `FloatyChatheadsPlatform.showChatHead`,
/// including the overlay entry point, content panel dimensions, native assets,
/// theming, size presets, and debug mode.
///
/// ## Grouped parameters
///
/// Related parameters can be passed individually **or** via config objects:
///
/// - [assets] / [ChatHeadAssets] — groups icon and close-button asset paths.
/// - [notification] / [NotificationConfig] — groups notification title, icon,
///   and visibility.
/// - [snap] / [SnapConfig] — groups snap edge, margin, and position
///   persistence.
///
/// When a grouped config is provided **and** the corresponding individual
/// parameter is also set, the grouped config takes precedence. Use the
/// `effective*` getters to resolve the final value.
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
    this.assets,
    this.notification,
    this.snap,
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
  ///
  /// Prefer using [assets] instead for grouped configuration.
  /// {@endtemplate}
  final String? chatheadIconAsset;

  /// {@template chat_head_config.close_icon_asset}
  /// Flutter asset path for the close-button icon (Android).
  ///
  /// Prefer using [assets] instead for grouped configuration.
  /// {@endtemplate}
  final String? closeIconAsset;

  /// {@template chat_head_config.close_background_asset}
  /// Flutter asset path for the close-button background (Android).
  ///
  /// Prefer using [assets] instead for grouped configuration.
  /// {@endtemplate}
  final String? closeBackgroundAsset;

  /// {@template chat_head_config.notification_title}
  /// Title shown in the foreground-service notification (Android).
  ///
  /// Prefer using [notification] instead for grouped configuration.
  /// {@endtemplate}
  final String? notificationTitle;

  /// {@template chat_head_config.notification_icon_asset}
  /// Flutter asset path for the notification icon (Android).
  ///
  /// Prefer using [notification] instead for grouped configuration.
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
  /// Prefer using [notification] instead for grouped configuration.
  ///
  /// Defaults to [NotificationVisibility.visibilityPublic].
  /// {@endtemplate}
  final NotificationVisibility notificationVisibility;

  /// {@template chat_head_config.snap_edge}
  /// Which screen edge(s) the chathead snaps to after being released.
  ///
  /// Prefer using [snap] instead for grouped configuration.
  ///
  /// Defaults to [SnapEdge.both].
  /// {@endtemplate}
  final SnapEdge snapEdge;

  /// {@template chat_head_config.snap_margin}
  /// Margin (in dp) from the screen edge when snapped.
  ///
  /// Prefer using [snap] instead for grouped configuration.
  ///
  /// Negative values mean the bubble overlaps the edge (partially hidden).
  /// Defaults to `-10` (matching the classic chathead look).
  /// {@endtemplate}
  final double snapMargin;

  /// {@template chat_head_config.persist_position}
  /// Whether to save and restore the chathead position across sessions.
  ///
  /// Prefer using [snap] instead for grouped configuration.
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

  // ── Grouped config objects ────────────────────────────────────────

  /// {@template chat_head_config.assets}
  /// Grouped asset paths for the chathead bubble, close icon, and
  /// close background.
  ///
  /// When provided, takes precedence over the individual
  /// [chatheadIconAsset], [closeIconAsset], and [closeBackgroundAsset]
  /// parameters.
  ///
  /// Use [ChatHeadAssets.defaults] for convention-based file names.
  /// {@endtemplate}
  final ChatHeadAssets? assets;

  /// {@template chat_head_config.notification}
  /// Grouped notification configuration.
  ///
  /// When provided, takes precedence over the individual
  /// [notificationTitle], [notificationIconAsset], and
  /// [notificationVisibility] parameters.
  /// {@endtemplate}
  final NotificationConfig? notification;

  /// {@template chat_head_config.snap}
  /// Grouped snap-behavior configuration.
  ///
  /// When provided, takes precedence over the individual
  /// [snapEdge], [snapMargin], and [persistPosition] parameters.
  /// {@endtemplate}
  final SnapConfig? snap;

  // ── Effective getters (grouped → individual fallback) ─────────────

  /// Resolved chathead icon asset: [assets] → [chatheadIconAsset].
  String? get effectiveChatheadIcon => assets?.icon ?? chatheadIconAsset;

  /// Resolved close icon asset: [assets] → [closeIconAsset].
  String? get effectiveCloseIcon => assets?.closeIcon ?? closeIconAsset;

  /// Resolved close background asset: [assets] → [closeBackgroundAsset].
  String? get effectiveCloseBackground =>
      assets?.closeBackground ?? closeBackgroundAsset;

  /// Resolved notification title: [notification] → [notificationTitle].
  String? get effectiveNotificationTitle =>
      notification?.title ?? notificationTitle;

  /// Resolved notification icon: [notification] → [notificationIconAsset].
  String? get effectiveNotificationIcon =>
      notification?.iconAsset ?? notificationIconAsset;

  /// Resolved notification visibility: [notification] →
  /// [notificationVisibility].
  NotificationVisibility get effectiveNotificationVisibility =>
      notification?.visibility ?? notificationVisibility;

  /// Resolved snap edge: [snap] → [snapEdge].
  SnapEdge get effectiveSnapEdge => snap?.edge ?? snapEdge;

  /// Resolved snap margin: [snap] → [snapMargin].
  double get effectiveSnapMargin => snap?.margin ?? snapMargin;

  /// Resolved persist position: [snap] → [persistPosition].
  bool get effectivePersistPosition =>
      snap?.persistPosition ?? persistPosition;
}
