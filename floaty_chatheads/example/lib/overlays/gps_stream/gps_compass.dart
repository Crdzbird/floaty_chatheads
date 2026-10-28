import 'package:flutter/material.dart';

import 'gps_compass_painter.dart';

/// Small compass dial with the heading in degrees at its center.
final class GpsCompass extends StatelessWidget {
  /// Creates a compass pointing at [heading] degrees.
  const factory GpsCompass({required double heading, Key? key}) = GpsCompass._;

  const GpsCompass._({required this.heading, super.key});

  /// Heading in degrees, 0 is north.
  final double heading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      child: CustomPaint(
        painter: GpsCompassPainter(heading: heading),
        child: Center(
          child: Text(
            '${heading.toStringAsFixed(0)}°',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ),
      ),
    );
  }
}
