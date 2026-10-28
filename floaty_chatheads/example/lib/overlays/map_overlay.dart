import 'dart:async';

import 'package:floaty_chatheads/advanced.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/map_actions.dart';
import 'map/map_overlay_header.dart';
import 'map/map_overlay_map_view.dart';
import 'map/map_overlay_status_bar.dart';

part 'map/map_overlay_logic.dart';
part 'map/map_overlay_state.dart';

/// Full-featured mini map overlay demonstrating three advanced features:
///
/// 1. Action Router: receives `PinAction`, dispatches `NavigateAction`.
/// 2. State Channel: receives `MapSyncState` with center/zoom/tracking.
/// 3. Proxy Client: calls `location.getCurrentPosition` on the main app
///    to get the latest GPS fix without its own `LocationService`.
///
/// Also receives live location updates via raw `onData` stream for the
/// streaming use case.
final class MapOverlay extends StatefulWidget {
  /// Creates the map overlay.
  const factory MapOverlay({Key? key}) = MapOverlay._;

  const MapOverlay._({super.key});

  @override
  State<MapOverlay> createState() => _MapOverlayState();
}
