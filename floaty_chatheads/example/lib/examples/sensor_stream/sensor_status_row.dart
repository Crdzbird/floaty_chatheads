import 'package:flutter/material.dart';

/// Row showing whether the sensor simulation is streaming.
final class SensorStatusRow extends StatelessWidget {
  /// Creates the status row.
  const factory SensorStatusRow({
    required bool streaming,
    required int updateCount,
    Key? key,
  }) = SensorStatusRow._;

  const SensorStatusRow._({
    required this.streaming,
    required this.updateCount,
    super.key,
  });

  /// Whether the simulation timer is running.
  final bool streaming;

  /// Number of updates pushed so far.
  final int updateCount;

  @override
  Widget build(BuildContext context) {
    final color = streaming ? Colors.green : Colors.grey;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(streaming ? Icons.sensors : Icons.sensors_off, color: color),
          const SizedBox(width: 8),
          Text(
            streaming ? 'Streaming ($updateCount updates)' : 'Not streaming',
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
