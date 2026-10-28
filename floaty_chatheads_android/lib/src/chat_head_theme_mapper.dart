import 'package:floaty_chatheads_android/src/generated/floaty_chatheads_api.g.dart'
    as pigeon;
import 'package:floaty_chatheads_platform_interface/floaty_chatheads_platform_interface.dart';

/// Converts a platform-interface [ChatHeadTheme] to its Pigeon message.
extension ChatHeadThemeMapper on ChatHeadTheme {
  /// Returns the [pigeon.ChatHeadThemeMessage] that mirrors this theme.
  pigeon.ChatHeadThemeMessage toPigeonTheme() {
    final palette = overlayPalette;
    return pigeon.ChatHeadThemeMessage(
      badgeColor: badgeColor,
      badgeTextColor: badgeTextColor,
      bubbleBorderColor: bubbleBorderColor,
      bubbleBorderWidth: bubbleBorderWidth,
      bubbleShadowColor: bubbleShadowColor,
      closeTintColor: closeTintColor,
      overlayPalette: palette != null ? Map<String?, int?>.from(palette) : null,
    );
  }
}
