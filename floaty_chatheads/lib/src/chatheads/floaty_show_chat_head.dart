import 'package:floaty_chatheads/src/animated_widget_icon.dart';
import 'package:floaty_chatheads/src/chatheads/floaty_icon_animation.dart';
import 'package:floaty_chatheads/src/chatheads/floaty_icon_resolver.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

/// Implementation of `FloatyChatheads.showChatHead`.
final class FloatyShowChatHead {
  FloatyShowChatHead._();

  /// Resolves widget icons, shows the chathead, then starts the icon
  /// animation when [animateIcon] is set.
  static Future<void> show({
    String entryPoint = 'overlayMain',
    String? entryPointLibrary,
    int? contentWidth,
    int? contentHeight,
    OverlayFlag flag = OverlayFlag.defaultFlag,
    bool enableDrag = true,
    EntranceAnimation entranceAnimation = EntranceAnimation.none,
    PanelAnchor panelAnchor = PanelAnchor.below,
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
    Duration readyTimeout = const Duration(seconds: 10),
  }) async {
    final platform = FloatyChatheadsPlatform.instance;
    FloatyIconAnimation.dispose();
    final effectiveAssets = !platform.supportsNativeIcons
        ? assets
        : await FloatyIconResolver.resolve(
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
    await platform.showChatHead(
      ChatHeadConfig(
        entryPoint: entryPoint,
        entryPointLibrary: entryPointLibrary,
        contentWidth: contentWidth,
        contentHeight: contentHeight,
        flag: flag,
        enableDrag: enableDrag,
        entranceAnimation: entranceAnimation,
        panelAnchor: panelAnchor,
        theme: theme,
        sizePreset: sizePreset,
        debugMode: debugMode,
        autoLaunchOnBackground: autoLaunchOnBackground,
        persistOnAppClose: persistOnAppClose,
        assets: effectiveAssets,
        notification: notification,
        snap: snap,
        readyTimeout: readyTimeout,
      ),
    );
    if (animateIcon) FloatyIconAnimation.start();
  }
}
