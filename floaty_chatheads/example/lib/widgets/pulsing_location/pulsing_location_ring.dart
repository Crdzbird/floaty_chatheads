import 'package:flutter/material.dart';

/// The fading outer ring of the location marker, scaled from 1.0 to 1.8
/// as [animation] runs from 0 to 1.
final class PulsingLocationRing extends StatelessWidget {
  /// Creates a ring [size] wide driven by [animation].
  const factory PulsingLocationRing({
    required Animation<double> animation,
    required double size,
    Key? key,
  }) = PulsingLocationRing._;

  const PulsingLocationRing._({
    required this.animation,
    required this.size,
    super.key,
  });

  /// Pulse progress from 0 to 1.
  final Animation<double> animation;

  /// Diameter of the ring before scaling.
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) {
        final scale = 1.0 + animation.value * 0.8;
        final opacity = 1.0 - animation.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withValues(alpha: 0.35 * opacity),
            ),
          ),
        );
      },
    );
  }
}
