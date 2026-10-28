import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Purple title bar of the sensor overlay with a close icon.
final class SensorOverlayHeader extends StatelessWidget {
  /// Creates the header.
  const factory SensorOverlayHeader({Key? key}) = SensorOverlayHeader._;

  const SensorOverlayHeader._({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: Colors.purple.shade700,
      child: Row(
        children: [
          const Icon(Icons.sensors, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Sensor Monitor',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => unawaited(FloatyOverlay.closeOverlay()),
            child: const Icon(Icons.close, color: Colors.white70, size: 14),
          ),
        ],
      ),
    );
  }
}
