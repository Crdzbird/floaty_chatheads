/// {@template content_size_preset}
/// Named size presets for the chathead content panel.
///
/// Use these instead of specifying raw `contentWidth`/`contentHeight` values
/// for common layouts. Negative dimension values are sentinel values resolved
/// on the native side (`-1` = MATCH_PARENT, `-2` = half-screen height).
/// {@endtemplate}
enum ContentSizePreset {
  /// {@template content_size_preset.compact}
  /// Compact floating card: 160 x 200 dp.
  /// {@endtemplate}
  compact(160, 200),

  /// {@template content_size_preset.card}
  /// Standard card: 300 x 400 dp.
  /// {@endtemplate}
  card(300, 400),

  /// {@template content_size_preset.half_screen}
  /// Full width, half the screen height.
  ///
  /// Resolves to `contentWidth = -1` (MATCH_PARENT) and a special
  /// sentinel for half-screen height on the native side.
  /// {@endtemplate}
  halfScreen(-1, -2),

  /// {@template content_size_preset.full_screen}
  /// Full-screen overlay: `contentWidth = -1`, `contentHeight = -1`.
  /// {@endtemplate}
  fullScreen(-1, -1);

  const ContentSizePreset(this.width, this.height);

  /// Width in dp (negative values are sentinels for MATCH_PARENT / special).
  final int width;

  /// Height in dp (negative values are sentinels for MATCH_PARENT / special).
  final int height;
}
