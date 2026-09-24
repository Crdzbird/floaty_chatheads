/// {@template panel_anchor}
/// Where the expanded content panel is anchored relative to the bubble.
///
/// The panel is always clamped to the screen bounds, so a panel that
/// would extend past an edge is shifted back on-screen.
/// {@endtemplate}
enum PanelAnchor {
  /// {@template panel_anchor.below}
  /// Open the panel below the bubble. Default.
  /// {@endtemplate}
  below,

  /// {@template panel_anchor.above}
  /// Open the panel above the bubble.
  ///
  /// On Android the expanded bubble row snaps to the bottom of the
  /// screen so the panel has room above it.
  /// {@endtemplate}
  above,

  /// {@template panel_anchor.auto}
  /// Open the panel below the bubble when there is room on screen,
  /// otherwise above it. Resolved once each time the panel expands.
  /// {@endtemplate}
  auto,
}
