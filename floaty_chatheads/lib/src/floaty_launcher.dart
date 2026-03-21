import 'package:floaty_chatheads/src/floaty_chatheads.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// {@template floaty_launcher}
/// One-call launcher that handles permission checks and shows the chathead.
///
/// Eliminates the common boilerplate of checking permissions, requesting
/// them, and then calling [FloatyChatheads.showChatHead]:
///
/// ```dart
/// // Before (5 lines):
/// final granted = await FloatyChatheads.checkPermission();
/// if (!granted) {
///   final ok = await FloatyChatheads.requestPermission();
///   if (!ok) return;
/// }
/// await FloatyChatheads.showChatHead(
///   entryPoint: 'overlayMain',
///   assets: ChatHeadAssets.defaults(),
/// );
///
/// // After (1 call):
/// await FloatyLauncher.show(
///   entryPoint: 'overlayMain',
///   assets: ChatHeadAssets.defaults(),
/// );
/// ```
///
/// Returns `true` if the chathead was shown, `false` if the user denied
/// the permission.
/// {@endtemplate}
final class FloatyLauncher {
  FloatyLauncher._(); // coverage:ignore-line

  /// {@template floaty_launcher.show}
  /// Checks permission, requests it if needed, and shows the chathead.
  ///
  /// Returns `true` if the chathead was launched successfully, `false` if
  /// the permission was denied.
  ///
  /// All parameters map directly to [FloatyChatheads.showChatHead].
  /// Use grouped config objects ([assets], [notification], [snap]) to
  /// configure platform-specific options.
  /// {@endtemplate}
  static Future<bool> show({
    String entryPoint = 'overlayMain',
    int? contentWidth,
    int? contentHeight,
    ContentSizePreset? sizePreset,
    ChatHeadTheme? theme,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    bool enableDrag = true,
    EntranceAnimation entranceAnimation = EntranceAnimation.none,
    bool debugMode = false,
    ChatHeadAssets? assets,
    NotificationConfig? notification,
    SnapConfig? snap,
  }) async {
    var granted = await FloatyChatheads.checkPermission();
    if (!granted) {
      granted = await FloatyChatheads.requestPermission();
      if (!granted) return false;
    }

    await FloatyChatheads.showChatHead(
      entryPoint: entryPoint,
      contentWidth: contentWidth,
      contentHeight: contentHeight,
      sizePreset: sizePreset,
      theme: theme,
      flag: flag,
      enableDrag: enableDrag,
      entranceAnimation: entranceAnimation,
      debugMode: debugMode,
      assets: assets,
      notification: notification,
      snap: snap,
    );

    return true;
  }

  /// {@template floaty_launcher.toggle}
  /// Toggles the chathead: shows it if inactive, closes it if active.
  ///
  /// Returns `true` if the chathead is now visible, `false` otherwise.
  /// Uses the same parameters as [show].
  /// {@endtemplate}
  static Future<bool> toggle({
    String entryPoint = 'overlayMain',
    int? contentWidth,
    int? contentHeight,
    ContentSizePreset? sizePreset,
    ChatHeadTheme? theme,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    bool enableDrag = true,
    EntranceAnimation entranceAnimation = EntranceAnimation.none,
    bool debugMode = false,
    ChatHeadAssets? assets,
    NotificationConfig? notification,
    SnapConfig? snap,
  }) async {
    final active = await FloatyChatheads.isActive();
    if (active) {
      await FloatyChatheads.closeChatHead();
      return false;
    }
    return show(
      entryPoint: entryPoint,
      contentWidth: contentWidth,
      contentHeight: contentHeight,
      sizePreset: sizePreset,
      theme: theme,
      flag: flag,
      enableDrag: enableDrag,
      entranceAnimation: entranceAnimation,
      debugMode: debugMode,
      assets: assets,
      notification: notification,
      snap: snap,
    );
  }
}
