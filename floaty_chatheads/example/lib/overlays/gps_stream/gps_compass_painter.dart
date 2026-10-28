import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints a compass ring with cardinal ticks and a red heading needle.
final class GpsCompassPainter extends CustomPainter {
  /// Creates a painter for [heading] degrees.
  factory GpsCompassPainter({required double heading}) =>
      GpsCompassPainter._(heading: heading);

  GpsCompassPainter._({required this.heading});

  /// Heading in degrees, 0 is north.
  final double heading;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final ringPaint = Paint()
      ..color = Colors.green.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, ringPaint);

    final tickPaint = Paint()
      ..color = Colors.green.shade400
      ..strokeWidth = 1.5;
    for (var i = 0; i < 4; i++) {
      final angle = (i * 90 - 90) * math.pi / 180;
      final outer = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - 6) * math.cos(angle),
        center.dy + (radius - 6) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    final needleAngle = (heading - 90) * math.pi / 180;
    final needleTip = Offset(
      center.dx + (radius - 8) * math.cos(needleAngle),
      center.dy + (radius - 8) * math.sin(needleAngle),
    );
    final needlePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleTip, needlePaint);

    canvas.drawCircle(center, 2.5, Paint()..color = Colors.green.shade800);
  }

  @override
  bool shouldRepaint(GpsCompassPainter oldDelegate) =>
      oldDelegate.heading != heading;
}
