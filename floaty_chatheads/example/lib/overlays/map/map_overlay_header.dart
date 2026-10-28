import 'package:flutter/material.dart';

/// Green title bar of the map overlay with locate and close buttons.
final class MapOverlayHeader extends StatelessWidget {
  /// Creates the header; [onLocate] asks for the GPS fix, [onClose] closes.
  const factory MapOverlayHeader({
    required VoidCallback onLocate,
    required VoidCallback onClose,
    Key? key,
  }) = MapOverlayHeader._;

  const MapOverlayHeader._({
    required this.onLocate,
    required this.onClose,
    super.key,
  });

  /// Called when the locate icon is tapped.
  final VoidCallback onLocate;

  /// Called when the close icon is tapped.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.green.shade700,
      child: Row(
        children: [
          const Icon(Icons.map, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Map',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          GestureDetector(
            onTap: onLocate,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.my_location, color: Colors.white70, size: 14),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, color: Colors.white70, size: 14),
          ),
        ],
      ),
    );
  }
}
