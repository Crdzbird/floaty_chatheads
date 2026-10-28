import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../examples/gps_stream/gps_coord.dart';
import 'gps_stream/gps_overlay_header.dart';
import 'gps_stream/gps_reading_view.dart';
import 'gps_stream/gps_waiting_view.dart';

part 'gps_stream/gps_stream_overlay_state.dart';

/// Overlay that displays live GPS coordinates from a [FloatyProxyStream].
///
/// Subscribes to the `gps` proxy stream and renders the current lat/lng,
/// a compass showing the heading, the speed and an update counter.
final class GpsStreamOverlay extends StatefulWidget {
  /// Creates the GPS stream overlay.
  const factory GpsStreamOverlay({Key? key}) = GpsStreamOverlay._;

  const GpsStreamOverlay._({super.key});

  @override
  State<GpsStreamOverlay> createState() => _GpsStreamOverlayState();
}
