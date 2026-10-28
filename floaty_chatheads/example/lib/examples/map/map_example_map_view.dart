import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../widgets/pulsing_location_marker.dart';

/// The OSM map of the map example with the live dot and the dropped pin.
final class MapExampleMapView extends StatelessWidget {
  /// Creates the map driven by [controller].
  const factory MapExampleMapView({
    required MapController controller,
    required TapCallback onTap,
    LatLng? currentLocation,
    LatLng? pinnedLocation,
    Key? key,
  }) = MapExampleMapView._;

  const MapExampleMapView._({
    required this.controller,
    required this.onTap,
    this.currentLocation,
    this.pinnedLocation,
    super.key,
  });

  static const _defaultCenter = LatLng(12.1364, -86.2514);

  /// Controller that moves the camera.
  final MapController controller;

  /// Called when the map is tapped.
  final TapCallback onTap;

  /// Live location, shown as a pulsing dot.
  final LatLng? currentLocation;

  /// Dropped pin, shown as a red marker.
  final LatLng? pinnedLocation;

  @override
  Widget build(BuildContext context) {
    final current = currentLocation;
    final pinned = pinnedLocation;
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: 13,
        onTap: onTap,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.floaty.chatheads.example',
        ),
        if (current != null)
          MarkerLayer(
            markers: [
              Marker(
                point: current,
                width: 32,
                height: 32,
                child: const PulsingLocationMarker(),
              ),
            ],
          ),
        if (pinned != null)
          MarkerLayer(
            markers: [
              Marker(
                point: pinned,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
