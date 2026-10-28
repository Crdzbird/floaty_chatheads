import 'package:flutter/material.dart';

/// Orange speed readout in km/h.
final class GpsSpeedRow extends StatelessWidget {
  /// Creates the readout for [speed] km/h.
  const factory GpsSpeedRow({required double speed, Key? key}) = GpsSpeedRow._;

  const GpsSpeedRow._({required this.speed, super.key});

  /// Speed in km/h.
  final double speed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.speed, size: 14, color: Colors.orange.shade700),
          const SizedBox(width: 4),
          Text(
            '${speed.toStringAsFixed(1)} km/h',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
