import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/map_actions.dart';
import '../widgets/pulsing_location_marker.dart';

/// Full-featured mini map overlay demonstrating three advanced features:
///
/// 1. **Action Router** – receives `PinAction`, dispatches `NavigateAction`.
/// 2. **State Channel** – receives `MapSyncState` with center/zoom/tracking.
/// 3. **Proxy Client** – calls `location.getCurrentPosition` on the main app
///    to get the latest GPS fix without its own `LocationService`.
///
/// Also receives live location updates via raw `onData` stream for the
/// streaming use case.
class MapOverlay extends StatefulWidget {
  const MapOverlay({super.key});

  @override
  State<MapOverlay> createState() => _MapOverlayState();
}

class _MapOverlayState extends State<MapOverlay> {
  static const _defaultCenter = LatLng(12.1364, -86.2514);

  final _mapController = MapController();
  LatLng? _pinLocation;
  LatLng? _liveLocation;
  String _status = 'Tap map to drop a pin';
  bool _tracking = false;

  // --- New feature instances ---
  late final FloatyActionRouter _router;
  late final FloatyStateChannel<MapSyncState> _stateChannel;
  late final FloatyProxyClient _proxyClient;

  late final StreamSubscription<Object?> _rawSub;
  late final StreamSubscription<MapSyncState> _stateSub;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();

    // 1. Action router — handle pin actions from main app.
    _router = FloatyActionRouter.overlay();
    _router.on<PinAction>(
      'pin',
      fromJson: PinAction.fromJson,
      handler: (action) {
        if (!mounted) return;
        final target = LatLng(action.lat, action.lng);
        setState(() {
          _pinLocation = target;
          _status = 'Pin ${action.lat.toStringAsFixed(4)}, '
              '${action.lng.toStringAsFixed(4)}';
        });
        _mapController.move(target, _mapController.camera.zoom);
      },
    );

    // 2. State channel — receive synced map state.
    _stateChannel = FloatyStateChannel<MapSyncState>.overlay(
      toJson: (s) => s.toJson(),
      fromJson: MapSyncState.fromJson,
      initialState: MapSyncState(),
    );
    _stateSub = _stateChannel.onStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _tracking = state.tracking);
    });

    // 3. Proxy client — call main app's location service on demand.
    _proxyClient = FloatyProxyClient();

    // Raw stream for live location updates (streaming use case).
    _rawSub = FloatyOverlay.onData.listen((data) {
      if (data is! Map || !mounted) return;
      if (data['action'] == 'location') {
        final lat = data['lat'] as double?;
        final lng = data['lng'] as double?;
        if (lat != null && lng != null) {
          setState(() => _liveLocation = LatLng(lat, lng));
        }
      }
    });
  }

  void _onMarkerTap() {
    if (_pinLocation == null) return;
    // Dispatch typed navigate action back to main app.
    _router.dispatch(NavigateAction(
      lat: _pinLocation!.latitude,
      lng: _pinLocation!.longitude,
    ));
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _pinLocation = point;
      _status = 'Pin ${point.latitude.toStringAsFixed(4)}, '
          '${point.longitude.toStringAsFixed(4)}';
    });

    // Dispatch typed pin action back to main app.
    _router.dispatch(PinAction(
      lat: point.latitude,
      lng: point.longitude,
    ));
  }

  /// Requests the current GPS position from the main app via the proxy.
  Future<void> _requestLocation() async {
    try {
      final result = await _proxyClient.call(
        'location',
        'getCurrentPosition',
      );
      if (result is Map && mounted) {
        final lat = result['lat'] as double?;
        final lng = result['lng'] as double?;
        if (lat != null && lng != null) {
          final target = LatLng(lat, lng);
          setState(() {
            _liveLocation = target;
            _status = 'GPS ${lat.toStringAsFixed(4)}, '
                '${lng.toStringAsFixed(4)}';
          });
          _mapController.move(target, _mapController.camera.zoom);
        }
      }
    } on FloatyProxyException {
      // Timeout or error — ignore silently.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(4),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
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
                    // Request GPS via proxy
                    GestureDetector(
                      onTap: _requestLocation,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.my_location,
                          color: Colors.white70,
                          size: 14,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: FloatyOverlay.closeOverlay,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Interactive map
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _defaultCenter,
                    initialZoom: 14,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                    onTap: _onMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'dev.floaty.chatheads.example',
                    ),
                    // Live location blue dot
                    if (_liveLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _liveLocation!,
                            width: 24,
                            height: 24,
                            child: const PulsingLocationMarker(size: 10),
                          ),
                        ],
                      ),
                    // Pin marker
                    if (_pinLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _pinLocation!,
                            width: 28,
                            height: 28,
                            child: GestureDetector(
                              onTap: _onMarkerTap,
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
                ),
              ),
              // Status / hint bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                color: Colors.green.shade50,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _status,
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.green.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_tracking)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rawSub.cancel();
    _stateSub.cancel();
    _router.dispose();
    _stateChannel.dispose();
    _proxyClient.dispose();
    _mapController.dispose();
    FloatyOverlay.dispose();
    super.dispose();
  }
}
