import 'package:flutter/material.dart';

import '../../examples/sensor_stream/light_data.dart';

/// Compact light level bar with the lux value and its label.
final class SensorLightMeter extends StatelessWidget {
  /// Creates the meter for [data].
  const factory SensorLightMeter({required LightData data, Key? key}) =
      SensorLightMeter._;

  const SensorLightMeter._({required this.data, super.key});

  /// Reading to show.
  final LightData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (data.lux / 1000).clamp(0, 1),
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                data.lux < 100
                    ? Colors.grey.shade600
                    : data.lux < 400
                        ? Colors.amber
                        : Colors.orange,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 62,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${data.lux.toStringAsFixed(0)} lux',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                data.label,
                style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
