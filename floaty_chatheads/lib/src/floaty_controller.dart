import 'dart:async';

import 'package:floaty_chatheads/src/floaty_chatheads.dart';
import 'package:floaty_chatheads/src/floaty_launcher.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

/// {@template floaty_controller}
/// A lifecycle-aware controller that manages the chathead declaratively.
///
/// Attach it to a widget's lifecycle so the chathead shows when the
/// widget mounts and closes when it unmounts — no manual imperative
/// calls needed:
///
/// ```dart
/// class _MyPageState extends State<MyPage> {
///   late final FloatyController _controller;
///
///   @override
///   void initState() {
///     super.initState();
///     _controller = FloatyController(
///       entryPoint: 'overlayMain',
///       assets: ChatHeadAssets.defaults(),
///       sizePreset: ContentSizePreset.card,
///       autoShow: true,
///     );
///   }
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) => ...;
/// }
/// ```
///
/// Or use [FloatyControllerWidget] for a fully declarative approach
/// without managing the controller yourself.
/// {@endtemplate}
final class FloatyController extends ChangeNotifier {
  /// {@macro floaty_controller}
  FloatyController({
    this.entryPoint = 'overlayMain',
    @Deprecated('Use assets instead') this.chatheadIcon,
    @Deprecated('Use assets instead') this.closeIcon,
    @Deprecated('Use assets instead') this.closeBackground,
    @Deprecated('Use notification instead') this.notificationTitle,
    @Deprecated('Use notification instead') this.notificationIcon,
    this.contentWidth,
    this.contentHeight,
    this.sizePreset,
    this.theme,
    this.flag = OverlayFlag.defaultFlag,
    this.enableDrag = true,
    @Deprecated('Use snap instead') this.snapEdge = SnapEdge.both,
    @Deprecated('Use snap instead') this.snapMargin = -10,
    @Deprecated('Use snap instead') this.persistPosition = false,
    this.entranceAnimation = EntranceAnimation.none,
    @Deprecated('Use notification instead')
    this.notificationVisibility = NotificationVisibility.visibilityPublic,
    this.debugMode = false,
    bool autoShow = false,
    this.onData,
    this.onError,
    this.assets,
    this.notification,
    this.snap,
  }) {
    if (autoShow) {
      unawaited(show());
    }
  }

  /// {@template floaty_controller.entry_point}
  /// Dart entry-point function for the overlay isolate.
  /// {@endtemplate}
  final String entryPoint;

  /// {@template floaty_controller.chathead_icon}
  /// Flutter asset path for the bubble icon (Android).
  ///
  /// Deprecated: use [assets] instead.
  /// {@endtemplate}
  @Deprecated('Use assets instead')
  final String? chatheadIcon;

  /// {@template floaty_controller.close_icon}
  /// Flutter asset path for the close icon (Android).
  ///
  /// Deprecated: use [assets] instead.
  /// {@endtemplate}
  @Deprecated('Use assets instead')
  final String? closeIcon;

  /// {@template floaty_controller.close_background}
  /// Flutter asset path for the close background (Android).
  ///
  /// Deprecated: use [assets] instead.
  /// {@endtemplate}
  @Deprecated('Use assets instead')
  final String? closeBackground;

  /// {@template floaty_controller.notification_title}
  /// Foreground-service notification title (Android).
  ///
  /// Deprecated: use [notification] instead.
  /// {@endtemplate}
  @Deprecated('Use notification instead')
  final String? notificationTitle;

  /// {@template floaty_controller.notification_icon}
  /// Flutter asset path for the notification icon (Android).
  ///
  /// Deprecated: use [notification] instead.
  /// {@endtemplate}
  @Deprecated('Use notification instead')
  final String? notificationIcon;

  /// {@template floaty_controller.content_width}
  /// Content panel width in dp/pt.
  /// {@endtemplate}
  final int? contentWidth;

  /// {@template floaty_controller.content_height}
  /// Content panel height in dp/pt.
  /// {@endtemplate}
  final int? contentHeight;

  /// {@template floaty_controller.size_preset}
  /// Named size preset (overrides width/height).
  /// {@endtemplate}
  final ContentSizePreset? sizePreset;

