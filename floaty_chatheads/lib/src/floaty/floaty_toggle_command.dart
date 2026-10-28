import 'package:floaty_chatheads/src/animated_widget_icon.dart';
import 'package:floaty_chatheads/src/floaty/floaty_show_command.dart';
import 'package:floaty_chatheads/src/floaty_chatheads.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

/// Implementation of `Floaty.toggle`.
final class FloatyToggleCommand {
  FloatyToggleCommand._();

  /// Closes the chathead when it is visible, otherwise shows it with the
  /// same options as [FloatyShowCommand.show].
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
    Duration readyTimeout = const Duration(seconds: 10),
  }) async {
    if (await FloatyChatheads.isActive()) {
      await FloatyChatheads.closeChatHead();
      return false;
    }
    return await FloatyShowCommand.show(
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
      readyTimeout: readyTimeout,
    );
  }
}
