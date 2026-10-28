import 'package:flutter/material.dart';

/// Small orange "SIM" badge shown while the location is simulated.
final class MapExampleSimBadge extends StatelessWidget {
  /// Creates the badge.
  const factory MapExampleSimBadge({Key? key}) = MapExampleSimBadge._;

  const MapExampleSimBadge._({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'SIM',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.orange.shade800,
        ),
      ),
    );
  }
}
