/// {@template chat_head_theme}
/// Theming configuration for the floating chathead.
///
/// All color values are ARGB integers (e.g. `0xFFFF0000` for opaque red).
/// Pass `null` to keep the platform default.
/// {@endtemplate}
class ChatHeadTheme {
  /// {@macro chat_head_theme}
  const ChatHeadTheme({
    this.badgeColor,
    this.badgeTextColor,
    this.bubbleBorderColor,
    this.bubbleBorderWidth,
    this.bubbleShadowColor,
    this.closeTintColor,
    this.overlayPalette,
  });

  /// {@template chat_head_theme.badge_color}
  /// Background color of the notification badge (default: red).
  /// {@endtemplate}
  final int? badgeColor;

  /// {@template chat_head_theme.badge_text_color}
  /// Text color of the notification badge (default: white).
  /// {@endtemplate}
  final int? badgeTextColor;

  /// {@template chat_head_theme.bubble_border_color}
  /// Optional border ring color drawn around the chathead bubble.
  /// {@endtemplate}
  final int? bubbleBorderColor;

  /// {@template chat_head_theme.bubble_border_width}
  /// Width of the bubble border ring in dp.
  ///
  /// Ignored when [bubbleBorderColor] is `null`. Defaults to `0`.
  /// {@endtemplate}
  final double? bubbleBorderWidth;

  /// {@template chat_head_theme.bubble_shadow_color}
  /// Shadow color behind the chathead bubble (default: semi-transparent black).
  /// {@endtemplate}
  final int? bubbleShadowColor;

  /// {@template chat_head_theme.close_tint_color}
  /// Tint color applied to the close-target icon.
  /// {@endtemplate}
  final int? closeTintColor;

  /// {@template chat_head_theme.overlay_palette}
  /// Color palette forwarded to the overlay isolate so it can style
  /// its Flutter UI to match.
  ///
  /// Supported keys: `primary`, `secondary`, `surface`, `background`,
  /// `onPrimary`, `onSecondary`, `onSurface`, `error`, `onError`.
  /// Values are ARGB integers.
  /// {@endtemplate}
  final Map<String, int>? overlayPalette;
}
