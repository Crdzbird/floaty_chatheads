import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Green title bar of the GPS overlay with an update count and close icon.
final class GpsOverlayHeader extends StatelessWidget {
  /// Creates the header showing [count] received updates.
  const factory GpsOverlayHeader({required int count, Key? key}) =
      GpsOverlayHeader._;

  const GpsOverlayHeader._({required this.count, super.key});

  /// Number of updates received so far.
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: Colors.green.shade700,
      child: Row(
        children: [
          const Icon(Icons.gps_fixed, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'GPS Stream',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            '$count updates',
            style: const TextStyle(color: Colors.white70, fontSize: 9),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => unawaited(FloatyOverlay.closeOverlay()),
            child: const Icon(Icons.close, color: Colors.white70, size: 14),
          ),
        ],
      ),
    );
  }
}
