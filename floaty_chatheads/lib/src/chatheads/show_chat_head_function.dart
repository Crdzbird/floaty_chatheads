import 'package:floaty_chatheads/src/icons/animated_icon_builder.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

/// Signature of `FloatyChatheads.showChatHead`.
typedef ShowChatHeadFunction =
    Future<void> Function({
      String entryPoint,
      String? entryPointLibrary,
      int? contentWidth,
      int? contentHeight,
      OverlayFlag flag,
      bool enableDrag,
      EntranceAnimation entranceAnimation,
      PanelAnchor panelAnchor,
      ChatHeadTheme? theme,
      ContentSizePreset? sizePreset,
      bool debugMode,
      bool autoLaunchOnBackground,
      bool persistOnAppClose,
      ChatHeadAssets? assets,
      NotificationConfig? notification,
      SnapConfig? snap,
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
