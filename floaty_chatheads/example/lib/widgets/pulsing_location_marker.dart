import 'package:flutter/material.dart';

import 'pulsing_location/pulsing_location_dot.dart';
import 'pulsing_location/pulsing_location_ring.dart';

part 'pulsing_location/pulsing_location_marker_state.dart';

/// An animated blue dot that pulses outward, used to represent the user's
/// live location on a map.
final class PulsingLocationMarker extends StatefulWidget {
  /// Creates the marker; [size] is the inner dot diameter (default 14).
  const factory PulsingLocationMarker({Key? key, double size}) =
      PulsingLocationMarker._;

  const PulsingLocationMarker._({super.key, this.size = 14});

  /// Diameter of the solid inner circle.
  final double size;

  @override
  State<PulsingLocationMarker> createState() => _PulsingLocationMarkerState();
}
