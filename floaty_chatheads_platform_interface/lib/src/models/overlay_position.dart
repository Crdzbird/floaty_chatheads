import 'package:meta/meta.dart';

/// {@template overlay_position}
/// The on-screen position of the overlay window.
/// {@endtemplate}
@immutable
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverlayPosition && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}
