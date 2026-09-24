import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/widgets.dart';

/// {@template floaty}
/// The one-stop API for showing and talking to a chathead.
///
/// `Floaty` handles the overlay permission (check, request, await the
/// user's answer) and then shows the chathead with every option the
/// plugin supports. The two-line integration:
///
/// ```dart
/// // Overlay isolate entry point (any top-level function; the default
/// // name is `overlayMain`).
/// @pragma('vm:entry-point')
/// void overlayMain() => FloatyOverlayApp.run(
///   const FloatySimplePanel(
///     title: 'Hello',
///     child: Text('I am a floating overlay.'),
///   ),
/// );
///
/// // Anywhere in your app.
/// ElevatedButton(
///   onPressed: Floaty.show,
///   child: const Text('Show Chathead'),
/// );
/// ```
///
/// No asset bundling, no manifest edits, no `ChatHeadConfig`. On Android
/// the bubble uses a built-in default icon; on iOS the overlay is
/// rendered entirely by your Flutter widget.
///
/// Every option is a named parameter on [show] and [toggle] — panel size
/// and anchor, theming, snapping, widget or animated icons, notification
/// text, background auto-launch, survival after app death. Use
/// [FloatyChatheads] only when you need to skip the permission flow
/// entirely.
///
/// For typed two-way messaging with state, see [FloatyHostKit] /
/// [FloatyOverlayKit]; for raw data, [send] and [onData].
/// {@endtemplate}
final class Floaty {
  Floaty._(); // coverage:ignore-line

  /// {@template floaty.ensure_permission}
  /// Returns `true` when the overlay permission is granted, requesting
  /// it from the user first if needed. Always `true` on iOS.
  /// {@endtemplate}
  static Future<bool> ensurePermission() async {
    if (await FloatyChatheads.checkPermission()) return true;
    return await FloatyChatheads.requestPermission();
  }

  /// {@template floaty.show}
  /// Checks the overlay permission (Android), requests it if needed,
  /// then shows the chathead.
  ///
  /// Returns `true` if the chathead is now visible, `false` if the
  /// user denied permission.
  ///
  /// [entryPointLibrary] lets the entry point live outside `main.dart`
  /// (`'package:my_app/overlay.dart'`).
  /// [size] picks a named panel size; pass [contentWidth] /
  /// [contentHeight] instead for exact logical-pixel dimensions.
  /// [title] is shorthand for `notification: NotificationConfig(title:)`
  /// and is ignored when [notification] is given.
  ///
  /// Icon priority: [iconBuilder] > [iconWidget] > [assets] > built-in
  /// defaults. See [FloatyChatheads.showChatHead] for the icon options.
  /// {@endtemplate}
  static Future<bool> show({
    String entryPoint = 'overlayMain',
    String? entryPointLibrary,
    String? title,
    ContentSizePreset? size = ContentSizePreset.card,
    int? contentWidth,
    int? contentHeight,
    PanelAnchor panelAnchor = PanelAnchor.below,
    EntranceAnimation entranceAnimation = EntranceAnimation.none,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    bool enableDrag = true,
    ChatHeadTheme? theme,
    SnapConfig? snap,
    ChatHeadAssets? assets,
    NotificationConfig? notification,
    bool autoLaunchOnBackground = false,
    bool persistOnAppClose = false,
    bool debugMode = false,
    Widget? iconWidget,
    AnimatedIconBuilder? iconBuilder,
    Widget? closeIconWidget,
    Widget? closeBackgroundWidget,
    bool animateIcon = false,
    int iconAnimationFps = 24,
    double iconSize = 80,
    double iconPixelRatio = 3,
    Duration iconAnimationDuration = const Duration(seconds: 1),
  }) async {
    if (!await ensurePermission()) return false;

    final explicitSize = contentWidth != null || contentHeight != null;
    await FloatyChatheads.showChatHead(
      entryPoint: entryPoint,
      entryPointLibrary: entryPointLibrary,
      contentWidth: contentWidth,
      contentHeight: contentHeight,
      sizePreset: explicitSize ? null : size,
      panelAnchor: panelAnchor,
      entranceAnimation: entranceAnimation,
      flag: flag,
      enableDrag: enableDrag,
      theme: theme,
      snap: snap,
      assets: assets,
      notification: notification ??
          (title != null ? NotificationConfig(title: title) : null),
      autoLaunchOnBackground: autoLaunchOnBackground,
      persistOnAppClose: persistOnAppClose,
      debugMode: debugMode,
      iconWidget: iconWidget,
      iconBuilder: iconBuilder,
      closeIconWidget: closeIconWidget,
      closeBackgroundWidget: closeBackgroundWidget,
      animateIcon: animateIcon,
      iconAnimationFps: iconAnimationFps,
      iconSize: iconSize,
      iconPixelRatio: iconPixelRatio,
      iconAnimationDuration: iconAnimationDuration,
    );
    return true;
  }

