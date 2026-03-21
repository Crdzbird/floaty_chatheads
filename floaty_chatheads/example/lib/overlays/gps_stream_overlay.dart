import 'dart:async';
import 'dart:math' as math;

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../examples/gps_stream_example.dart';

/// Overlay that displays live GPS coordinates from a [FloatyProxyStream].
///
/// Subscribes to the `'gps'` proxy stream and renders:
/// - Current lat/lng
/// - A visual compass indicator showing heading
/// - Speed readout
/// - Update counter
class GpsStreamOverlay extends StatefulWidget {
  const GpsStreamOverlay({super.key});

  @override
  State<GpsStreamOverlay> createState() => _GpsStreamOverlayState();
}

class _GpsStreamOverlayState extends State<GpsStreamOverlay> {
  late final FloatyProxyStream<GpsCoord> _gpsStream;
  StreamSubscription<GpsCoord>? _sub;

  GpsCoord? _current;
  int _count = 0;

  @override
  void initState() {
    super.initState();

    _gpsStream = FloatyProxyStream<GpsCoord>.overlay(
      name: 'gps',
      fromJson: GpsCoord.fromJson,
    );

    _sub = _gpsStream.stream.listen((coord) {
      if (mounted) {
        setState(() {
          _current = coord;
          _count++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final coord = _current;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(4),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: Colors.green.shade700,
                child: Row(
                  children: [
                    const Icon(Icons.gps_fixed, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'GPS Stream',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      '$_count updates',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: FloatyOverlay.closeOverlay,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),

              if (coord == null)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.gps_off, size: 28, color: Colors.grey),
                      SizedBox(height: 6),
                      Text(
                        'Waiting for GPS data...',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else ...[
                const SizedBox(height: 8),

                // Compass + heading
                SizedBox(
                  height: 60,
                  width: 60,
                  child: CustomPaint(
                    painter: _CompassPainter(heading: coord.heading),
                    child: Center(
                      child: Text(
                        '${coord.heading.toStringAsFixed(0)}°',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Coordinates
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _CoordRow(label: 'LAT', value: coord.lat),
                        const SizedBox(height: 2),
                        _CoordRow(label: 'LNG', value: coord.lng),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Speed
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.speed,
                        size: 14,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${coord.speed.toStringAsFixed(1)} km/h',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _gpsStream.dispose();
    FloatyOverlay.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _CoordRow extends StatelessWidget {
  const _CoordRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value.toStringAsFixed(6),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({required this.heading});

  final double heading;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Outer ring.
    final ringPaint = Paint()
      ..color = Colors.green.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, ringPaint);

    // Cardinal ticks.
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

    // Heading needle.
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

    // Center dot.
    canvas.drawCircle(center, 2.5, Paint()..color = Colors.green.shade800);
  }

  @override
  bool shouldRepaint(_CompassPainter oldDelegate) =>
      oldDelegate.heading != heading;
}
