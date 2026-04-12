import 'dart:async';
import 'dart:typed_data';

import 'package:floaty_chatheads/src/animated_widget_icon.dart';
import 'package:floaty_chatheads/src/floaty_channel.dart';
import 'package:floaty_chatheads/src/widget_to_icon_source.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

/// {@template floaty_chatheads}
/// Main app API for controlling the floating chathead.
///
/// Use this from the main app isolate to show/close the chathead
/// and exchange data with the overlay. All methods are static.
///
/// ```dart
/// // Image-based icon (existing)
/// await FloatyChatheads.showChatHead(
///   entryPoint: 'overlayMain',
///   assets: ChatHeadAssets.defaults(),
/// );
///
/// // Widget-based icon — any widget, one line
/// await FloatyChatheads.showChatHead(
///   entryPoint: 'overlayMain',
///   iconWidget: const CircleAvatar(child: Text('JD')),
/// );
///
/// // Animated widget icon with widget close icons
/// await FloatyChatheads.showChatHead(
///   entryPoint: 'overlayMain',
///   iconBuilder: (v) => RotatingWidget(progress: v),
///   animateIcon: true,
///   closeIconWidget: const Icon(Icons.close, color: Colors.white),
///   closeBackgroundWidget: const CircleAvatar(backgroundColor: Colors.red),
/// );
/// ```
/// {@endtemplate}
final class FloatyChatheads {
  FloatyChatheads._(); // coverage:ignore-line

  static FloatyChatheadsPlatform get _platform =>
      FloatyChatheadsPlatform.instance;

  static const _closedPrefixKey = '_floaty_closed';
  static final StreamController<String> _closeController =
      StreamController<String>.broadcast();
  static bool _closedHandlerRegistered = false;

  // ── Icon animation state ────────────────────────────────────────
  static AnimatedWidgetIcon? _activeIconAnimation;

  /// Whether an animated icon render loop is currently running.
  static bool get isIconAnimating =>
      _activeIconAnimation?.isRunning ?? false;

  /// Stops the current icon animation if one is running.
  ///
  /// The icon stays on the last rendered frame. The controller is
  /// retained so [startIconAnimation] can resume the animation.
  static void stopIconAnimation() {
    _activeIconAnimation?.stop();
  }

  /// Starts the icon animation that was configured via [showChatHead].
  ///
  /// No-op if no animated builder was provided, or if the animation
  /// is already running.
  static void startIconAnimation() {
    _activeIconAnimation?.start();
  }

  /// Stops and fully releases the active icon animation controller.
  static void _disposeIconAnimation() {
    _activeIconAnimation?.dispose();
    _activeIconAnimation = null;
  }

  static void _ensureClosedHandler() {
    if (!_closedHandlerRegistered) {
      FloatyChannel.registerHandler(_closedPrefixKey, (data) {
        final id = data['id'] as String? ?? 'default';
        // Only dispose the animation when the closed bubble is the one
        // that owns the active animation (avoids killing the animation
        // when a secondary non-animated bubble is closed).
        if (_activeIconAnimation?.id == id) {
          _disposeIconAnimation();
        }
        _closeController.add(id);
      });
      _closedHandlerRegistered = true;
    }
  }

  /// {@template floaty_chatheads.on_closed}
  /// Stream that emits the chathead ID when the overlay is closed
  /// by the native gesture (drag-to-close) or from the overlay itself.
  ///
  /// Use this to update your UI state when the chathead is dismissed
  /// without the main app explicitly calling [closeChatHead].
  /// {@endtemplate}
  static Stream<String> get onClosed {
    _ensureClosedHandler();
    FloatyChannel.ensureListening();
    return _closeController.stream;
  }

  /// {@template floaty_chatheads.on_data}
  /// Stream of messages sent from the overlay isolate.
  ///
  /// Attaches the message handler lazily on first access.
  /// {@endtemplate}
  static Stream<Object?> get onData => FloatyChannel.rawMessages;

  /// {@macro floaty_chatheads_platform.check_permission}
  static Future<bool> checkPermission() => _platform.checkPermission();

  /// {@macro floaty_chatheads_platform.request_permission}
  static Future<bool> requestPermission() => _platform.requestPermission();

