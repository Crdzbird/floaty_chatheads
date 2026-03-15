import 'package:flutter/material.dart';

/// An animated blue dot that pulses outward, used to represent the user's
/// live location on a map.
class PulsingLocationMarker extends StatefulWidget {
  const PulsingLocationMarker({super.key, this.size = 14});

  /// Diameter of the solid inner circle.
  final double size;

  @override
  State<PulsingLocationMarker> createState() => _PulsingLocationMarkerState();
}

class _PulsingLocationMarkerState extends State<PulsingLocationMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outerMax = widget.size * 2.2;
    return SizedBox(
      width: outerMax,
      height: outerMax,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing outer ring
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) {
                final scale = 1.0 + _ctrl.value * 0.8; // 1.0 → 1.8
                final opacity = 1.0 - _ctrl.value; // 1.0 → 0.0
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withValues(alpha: 0.35 * opacity),
                    ),
                  ),
                );
              },
            ),
            // White border ring
            Container(
              width: widget.size + 4,
              height: widget.size + 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            // Solid inner dot
            Container(
              width: widget.size,
              height: widget.size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