  /// {@template floaty_controller.theme}
  /// Theming configuration (Android).
  /// {@endtemplate}
  final ChatHeadTheme? theme;

  /// {@template floaty_controller.flag}
  /// Window behavior flag.
  /// {@endtemplate}
  final OverlayFlag flag;

  /// {@template floaty_controller.enable_drag}
  /// Whether the bubble is draggable.
  /// {@endtemplate}
  final bool enableDrag;

  /// {@template floaty_controller.snap_edge}
  /// Edge snapping mode (Android).
  ///
  /// Deprecated: use [snap] instead.
  /// {@endtemplate}
  @Deprecated('Use snap instead')
  final SnapEdge snapEdge;

  /// {@template floaty_controller.snap_margin}
  /// Margin from screen edge when snapped (Android).
  ///
  /// Deprecated: use [snap] instead.
  /// {@endtemplate}
  @Deprecated('Use snap instead')
  final double snapMargin;

  /// {@template floaty_controller.persist_position}
  /// Whether to restore position across sessions (Android).
  ///
  /// Deprecated: use [snap] instead.
  /// {@endtemplate}
  @Deprecated('Use snap instead')
  final bool persistPosition;

  /// {@template floaty_controller.entrance_animation}
  /// Entry animation variant (Android).
  /// {@endtemplate}
  final EntranceAnimation entranceAnimation;

  /// {@template floaty_controller.notification_visibility}
  /// Lock-screen visibility (Android).
  ///
  /// Deprecated: use [notification] instead.
  /// {@endtemplate}
  @Deprecated('Use notification instead')
  final NotificationVisibility notificationVisibility;

  /// {@template floaty_controller.debug_mode}
  /// Whether the native debug inspector is enabled (Android).
  /// {@endtemplate}
  final bool debugMode;

  /// Grouped asset configuration.
  ///
  /// When provided, takes precedence over the individual icon asset
  /// parameters (which are deprecated).
  final ChatHeadAssets? assets;

  /// Grouped notification configuration.
  ///
  /// When provided, takes precedence over the individual notification
  /// parameters (which are deprecated).
  final NotificationConfig? notification;

  /// Grouped snap-behavior configuration.
  ///
  /// When provided, takes precedence over the individual snap
  /// parameters (which are deprecated).
  final SnapConfig? snap;

  /// {@template floaty_controller.on_data}
  /// Callback invoked when data arrives from the overlay.
  /// {@endtemplate}
  final void Function(Object? data)? onData;

  /// {@template floaty_controller.on_error}
  /// Callback invoked when an error occurs during show/close.
  /// {@endtemplate}
  final void Function(Object error, StackTrace stack)? onError;

  bool _isActive = false;
  StreamSubscription<Object?>? _dataSub;

  /// Whether the chathead is currently visible.
  bool get isActive => _isActive;

  /// Shows the chathead. Handles permission automatically.
  ///
  /// Returns `true` if the chathead was shown, `false` if permission
  /// was denied.
  Future<bool> show() async {
    try {
      final shown = await FloatyLauncher.show(
        entryPoint: entryPoint,
        // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
        chatheadIcon: chatheadIcon,
        // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
        closeIcon: closeIcon,
        // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
        closeBackground: closeBackground,
        // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
        notificationTitle: notificationTitle,
        // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
        notificationIcon: notificationIcon,
        contentWidth: contentWidth,
        contentHeight: contentHeight,
        sizePreset: sizePreset,
        theme: theme,
        flag: flag,
        enableDrag: enableDrag,
        // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
        snapEdge: snapEdge,
        // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
        snapMargin: snapMargin,
        // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
        persistPosition: persistPosition,
        entranceAnimation: entranceAnimation,
        // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
        notificationVisibility: notificationVisibility,
        debugMode: debugMode,
        assets: assets,
        notification: notification,
        snap: snap,
      );
      _isActive = shown;
      if (shown && onData != null) {
        _dataSub ??= FloatyChatheads.onData.listen(onData);
      }
      notifyListeners();
      return shown;
    } on Object catch (e, st) {
      onError?.call(e, st);
      return false;
    }
  }

