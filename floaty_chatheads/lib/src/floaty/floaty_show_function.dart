import 'package:floaty_chatheads/src/icons/animated_icon_builder.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

/// Signature of `Floaty.show` and `Floaty.toggle`.
typedef FloatyShowFunction =
    Future<bool> Function({
      String entryPoint,
      String? entryPointLibrary,
      String? title,
      ContentSizePreset? size,
      int? contentWidth,
      int? contentHeight,
      PanelAnchor panelAnchor,
      EntranceAnimation entranceAnimation,
      OverlayFlag flag,
      bool enableDrag,
      ChatHeadTheme? theme,
      SnapConfig? snap,
      ChatHeadAssets? assets,
      NotificationConfig? notification,
      bool autoLaunchOnBackground,
      bool persistOnAppClose,
      bool debugMode,
      Widget? iconWidget,
      AnimatedIconBuilder? iconBuilder,
      Widget? closeIconWidget,
      Widget? closeBackgroundWidget,
      bool animateIcon,
      int iconAnimationFps,
      double iconSize,
      double iconPixelRatio,
      Duration iconAnimationDuration,
      Duration readyTimeout,
    });
