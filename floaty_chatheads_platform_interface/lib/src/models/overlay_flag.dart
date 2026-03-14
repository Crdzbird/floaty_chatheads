/// {@template overlay_flag}
/// Window behavior flags for the overlay.
/// {@endtemplate}
enum OverlayFlag {
  /// {@template overlay_flag.default_flag}
  /// Default behavior -- the overlay is interactive and visible.
  /// {@endtemplate}
  defaultFlag,

  /// {@template overlay_flag.click_through}
  /// The overlay ignores all touch events.
  /// {@endtemplate}
  clickThrough,

  /// {@template overlay_flag.focus_pointer}
  /// The overlay can receive keyboard focus.
  /// {@endtemplate}
  focusPointer,
}
