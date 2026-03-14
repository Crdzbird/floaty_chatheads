/// {@template overlay_position}
/// The on-screen position of the overlay window.
/// {@endtemplate}
class OverlayPosition {
  /// {@macro overlay_position}
  const OverlayPosition({required this.x, required this.y});

  /// {@template overlay_position.x}
  /// Horizontal position in device-independent pixels.
  /// {@endtemplate}
  final double x;

  /// {@template overlay_position.y}
  /// Vertical position in device-independent pixels.
  /// {@endtemplate}
  final double y;
}
