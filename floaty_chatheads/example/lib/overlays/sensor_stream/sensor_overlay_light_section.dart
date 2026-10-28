import 'package:flutter/material.dart';

import '../../examples/sensor_stream/light_data.dart';
import 'sensor_light_meter.dart';
import 'sensor_overlay_section.dart';
import 'sensor_waiting_text.dart';

/// Ambient light section of the sensor overlay.
final class SensorOverlayLightSection extends StatelessWidget {
  /// Creates the section for the latest [data], if any.
  const factory SensorOverlayLightSection({
    required LightData? data,
    required int count,
    Key? key,
  }) = SensorOverlayLightSection._;

  const SensorOverlayLightSection._({
    required this.data,
    required this.count,
    super.key,
  });

  /// Latest reading, or null before the first one arrives.
  final LightData? data;

  /// Number of readings received.
  final int count;

  @override
  Widget build(BuildContext context) {
    final light = data;
    return SensorOverlaySection(
      color: Colors.amber,
      icon: Icons.light_mode,
      title: 'Ambient Light',
      count: count,
      child: light == null
          ? const SensorWaitingText()
          : SensorLightMeter(data: light),
    );
  }
}
