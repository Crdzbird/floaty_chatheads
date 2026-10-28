import 'package:flutter/material.dart';

import '../../examples/gps_stream/gps_coord.dart';
import 'gps_compass.dart';
import 'gps_coord_row.dart';
import 'gps_speed_row.dart';

/// Compass, coordinates and speed for the latest GPS fix.
final class GpsReadingView extends StatelessWidget {
  /// Creates the reading view for [coord].
  const factory GpsReadingView({required GpsCoord coord, Key? key}) =
      GpsReadingView._;

  const GpsReadingView._({required this.coord, super.key});

  /// The fix to show.
  final GpsCoord coord;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        GpsCompass(heading: coord.heading),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                GpsCoordRow(label: 'LAT', value: coord.lat),
                const SizedBox(height: 2),
                GpsCoordRow(label: 'LNG', value: coord.lng),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        GpsSpeedRow(speed: coord.speed),
        const SizedBox(height: 8),
      ],
    );
  }
}
