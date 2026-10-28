import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../widgets/pulsing_location_marker.dart';

/// The interactive mini map of the map overlay with live dot and pin.
final class MapOverlayMapView extends StatelessWidget {
  /// Creates the map driven by [controller].
  const factory MapOverlayMapView({
    required MapController controller,
    required TapCallback onTap,
    required VoidCallback onMarkerTap,
    LatLng? liveLocation,
    LatLng? pinLocation,
    Key? key,
  }) = MapOverlayMapView._;

  const MapOverlayMapView._({
    required this.controller,
    required this.onTap,
    required this.onMarkerTap,
    this.liveLocation,
    this.pinLocation,
    super.key,
  });

  static const _defaultCenter = LatLng(12.1364, -86.2514);

  /// Controller that moves the camera.
  final MapController controller;

  /// Called when the map is tapped.
  final TapCallback onTap;

  /// Called when the pin marker is tapped.
  final VoidCallback onMarkerTap;

  /// Live location, shown as a pulsing dot.
  final LatLng? liveLocation;

  /// Dropped pin, shown as a red marker.
  final LatLng? pinLocation;

  @override
  Widget build(BuildContext context) {
    final live = liveLocation;
    final pin = pinLocation;
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: 14,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        onTap: onTap,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.floaty.chatheads.example',
        ),
        if (live != null)
          MarkerLayer(
            markers: [
              Marker(
                point: live,
                width: 24,
                height: 24,
                child: const PulsingLocationMarker(size: 10),
              ),
            ],
          ),
        if (pin != null)
          MarkerLayer(
            markers: [
              Marker(
                point: pin,
                width: 28,
                height: 28,
                child: GestureDetector(
                  onTap: onMarkerTap,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