  /// {@template floaty.toggle}
  /// Shows the chathead if it is closed; closes it if it is open.
  ///
  /// Returns `true` when the chathead ends up visible, `false` when
  /// closed (or when permission was denied). Takes the same options as
  /// [show].
  /// {@endtemplate}
  static Future<bool> toggle({
    String entryPoint = 'overlayMain',
    String? entryPointLibrary,
    String? title,
    ContentSizePreset? size = ContentSizePreset.card,
    int? contentWidth,
    int? contentHeight,
    PanelAnchor panelAnchor = PanelAnchor.below,
    EntranceAnimation entranceAnimation = EntranceAnimation.none,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    bool enableDrag = true,
    ChatHeadTheme? theme,
    SnapConfig? snap,
    ChatHeadAssets? assets,
    NotificationConfig? notification,
    bool autoLaunchOnBackground = false,
    bool persistOnAppClose = false,
    bool debugMode = false,
    Widget? iconWidget,
    AnimatedIconBuilder? iconBuilder,
    Widget? closeIconWidget,
    Widget? closeBackgroundWidget,
    bool animateIcon = false,
    int iconAnimationFps = 24,
    double iconSize = 80,
    double iconPixelRatio = 3,
    Duration iconAnimationDuration = const Duration(seconds: 1),
  }) async {
    if (await FloatyChatheads.isActive()) {
      await FloatyChatheads.closeChatHead();
      return false;
    }
    return await show(
      entryPoint: entryPoint,
      entryPointLibrary: entryPointLibrary,
      title: title,
      size: size,
      contentWidth: contentWidth,
      contentHeight: contentHeight,
      panelAnchor: panelAnchor,
      entranceAnimation: entranceAnimation,
      flag: flag,
      enableDrag: enableDrag,
      theme: theme,
      snap: snap,
      assets: assets,
      notification: notification,
      autoLaunchOnBackground: autoLaunchOnBackground,
      persistOnAppClose: persistOnAppClose,
      debugMode: debugMode,
      iconWidget: iconWidget,
      iconBuilder: iconBuilder,
      closeIconWidget: closeIconWidget,
      closeBackgroundWidget: closeBackgroundWidget,
      animateIcon: animateIcon,
      iconAnimationFps: iconAnimationFps,
      iconSize: iconSize,
      iconPixelRatio: iconPixelRatio,
      iconAnimationDuration: iconAnimationDuration,
    );
  }

  /// {@template floaty.close}
  /// Closes the chathead. No-op if already closed.
  /// {@endtemplate}
  static Future<void> close() => FloatyChatheads.closeChatHead();

  /// {@template floaty.is_active}
  /// Whether the chathead is currently visible.
  /// {@endtemplate}
  static Future<bool> isActive() => FloatyChatheads.isActive();

  /// {@macro floaty_chatheads_platform.expand_chat_head}
  static Future<void> expand() => FloatyChatheads.expandChatHead();

  /// {@macro floaty_chatheads_platform.collapse_chat_head}
  static Future<void> collapse() => FloatyChatheads.collapseChatHead();

  /// {@macro floaty_chatheads_platform.update_badge}
  static Future<void> updateBadge(int count) =>
      FloatyChatheads.updateBadge(count);

  /// {@template floaty.send}
  /// Sends raw data to the overlay isolate.
  ///
  /// For typed bidirectional messaging with state and actions, use
  /// [FloatyHostKit] instead.
  /// {@endtemplate}
  static Future<void> send(Object? data) => FloatyChatheads.shareData(data);

  /// {@template floaty.on_data}
  /// Stream of raw data received from the overlay.
  ///
  /// For typed messaging, see [FloatyHostKit] and [FloatyMessenger].
  /// {@endtemplate}
  static Stream<Object?> get onData => FloatyChatheads.onData;

  /// {@macro floaty_chatheads.on_closed}
  static Stream<String> get onClosed => FloatyChatheads.onClosed;
}
