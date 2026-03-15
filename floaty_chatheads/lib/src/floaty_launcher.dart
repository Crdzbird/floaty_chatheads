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
  /// The most common ones are promoted to short-named top-level parameters;
  /// Android-specific options are grouped under their original names.
  ///
  /// Prefer grouped config objects ([assets], [notification], [snap]) over
  /// their individual counterparts — the flat parameters are deprecated and
  /// will be removed in the next major version.
  /// {@endtemplate}
  static Future<bool> show({
    String entryPoint = 'overlayMain',
    @Deprecated('Use assets instead') String? chatheadIcon,
    @Deprecated('Use assets instead') String? closeIcon,
    @Deprecated('Use assets instead') String? closeBackground,
    @Deprecated('Use notification instead') String? notificationTitle,
    @Deprecated('Use notification instead') String? notificationIcon,
    int? contentWidth,
    int? contentHeight,
    ContentSizePreset? sizePreset,
    ChatHeadTheme? theme,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    bool enableDrag = true,
    @Deprecated('Use snap instead') SnapEdge snapEdge = SnapEdge.both,
    @Deprecated('Use snap instead') double snapMargin = -10,
    @Deprecated('Use snap instead') bool persistPosition = false,
    EntranceAnimation entranceAnimation = EntranceAnimation.none,
    @Deprecated('Use notification instead')
    NotificationVisibility notificationVisibility =
        NotificationVisibility.visibilityPublic,
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
      // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
      chatheadIconAsset: chatheadIcon,
      // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
      closeIconAsset: closeIcon,
      // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
      closeBackgroundAsset: closeBackground,
      // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
      notificationTitle: notificationTitle,
      // ignore: deprecated_member_use_from_same_package, forwards deprecated param for backward compat.
      notificationIconAsset: notificationIcon,
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
    @Deprecated('Use assets instead') String? chatheadIcon,
    @Deprecated('Use assets instead') String? closeIcon,
    @Deprecated('Use assets instead') String? closeBackground,
    @Deprecated('Use notification instead') String? notificationTitle,
    @Deprecated('Use notification instead') String? notificationIcon,
    int? contentWidth,
    int? contentHeight,
    ContentSizePreset? sizePreset,
    ChatHeadTheme? theme,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    bool enableDrag = true,
    @Deprecated('Use snap instead') SnapEdge snapEdge = SnapEdge.both,
    @Deprecated('Use snap instead') double snapMargin = -10,
    @Deprecated('Use snap instead') bool persistPosition = false,
    EntranceAnimation entranceAnimation = EntranceAnimation.none,
    @Deprecated('Use notification instead')
    NotificationVisibility notificationVisibility =
        NotificationVisibility.visibilityPublic,
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
  }
}
