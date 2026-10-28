import 'package:flutter/material.dart';

/// A solid circle of the given [size] and [color].
final class PulsingLocationDot extends StatelessWidget {
  /// Creates a circle [size] wide filled with [color].
  const factory PulsingLocationDot({
    required double size,
    required Color color,
    Key? key,
  }) = PulsingLocationDot._;

  const PulsingLocationDot._({
    required this.size,
    required this.color,
    super.key,
  });

  /// Diameter of the circle.
  final double size;

  /// Fill color of the circle.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
