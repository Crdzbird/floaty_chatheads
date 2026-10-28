import 'package:flutter/material.dart';

/// Banner explaining the two independent sensor proxy streams.
final class SensorStreamIntro extends StatelessWidget {
  /// Creates the explanation banner.
  const factory SensorStreamIntro({Key? key}) = SensorStreamIntro._;

  const SensorStreamIntro._({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.purple.shade50,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Multiple FloatyProxyStreams',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          SizedBox(height: 4),
          Text(
            'Two independent streams push data at 5 Hz:\n'
            '- "accel": simulated accelerometer (x, y, z)\n'
            '- "light": simulated ambient light (lux)\n'
            'The overlay subscribes to both separately.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
