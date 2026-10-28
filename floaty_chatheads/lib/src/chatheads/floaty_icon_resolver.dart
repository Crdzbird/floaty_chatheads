import 'package:floaty_chatheads/src/animated_widget_icon.dart';
import 'package:floaty_chatheads/src/chatheads/floaty_icon_animation.dart';
import 'package:floaty_chatheads/src/widget_to_icon_source.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

/// Turns widget-based chathead icons into [ChatHeadAssets].
final class FloatyIconResolver {
  FloatyIconResolver._();

  /// Renders the widget icons and merges them over [assets]; widget
  /// sources win. Returns [assets] unchanged when no widget is given.
  ///
  /// An [iconBuilder] becomes the active [FloatyIconAnimation].
  static Future<ChatHeadAssets?> resolve({
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
    Future<IconSource?> render(Widget? widget) async => widget == null
        ? null
        : await widgetToIconSource(
            widget,
            size: iconSize,
            pixelRatio: iconPixelRatio,
          );
    final animated = iconBuilder == null
        ? null
        : AnimatedWidgetIcon(
            id: 'default',
            builder: iconBuilder,
            fps: iconAnimationFps,
            size: iconSize,
            pixelRatio: iconPixelRatio,
            duration: iconAnimationDuration,
          );
    await animated?.init();
    if (animated != null) FloatyIconAnimation.active = animated;
    final icon = animated?.initialFrame ?? await render(iconWidget);
    final close = await render(closeIconWidget);
    final closeBg = await render(closeBackgroundWidget);
    if (icon == null && close == null && closeBg == null) return assets;
    return ChatHeadAssets(
      icon:
          icon ??
          assets?.icon ??
          const IconSource.asset('assets/chatheadIcon.png'),
      closeIcon:
          close ??
          assets?.closeIcon ??
          const IconSource.asset('assets/close.png'),
      closeBackground:
          closeBg ??
          assets?.closeBackground ??
          const IconSource.asset('assets/closeBg.png'),
    );
  }
}
