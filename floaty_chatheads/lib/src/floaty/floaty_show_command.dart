import 'package:floaty_chatheads/src/animated_widget_icon.dart';
import 'package:floaty_chatheads/src/floaty_chatheads.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

/// Implementation of `Floaty.show` and `Floaty.ensurePermission`.
final class FloatyShowCommand {
  FloatyShowCommand._();

  /// Returns `true` when the overlay permission is granted, requesting it
  /// first if needed.
  static Future<bool> ensurePermission() async {
    if (await FloatyChatheads.checkPermission()) return true;
    return await FloatyChatheads.requestPermission();
  }

  /// Ensures the permission, then shows the chathead. Returns `false` when
  /// the permission was denied.
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
    Duration readyTimeout = const Duration(seconds: 10),
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
      notification:
          notification ??
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
      readyTimeout: readyTimeout,
    );
    return true;
  }
}