  /// {@macro floaty_chatheads_platform.show_chat_head}
  ///
  /// ## Widget-based icons
  ///
  /// Pass [iconWidget] to use any Flutter widget as the chathead bubble
  /// (rendered to an image automatically):
  ///
  /// ```dart
  /// await FloatyChatheads.showChatHead(
  ///   entryPoint: 'overlayMain',
  ///   iconWidget: const CircleAvatar(child: Text('JD')),
  /// );
  /// ```
  ///
  /// For animated icons, pass [iconBuilder] instead (receives a
  /// normalised 0.0–1.0 animation value) and set [animateIcon] to
  /// `true`:
  ///
  /// ```dart
  /// await FloatyChatheads.showChatHead(
  ///   entryPoint: 'overlayMain',
  ///   iconBuilder: (v) => Transform.rotate(
  ///     angle: v * 2 * 3.14159,
  ///     child: const Icon(Icons.sync, size: 50),
  ///   ),
  ///   animateIcon: true,
  /// );
  /// ```
  ///
  /// The close icon and close background can also be widgets via
  /// [closeIconWidget] and [closeBackgroundWidget].
  ///
  /// Use [animateIcon] to start/pause the animation. You can also
  /// toggle it later via [startIconAnimation] / [stopIconAnimation].
  ///
  /// Priority: [iconBuilder] > [iconWidget] > [assets] > defaults.
  static Future<void> showChatHead({
    String entryPoint = 'overlayMain',
    int? contentWidth,
    int? contentHeight,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    bool enableDrag = true,
    EntranceAnimation entranceAnimation = EntranceAnimation.none,
    ChatHeadTheme? theme,
    ContentSizePreset? sizePreset,
    bool debugMode = false,
    bool autoLaunchOnBackground = false,
    bool persistOnAppClose = false,
    ChatHeadAssets? assets,
    NotificationConfig? notification,
    SnapConfig? snap,
    Widget? iconWidget,
    AnimatedIconBuilder? iconBuilder,
    Widget? closeIconWidget,
    Widget? closeBackgroundWidget,
    bool animateIcon = false,
    int iconAnimationFps = 24,
    double iconSize = 80,
    double iconPixelRatio = 3.0,
    Duration iconAnimationDuration = const Duration(seconds: 1),
  }) async {
    // Dispose any previous animation.
    _disposeIconAnimation();

    // Resolve widget-based icons into IconSource.bytes.
    final effectiveAssets = await _resolveAssets(
      assets: assets,
      iconWidget: iconWidget,
      iconBuilder: iconBuilder,
      closeIconWidget: closeIconWidget,
      closeBackgroundWidget: closeBackgroundWidget,
      iconSize: iconSize,
      iconPixelRatio: iconPixelRatio,
      iconAnimationFps: iconAnimationFps,
      iconAnimationDuration: iconAnimationDuration,
    );

    await _platform.showChatHead(
      ChatHeadConfig(
        entryPoint: entryPoint,
        contentWidth: contentWidth,
        contentHeight: contentHeight,
        flag: flag,
        enableDrag: enableDrag,
        entranceAnimation: entranceAnimation,
        theme: theme,
        sizePreset: sizePreset,
        debugMode: debugMode,
        autoLaunchOnBackground: autoLaunchOnBackground,
        persistOnAppClose: persistOnAppClose,
        assets: effectiveAssets,
        notification: notification,
        snap: snap,
      ),
    );

    // Start animation after the chathead is visible.
    if (animateIcon && _activeIconAnimation != null) {
      _activeIconAnimation!.start();
    }
  }

  /// {@macro floaty_chatheads_platform.close_chat_head}
  static Future<void> closeChatHead() {
    _disposeIconAnimation();
    return _platform.closeChatHead();
  }

  /// {@macro floaty_chatheads_platform.is_active}
  static Future<bool> isActive() => _platform.isActive();

  /// {@macro floaty_chatheads_platform.add_chat_head}
  ///
  /// [id] uniquely identifies this bubble. Pass either [iconSource]
  /// (asset/network/bytes) or [iconWidget] (any Flutter widget).
  ///
  /// [iconWidget] is rendered to an image automatically at [iconSize]
  /// logical pixels.
  static Future<void> addChatHead({
    required String id,
    IconSource? iconSource,
    Widget? iconWidget,
    double iconSize = 80,
    double iconPixelRatio = 3.0,
  }) async {
    var effectiveSource = iconSource;
    if (iconWidget != null && effectiveSource == null) {
      effectiveSource = await widgetToIconSource(
        iconWidget,
        size: iconSize,
        pixelRatio: iconPixelRatio,
      );
    }
    return _platform.addChatHead(
      AddChatHeadConfig(id: id, iconSource: effectiveSource),
    );
  }

