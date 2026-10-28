import 'package:flutter/material.dart';

import 'map_example_sim_badge.dart';

/// Green status strip above the map with an optional SIM badge.
final class MapExampleStatusBar extends StatelessWidget {
  /// Creates the strip showing [status]; [simulated] adds the SIM badge.
  const factory MapExampleStatusBar({
    required String status,
    required bool simulated,
    Key? key,
  }) = MapExampleStatusBar._;

  const MapExampleStatusBar._({
    required this.status,
    required this.simulated,
    super.key,
  });

  /// Status text to show.
  final String status;

  /// Whether positions come from the simulation.
  final bool simulated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.green.shade50,
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.green.shade400),
          const SizedBox(width: 8),
          Expanded(child: Text(status, style: const TextStyle(fontSize: 12))),
          if (simulated) const MapExampleSimBadge(),
        ],
      ),
    );
  }
}
