import 'package:flutter/material.dart';

/// Row showing the current simulated position and the streaming status.
final class GpsPositionRow extends StatelessWidget {
  /// Creates the row for the position [lat], [lng].
  const factory GpsPositionRow({
    required double lat,
    required double lng,
    required bool active,
    required int updateCount,
    Key? key,
  }) = GpsPositionRow._;

  const GpsPositionRow._({
    required this.lat,
    required this.lng,
    required this.active,
    required this.updateCount,
    super.key,
  });

  /// Current latitude.
  final double lat;

  /// Current longitude.
  final double lng;

  /// Whether the chathead is showing and the stream is running.
  final bool active;

  /// Number of updates pushed so far.
  final int updateCount;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.green : Colors.grey;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.gps_fixed, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${lat.toStringAsFixed(6)}, '
                  '${lng.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  active
                      ? 'Streaming ($updateCount updates)'
                      : 'Tap Launch to start',
                  style: TextStyle(fontSize: 11, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
