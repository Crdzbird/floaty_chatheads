import 'dart:async';

import 'package:floaty_chatheads/advanced.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/map_actions.dart';
import '../services/location_service.dart';
import '../utils.dart';
import 'map/map_example_map_view.dart';
import 'map/map_example_status_bar.dart';

part 'map/map_example_actions.dart';
part 'map/map_example_setup.dart';
part 'map/map_example_state.dart';

/// Interactive map example demonstrating three advanced messaging features:
///
/// 1. Action Router: typed `PinAction` / `NavigateAction` instead of
///    raw string-keyed maps.
/// 2. State Channel: `MapSyncState` auto-synced between app and overlay
///    (center, zoom, tracking flag).
/// 3. Proxy: overlay can call `location.getCurrentPosition` on the main
///    app via `FloatyProxyClient`, without its own `LocationService`.
///
/// Also supports live location tracking via GPS with a simulated fallback.
final class MapExample extends StatefulWidget {
  /// Creates the interactive map example page.
  const factory MapExample({Key? key}) = MapExample._;

  const MapExample._({super.key});

  @override
  State<MapExample> createState() => _MapExampleState();
}
