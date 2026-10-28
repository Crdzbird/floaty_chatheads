import 'package:flutter/material.dart';

/// Hint strip at the bottom of the map overlay with an optional SIM badge.
final class MapOverlayStatusBar extends StatelessWidget {
  /// Creates the strip showing [status]; [tracking] adds the SIM badge.
  const factory MapOverlayStatusBar({
    required String status,
    required bool tracking,
    Key? key,
  }) = MapOverlayStatusBar._;

  const MapOverlayStatusBar._({
    required this.status,
    required this.tracking,
    super.key,
  });

  /// Status text to show.
  final String status;

  /// Whether the main app is in simulation mode.
  final bool tracking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      color: Colors.green.shade50,
      child: Row(
        children: [
          Expanded(
            child: Text(
              status,
              style: TextStyle(fontSize: 8, color: Colors.green.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (tracking)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'SIM',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
