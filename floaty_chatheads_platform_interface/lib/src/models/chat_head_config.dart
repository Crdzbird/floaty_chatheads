import 'package:floaty_chatheads_platform_interface/src/models/chat_head_assets.dart';
import 'package:floaty_chatheads_platform_interface/src/models/chat_head_theme.dart';
import 'package:floaty_chatheads_platform_interface/src/models/content_size_preset.dart';
import 'package:floaty_chatheads_platform_interface/src/models/entrance_animation.dart';
import 'package:floaty_chatheads_platform_interface/src/models/notification_config.dart';
import 'package:floaty_chatheads_platform_interface/src/models/overlay_flag.dart';
import 'package:floaty_chatheads_platform_interface/src/models/snap_config.dart';
import 'package:meta/meta.dart';

/// {@template chat_head_config}
/// Configuration for showing a floating chathead.
///
/// Encapsulates every option needed by `FloatyChatheadsPlatform.showChatHead`,
/// including the overlay entry point, content panel dimensions, native assets,
/// theming, size presets, and debug mode.
///
/// ## Grouped parameters
///
/// Related parameters are passed via config objects:
///
/// - [assets] / [ChatHeadAssets] — groups icon and close-button asset paths.
/// - [notification] / [NotificationConfig] — groups notification title, icon,
///   and visibility.
/// - [snap] / [SnapConfig] — groups snap edge, margin, and position
///   persistence.
/// {@endtemplate}
@immutable
class ChatHeadConfig {
  /// {@macro chat_head_config}
  const ChatHeadConfig({
    this.entryPoint = 'overlayMain',
    this.contentWidth,
    this.contentHeight,
    this.flag = OverlayFlag.defaultFlag,
    this.enableDrag = true,
    this.entranceAnimation = EntranceAnimation.none,
    this.theme,
    this.sizePreset,
    this.debugMode = false,
    this.autoLaunchOnBackground = false,
    this.persistOnAppClose = false,
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

  /// {@template chat_head_config.auto_launch_on_background}
  /// Whether the chathead automatically appears when the app goes to the
  /// background.
  ///
  /// When `true`, the chathead is shown as soon as all activities leave the
  /// foreground. It is automatically closed when the app returns to the
  /// foreground.
  /// Defaults to `false`.
  /// {@endtemplate}
  final bool autoLaunchOnBackground;

  /// {@template chat_head_config.persist_on_app_close}
  /// Whether the chathead overlay survives after the main app process is
  /// killed.
  ///
  /// When `true`, the foreground service uses `START_STICKY` and persists
  /// its configuration so the overlay is recreated automatically if the
  /// system restarts the service. When `false`, the service uses
  /// `START_NOT_STICKY` and stops itself when the main app disconnects.
  /// Defaults to `false`.
  /// {@endtemplate}
  final bool persistOnAppClose;

  // ── Grouped config objects ────────────────────────────────────────

  /// {@template chat_head_config.assets}
  /// Grouped asset paths for the chathead bubble, close icon, and
  /// close background.
  ///
  /// Use [ChatHeadAssets.defaults] for convention-based file names.
  /// {@endtemplate}
  final ChatHeadAssets? assets;

  /// {@template chat_head_config.notification}
  /// Grouped notification configuration (title, description, icon,
  /// and lock-screen visibility).
  /// {@endtemplate}
  final NotificationConfig? notification;

  /// {@template chat_head_config.snap}
  /// Grouped snap-behavior configuration (edge, margin, and position
  /// persistence).
  /// {@endtemplate}
  final SnapConfig? snap;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatHeadConfig &&
          other.entryPoint == entryPoint &&
          other.contentWidth == contentWidth &&
          other.contentHeight == contentHeight &&
          other.flag == flag &&
          other.enableDrag == enableDrag &&
          other.entranceAnimation == entranceAnimation &&
          other.theme == theme &&
          other.sizePreset == sizePreset &&
          other.debugMode == debugMode &&
          other.autoLaunchOnBackground == autoLaunchOnBackground &&
          other.persistOnAppClose == persistOnAppClose &&
          other.assets == assets &&
          other.notification == notification &&
          other.snap == snap;

  @override
  int get hashCode => Object.hashAll([
        entryPoint,
        contentWidth,
        contentHeight,
        flag,
        enableDrag,
        entranceAnimation,
        theme,
        sizePreset,
        debugMode,
        autoLaunchOnBackground,
        persistOnAppClose,
        assets,
        notification,
        snap,
      ]);
}