  /// Closes the chathead.
  Future<void> close() async {
    try {
      await FloatyChatheads.closeChatHead();
      _isActive = false;
      notifyListeners();
    } on Object catch (e, st) {
      onError?.call(e, st);
    }
  }

  /// Toggles the chathead: shows if hidden, closes if visible.
  Future<bool> toggle() async {
    if (_isActive) {
      await close();
      return false;
    }
    return show();
  }

  /// Sends data to the overlay isolate.
  Future<void> sendData(Object? data) => FloatyChatheads.shareData(data);

  @override
  void dispose() {
    unawaited(_dataSub?.cancel());
    _dataSub = null;
    FloatyChatheads.dispose();
    super.dispose();
  }
}

/// {@template floaty_controller_widget}
/// A declarative widget that shows the chathead when mounted and
/// closes it when unmounted.
///
/// ```dart
/// FloatyControllerWidget(
///   entryPoint: 'overlayMain',
///   assets: ChatHeadAssets.defaults(),
///   sizePreset: ContentSizePreset.card,
///   child: MyPageContent(),
/// )
/// ```
///
/// Access the underlying [FloatyController] via [FloatyControllerWidget.of].
/// {@endtemplate}
final class FloatyControllerWidget extends StatefulWidget {
  /// {@macro floaty_controller_widget}
  const FloatyControllerWidget({
    required this.child,
    super.key,
    this.entryPoint = 'overlayMain',
    @Deprecated('Use assets instead') this.chatheadIcon,
    @Deprecated('Use assets instead') this.closeIcon,
    @Deprecated('Use assets instead') this.closeBackground,
    @Deprecated('Use notification instead') this.notificationTitle,
    this.sizePreset,
    this.theme,
    this.debugMode = false,
    this.onData,
    this.assets,
    this.notification,
    this.snap,
  });

  /// The widget to render while the chathead is active.
  final Widget child;

  /// Dart entry-point function name for the overlay.
  final String entryPoint;

  /// Flutter asset path for the bubble icon (Android).
  ///
  /// Deprecated: use [assets] instead.
  @Deprecated('Use assets instead')
  final String? chatheadIcon;

  /// Flutter asset path for the close icon (Android).
  ///
  /// Deprecated: use [assets] instead.
  @Deprecated('Use assets instead')
  final String? closeIcon;

  /// Flutter asset path for the close background (Android).
  ///
  /// Deprecated: use [assets] instead.
  @Deprecated('Use assets instead')
  final String? closeBackground;

  /// Foreground-service notification title (Android).
  ///
  /// Deprecated: use [notification] instead.
  @Deprecated('Use notification instead')
  final String? notificationTitle;

  /// Named size preset.
  final ContentSizePreset? sizePreset;

  /// Theming configuration.
  final ChatHeadTheme? theme;

  /// Whether to enable the native debug inspector.
  final bool debugMode;

  /// Callback when data arrives from the overlay.
  final void Function(Object? data)? onData;

  /// Grouped asset configuration.
  final ChatHeadAssets? assets;

  /// Grouped notification configuration.
  final NotificationConfig? notification;

  /// Grouped snap-behavior configuration.
  final SnapConfig? snap;

  /// Returns the nearest [FloatyController] above [context], or `null`.
  static FloatyController? of(BuildContext context) {
    return context
        .findAncestorStateOfType<_FloatyControllerWidgetState>()
        ?._controller;
  }

  @override
  State<FloatyControllerWidget> createState() =>
      _FloatyControllerWidgetState();
}

final class _FloatyControllerWidgetState
    extends State<FloatyControllerWidget> {
  late FloatyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FloatyController(
      entryPoint: widget.entryPoint,
      // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
      chatheadIcon: widget.chatheadIcon,
      // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
      closeIcon: widget.closeIcon,
      // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
      closeBackground: widget.closeBackground,
      // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
      notificationTitle: widget.notificationTitle,
      sizePreset: widget.sizePreset,
      theme: widget.theme,
      debugMode: widget.debugMode,
      onData: widget.onData,
      autoShow: true,
      assets: widget.assets,
      notification: widget.notification,
      snap: widget.snap,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
