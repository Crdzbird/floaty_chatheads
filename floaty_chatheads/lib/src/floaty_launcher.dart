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
///   chatheadIconAsset: 'assets/icon.png',
/// );
///
/// // After (1 call):
/// await FloatyLauncher.show(
///   entryPoint: 'overlayMain',
///   chatheadIcon: 'assets/icon.png',
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
  /// The most common ones are promoted to short-named top-level parameters;
  /// Android-specific options are grouped under their original names.
  /// {@endtemplate}
  static Future<bool> show({
    String entryPoint = 'overlayMain',
    String? chatheadIcon,
    String? closeIcon,
    String? closeBackground,
    String? notificationTitle,
    String? notificationIcon,
    int? contentWidth,
    int? contentHeight,
    ContentSizePreset? sizePreset,
    ChatHeadTheme? theme,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    bool enableDrag = true,
    SnapEdge snapEdge = SnapEdge.both,
    double snapMargin = -10,
    bool persistPosition = false,
    EntranceAnimation entranceAnimation = EntranceAnimation.none,
    NotificationVisibility notificationVisibility =
        NotificationVisibility.visibilityPublic,
    bool debugMode = false,
  }) async {
    var granted = await FloatyChatheads.checkPermission();
    if (!granted) {
      granted = await FloatyChatheads.requestPermission();
      if (!granted) return false;
    }

    await FloatyChatheads.showChatHead(
      entryPoint: entryPoint,
      chatheadIconAsset: chatheadIcon,
      closeIconAsset: closeIcon,
      closeBackgroundAsset: closeBackground,
      notificationTitle: notificationTitle,
      notificationIconAsset: notificationIcon,
      contentWidth: contentWidth,
      contentHeight: contentHeight,
      sizePreset: sizePreset,
      theme: theme,
      flag: flag,
      enableDrag: enableDrag,
      snapEdge: snapEdge,
      snapMargin: snapMargin,
      persistPosition: persistPosition,
      entranceAnimation: entranceAnimation,
      notificationVisibility: notificationVisibility,
      debugMode: debugMode,
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
    String? chatheadIcon,
    String? closeIcon,
    String? closeBackground,
    String? notificationTitle,
    String? notificationIcon,
    int? contentWidth,
    int? contentHeight,
    ContentSizePreset? sizePreset,
    ChatHeadTheme? theme,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    bool enableDrag = true,
    SnapEdge snapEdge = SnapEdge.both,
    double snapMargin = -10,
    bool persistPosition = false,
    EntranceAnimation entranceAnimation = EntranceAnimation.none,
    NotificationVisibility notificationVisibility =
        NotificationVisibility.visibilityPublic,
    bool debugMode = false,
  }) async {
    final active = await FloatyChatheads.isActive();
    if (active) {
      await FloatyChatheads.closeChatHead();
      return false;
    }
    return show(
      entryPoint: entryPoint,
      chatheadIcon: chatheadIcon,
      closeIcon: closeIcon,
      closeBackground: closeBackground,
      notificationTitle: notificationTitle,
      notificationIcon: notificationIcon,
      contentWidth: contentWidth,
      contentHeight: contentHeight,
      sizePreset: sizePreset,
      theme: theme,
      flag: flag,
      enableDrag: enableDrag,
      snapEdge: snapEdge,
      snapMargin: snapMargin,
      persistPosition: persistPosition,
      entranceAnimation: entranceAnimation,
      notificationVisibility: notificationVisibility,
      debugMode: debugMode,
    );
  }
}
