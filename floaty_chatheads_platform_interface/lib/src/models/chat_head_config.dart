import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/foundation.dart' show immutable, listEquals;

part 'chat_head_config_groups.dart';
part 'chat_head_config_props.dart';

/// {@template chat_head_config}
/// Configuration for showing a floating chathead.
///
/// Holds every option needed by `FloatyChatheadsPlatform.showChatHead`.
/// {@endtemplate}
@immutable
final class ChatHeadConfig extends _ChatHeadConfigGroups {
  /// {@macro chat_head_config}
  const factory ChatHeadConfig({
    String entryPoint,
    String? entryPointLibrary,
    int? contentWidth,
    int? contentHeight,
    OverlayFlag flag,
    bool enableDrag,
    EntranceAnimation entranceAnimation,
    PanelAnchor panelAnchor,
    ChatHeadTheme? theme,
    ContentSizePreset? sizePreset,
    bool debugMode,
    bool autoLaunchOnBackground,
    bool persistOnAppClose,
    ChatHeadAssets? assets,
    NotificationConfig? notification,
    SnapConfig? snap,
    Duration readyTimeout,
  }) = ChatHeadConfig._;

  const ChatHeadConfig._({
    this.entryPoint = 'overlayMain',
    this.entryPointLibrary,
    this.contentWidth,
    this.contentHeight,
    this.flag = OverlayFlag.defaultFlag,
    this.enableDrag = true,
    this.entranceAnimation = EntranceAnimation.none,
    this.panelAnchor = PanelAnchor.below,
    super.theme,
    super.sizePreset,
    this.debugMode = false,
    this.autoLaunchOnBackground = false,
    this.persistOnAppClose = false,
    super.assets,
    super.notification,
    super.snap,
    this.readyTimeout = const Duration(seconds: 10),
  });

  /// Name of the `vm:entry-point` function run in the overlay isolate.
  final String entryPoint;

  /// Library URI defining [entryPoint], or `null` for the root library.
  final String? entryPointLibrary;

  /// Width of the content panel in logical pixels.
  final int? contentWidth;

  /// Height of the content panel in logical pixels.
  final int? contentHeight;

  /// Window behavior flag. See [OverlayFlag] for available values.
  final OverlayFlag flag;

  /// Whether the chathead bubble can be dragged. Defaults to `true`.
  final bool enableDrag;

  /// The entrance animation when the chathead first appears.
  final EntranceAnimation entranceAnimation;

  /// Where the expanded content panel opens relative to the bubble.
  final PanelAnchor panelAnchor;

  /// Whether to draw the debug overlay inspector on top of the overlay.
  final bool debugMode;

  /// Whether the chathead appears while the app is in the background.
  final bool autoLaunchOnBackground;

  /// Whether the overlay survives after the main app process is killed.
  final bool persistOnAppClose;

  /// How long `showChatHead` waits for the overlay; zero skips the check.
  final Duration readyTimeout;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatHeadConfig && listEquals(other._props, _props);

  @override
  int get hashCode => Object.hashAll(_props);
}