  /// {@macro floaty_chatheads_platform.remove_chat_head}
  static Future<void> removeChatHead(String id) =>
      _platform.removeChatHead(id);

  /// {@macro floaty_chatheads_platform.update_badge}
  static Future<void> updateBadge(int count) => _platform.updateBadge(count);

  /// {@macro floaty_chatheads_platform.expand_chat_head}
  static Future<void> expandChatHead() => _platform.expandChatHead();

  /// {@macro floaty_chatheads_platform.collapse_chat_head}
  static Future<void> collapseChatHead() => _platform.collapseChatHead();

  /// {@macro floaty_chatheads_platform.update_chat_head_icon}
  static Future<void> updateChatHeadIcon({
    required Uint8List rgbaBytes,
    required int width,
    required int height,
    String id = 'default',
  }) =>
      _platform.updateChatHeadIcon(id, rgbaBytes, width, height);

  /// {@template floaty_chatheads.share_data}
  /// Sends data from the main app to the overlay isolate.
  ///
  /// The data is serialized via `JSONMessageCodec` and forwarded
  /// through a `BasicMessageChannel`.
  /// {@endtemplate}
  static Future<void> shareData(Object? data) => FloatyChannel.send(data);

  /// {@template floaty_chatheads.dispose}
  /// Detaches the message handler and stops any active icon animation.
  ///
  /// Safe to call multiple times. After calling, [onData] will
  /// re-attach the handler automatically on the next access.
  /// {@endtemplate}
  static void dispose() {
    _disposeIconAnimation();
    FloatyChannel.unregisterHandler(_closedPrefixKey);
    _closedHandlerRegistered = false;
    FloatyChannel.dispose();
  }

  // ── Private helpers ─────────────────────────────────────────────

  /// Resolves widget params into a [ChatHeadAssets], rendering widgets
  /// to bytes via the offscreen pipeline when provided.
  static Future<ChatHeadAssets?> _resolveAssets({
    required ChatHeadAssets? assets,
    required Widget? iconWidget,
    required AnimatedIconBuilder? iconBuilder,
    required Widget? closeIconWidget,
    required Widget? closeBackgroundWidget,
    required double iconSize,
    required double iconPixelRatio,
    required int iconAnimationFps,
    required Duration iconAnimationDuration,
  }) async {
    // Resolve the main chathead icon.
    IconSource? iconSource;
    if (iconBuilder != null) {
      final animated = AnimatedWidgetIcon(
        id: 'default',
        builder: iconBuilder,
        fps: iconAnimationFps,
        size: iconSize,
        pixelRatio: iconPixelRatio,
        duration: iconAnimationDuration,
      );
      await animated.init();
      iconSource = animated.initialFrame;
      _activeIconAnimation = animated;
    } else if (iconWidget != null) {
      iconSource = await widgetToIconSource(
        iconWidget,
        size: iconSize,
        pixelRatio: iconPixelRatio,
      );
    }

    // Resolve close icon widgets.
    IconSource? closeSource;
    if (closeIconWidget != null) {
      closeSource = await widgetToIconSource(
        closeIconWidget,
        size: iconSize,
        pixelRatio: iconPixelRatio,
      );
    }

    IconSource? closeBgSource;
    if (closeBackgroundWidget != null) {
      closeBgSource = await widgetToIconSource(
        closeBackgroundWidget,
        size: iconSize,
        pixelRatio: iconPixelRatio,
      );
    }

    // Nothing widget-based — return original assets.
    if (iconSource == null && closeSource == null && closeBgSource == null) {
      return assets;
    }

    // Build merged assets: widget sources override asset sources.
    return ChatHeadAssets(
      icon: iconSource ??
          assets?.icon ??
          const IconSource.asset('assets/chatheadIcon.png'),
      closeIcon: closeSource ??
          assets?.closeIcon ??
          const IconSource.asset('assets/close.png'),
      closeBackground: closeBgSource ??
          assets?.closeBackground ??
          const IconSource.asset('assets/closeBg.png'),
    );
  }
}
