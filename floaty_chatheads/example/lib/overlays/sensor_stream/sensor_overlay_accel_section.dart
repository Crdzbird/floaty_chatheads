import 'package:flutter/material.dart';

import '../../examples/sensor_stream/accel_data.dart';
import 'sensor_mini_axis_bar.dart';
import 'sensor_overlay_section.dart';
import 'sensor_waiting_text.dart';

/// Accelerometer section of the sensor overlay.
final class SensorOverlayAccelSection extends StatelessWidget {
  /// Creates the section for the latest [data], if any.
  const factory SensorOverlayAccelSection({
    required AccelData? data,
    required int count,
    Key? key,
  }) = SensorOverlayAccelSection._;

  const SensorOverlayAccelSection._({
    required this.data,
    required this.count,
    super.key,
  });

  /// Latest reading, or null before the first one arrives.
  final AccelData? data;

  /// Number of readings received.
  final int count;

  @override
  Widget build(BuildContext context) {
    final accel = data;
    return SensorOverlaySection(
      color: Colors.blue,
      icon: Icons.vibration,
      title: 'Accelerometer',
      count: count,
      child: accel == null
          ? const SensorWaitingText()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SensorMiniAxisBar(
                  label: 'X',
                  value: accel.x,
                  maxVal: 10,
                  color: Colors.red,
                ),
                const SizedBox(height: 3),
                SensorMiniAxisBar(
                  label: 'Y',
                  value: accel.y,
                  maxVal: 15,
                  color: Colors.green,
                ),
                const SizedBox(height: 3),
                SensorMiniAxisBar(
                  label: 'Z',
                  value: accel.z,
                  maxVal: 10,
                  color: Colors.blue,
                ),
              ],
            ),
    );
  }
}
