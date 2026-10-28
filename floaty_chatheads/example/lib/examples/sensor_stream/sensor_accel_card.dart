import 'package:flutter/material.dart';

import 'sensor_axis_bar.dart';
import 'sensor_card_header.dart';

/// Card showing the simulated accelerometer axes as bars.
final class SensorAccelCard extends StatelessWidget {
  /// Creates the card for the axis values [x], [y] and [z].
  const factory SensorAccelCard({
    required double x,
    required double y,
    required double z,
    Key? key,
  }) = SensorAccelCard._;

  const SensorAccelCard._({
    required this.x,
    required this.y,
    required this.z,
    super.key,
  });

  /// X axis value.
  final double x;

  /// Y axis value.
  final double y;

  /// Z axis value.
  final double z;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SensorCardHeader(
                icon: Icons.vibration,
                iconColor: Colors.blue.shade700,
                title: 'Accelerometer',
                tag: 'accel',
                tagBackground: Colors.blue.shade50,
                tagColor: Colors.blue,
              ),
              const SizedBox(height: 12),
              SensorAxisBar(
                label: 'X',
                value: x,
                maxVal: 10,
                color: Colors.red,
              ),
              const SizedBox(height: 6),
              SensorAxisBar(
                label: 'Y',
                value: y,
                maxVal: 15,
                color: Colors.green,
              ),
              const SizedBox(height: 6),
              SensorAxisBar(
                label: 'Z',
                value: z,
                maxVal: 10,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
