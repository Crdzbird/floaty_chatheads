import 'package:floaty_chatheads/src/widget_to_icon_source.dart';
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';
import 'package:flutter/widgets.dart';

/// Implementation of `FloatyChatheads.addChatHead`.
final class FloatyAddChatHead {
  FloatyAddChatHead._();

  /// Adds bubble [id] with [iconSource], or with [iconWidget] rendered at
  /// [iconSize] when no source is given and the platform draws icons.
  static Future<void> add({
    required String id,
    IconSource? iconSource,
    Widget? iconWidget,
    double iconSize = 80,
    double iconPixelRatio = 3.0,
  }) async {
    final platform = FloatyChatheadsPlatform.instance;
    final render = iconSource == null && platform.supportsNativeIcons;
    final widget = render ? iconWidget : null;
    final source = widget == null
        ? iconSource
        : await widgetToIconSource(
            widget,
            size: iconSize,
            pixelRatio: iconPixelRatio,
          );
    await platform.addChatHead(AddChatHeadConfig(id: id, iconSource: source));
  }
}
