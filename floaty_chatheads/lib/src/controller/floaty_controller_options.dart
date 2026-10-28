part of '../floaty_controller.dart';

/// The configuration fields of [FloatyController].
abstract base class _FloatyControllerOptions extends ChangeNotifier {
  _FloatyControllerOptions({
    this.entryPoint = 'overlayMain',
    this.entryPointLibrary,
    this.contentWidth,
    this.contentHeight,
    this.sizePreset,
    this.theme,
    this.flag = OverlayFlag.defaultFlag,
    this.enableDrag = true,
    this.entranceAnimation = EntranceAnimation.none,
    this.panelAnchor = PanelAnchor.below,
    this.autoLaunchOnBackground = false,
    this.persistOnAppClose = false,
    this.debugMode = false,
    this.onData,
    this.onError,
    this.assets,
    this.notification,
    this.snap,
  });

  /// Dart entry-point function for the overlay isolate.
  final String entryPoint;

  /// {@macro chat_head_config.entry_point_library}
  final String? entryPointLibrary;

  /// Content panel width in dp/pt.
  final int? contentWidth;

  /// Content panel height in dp/pt.
  final int? contentHeight;

  /// Named size preset (overrides width/height).
  final ContentSizePreset? sizePreset;

  /// Theming configuration (Android).
  final ChatHeadTheme? theme;

  /// Window behavior flag.
  final OverlayFlag flag;

  /// Whether the bubble is draggable.
  final bool enableDrag;

  /// Entry animation variant (Android).
  final EntranceAnimation entranceAnimation;

  /// Where the expanded content panel opens relative to the bubble.
  final PanelAnchor panelAnchor;

  /// {@macro chat_head_config.auto_launch_on_background}
  final bool autoLaunchOnBackground;

  /// {@macro chat_head_config.persist_on_app_close}
  final bool persistOnAppClose;

  /// Whether the native debug inspector is enabled (Android).
  final bool debugMode;

  /// Grouped asset configuration.
  final ChatHeadAssets? assets;

  /// Grouped notification configuration.
  final NotificationConfig? notification;

  /// Grouped snap-behavior configuration.
  final SnapConfig? snap;

  /// Callback invoked when data arrives from the overlay.
  final void Function(Object? data)? onData;

  /// Callback invoked when an error occurs during show/close.
  final void Function(Object error, StackTrace stack)? onError;
}
