import 'package:flutter/material.dart';

/// One frame of the pulsing red alert icon for an animation [value].
final class WidgetIconPulse extends StatelessWidget {
  /// Creates the frame for [value], which runs from 0 to 1.
  const factory WidgetIconPulse({required double value, Key? key}) =
      WidgetIconPulse._;

  const WidgetIconPulse._({required this.value, super.key});

  /// Animation progress from 0 to 1.
  final double value;

  @override
  Widget build(BuildContext context) {
    final pulse = (value < 0.5) ? value * 2 : 2 - value * 2;
    final scale = 0.85 + pulse * 0.15;
    final opacity = 0.6 + pulse * 0.4;
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.4 * pulse),
                blurRadius: 12 * pulse,
                spreadRadius: 4 * pulse,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.priority_high, color: Colors.white, size: 36),
          ),
        ),
      ),
    );
  }
}
