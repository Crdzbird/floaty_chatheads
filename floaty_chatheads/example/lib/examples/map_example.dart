import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/map_actions.dart';
import '../services/location_service.dart';
import '../utils.dart';
import '../widgets/pulsing_location_marker.dart';

/// Interactive map example demonstrating three advanced messaging features:
///
/// 1. **Action Router** – typed `PinAction` / `NavigateAction` instead of
///    raw string-keyed maps.
/// 2. **State Channel** – `MapSyncState` auto-synced between app and overlay
///    (center, zoom, tracking flag).
/// 3. **Proxy** – overlay can call `location.getCurrentPosition` on the main
///    app via `FloatyProxyClient`, without its own `LocationService`.
///
/// Also supports live location tracking via GPS with a simulated fallback.
class MapExample extends StatefulWidget {
  const MapExample({super.key});

  @override
  State<MapExample> createState() => _MapExampleState();
}

class _MapExampleState extends State<MapExample> {
  /// Default center: Managua, Nicaragua.
  static const _defaultCenter = LatLng(12.1364, -86.2514);

  final _mapController = MapController();
  LatLng? _pinnedLocation;
  bool _chatheadActive = false;
  String _status = 'Tap the map to drop a pin';

  // Live-location state
  late final LocationService _locationService;
  StreamSubscription<LatLng>? _locationSub;
  LatLng? _currentLocation;
  bool _useSimulation = false;

  // --- New feature instances ---

  /// Typed action router (replaces raw shareData for pin/navigate).
  late final FloatyActionRouter _router;

  /// Shared state channel (syncs map center, zoom, tracking flag).
  late final FloatyStateChannel<MapSyncState> _stateChannel;

  /// Proxy host — exposes a `location` service so the overlay can request
  /// the current GPS position on demand.
  late final FloatyProxyHost _proxyHost;

  @override
  void initState() {
    super.initState();

    // 1. Action router — handle navigate/pin actions from overlay.
    _router = FloatyActionRouter();
    _router.on<NavigateAction>(
      'navigate',
      fromJson: NavigateAction.fromJson,
      handler: (action) {
        if (!mounted) return;
        final target = LatLng(action.lat, action.lng);
        _mapController.move(target, _mapController.camera.zoom);
        setState(() {
          _status = 'Navigated to ${action.lat.toStringAsFixed(4)}, '
              '${action.lng.toStringAsFixed(4)}';
        });
      },
    );
    _router.on<PinAction>(
      'pin',
      fromJson: PinAction.fromJson,
      handler: (action) {
        if (!mounted) return;
        final target = LatLng(action.lat, action.lng);
        setState(() {
          _pinnedLocation = target;
          _status = 'Pinned from overlay '
              '${action.lat.toStringAsFixed(4)}, '
              '${action.lng.toStringAsFixed(4)}';
        });
        _mapController.move(target, _mapController.camera.zoom);
      },
    );

    // 2. Shared state channel.
    _stateChannel = FloatyStateChannel<MapSyncState>(
      toJson: (s) => s.toJson(),
      fromJson: MapSyncState.fromJson,
      initialState: MapSyncState(),
    );

    // 3. Proxy host — expose location service to overlay.
    _proxyHost = FloatyProxyHost();
    _proxyHost.register('location', (method, params) async {
      if (method == 'getCurrentPosition') {
        if (_currentLocation != null) {
          return {
            'lat': _currentLocation!.latitude,
            'lng': _currentLocation!.longitude,
          };
        }
        return null;
      }
      return null;
    });

    // Live-location tracking.
    _locationService = LocationService(useSimulation: _useSimulation);
    _locationSub = _locationService.positionStream.listen(_onLocationUpdate);
    _locationService.startTracking();
  }

  void _onLocationUpdate(LatLng latLng) {
    if (!mounted) return;
    setState(() => _currentLocation = latLng);

    // Relay live location to overlay via raw shareData (streaming use case).
    FloatyChatheads.shareData({
      'action': 'location',
      'lat': latLng.latitude,
      'lng': latLng.longitude,
    });
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'mapOverlayMain',
      chatheadIconAsset: 'assets/chatheadIcon.png',
      closeIconAsset: 'assets/close.png',
      closeBackgroundAsset: 'assets/closeBg.png',
      notificationTitle: 'Map Overlay Active',
      contentWidth: 220,
      contentHeight: 220,
      entranceAnimation: EntranceAnimation.pop,
      snapEdge: SnapEdge.both,
    );
    setState(() => _chatheadActive = true);

    // Sync current state to overlay.
    await _stateChannel.setState(MapSyncState(
      centerLat: _mapController.camera.center.latitude,
      centerLng: _mapController.camera.center.longitude,
      zoom: _mapController.camera.zoom,
      tracking: _useSimulation,
    ));

    // Send current pin to overlay via action router.
    if (_pinnedLocation != null) {
      await _router.dispatch(PinAction(
        lat: _pinnedLocation!.latitude,
        lng: _pinnedLocation!.longitude,
      ));
    }

    // Send current live location to overlay.
    if (_currentLocation != null) {
      await FloatyChatheads.shareData({
        'action': 'location',
        'lat': _currentLocation!.latitude,
        'lng': _currentLocation!.longitude,
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _pinnedLocation = point;
      _status = 'Pinned at ${point.latitude.toStringAsFixed(4)}, '
          '${point.longitude.toStringAsFixed(4)}';
    });

    // Dispatch typed action to overlay.
    _router.dispatch(PinAction(lat: point.latitude, lng: point.longitude));
  }

  Future<void> _toggleSimulation() async {
    final next = !_useSimulation;
    await _locationService.setSimulation(enabled: next);
    if (mounted) {
      setState(() => _useSimulation = _locationService.useSimulation);
      // Sync tracking flag via state channel.
      unawaited(_stateChannel.updateState({'tracking': _useSimulation}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Map'),
        actions: [
          // Simulation / GPS toggle
          IconButton(
            icon: Icon(
              _useSimulation ? Icons.route : Icons.my_location,
            ),
            tooltip: _useSimulation ? 'Using simulation' : 'Using GPS',
            onPressed: _toggleSimulation,
          ),
          if (!_chatheadActive)
            IconButton(
              icon: const Icon(Icons.map),
              tooltip: 'Launch map bubble',
              onPressed: _launch,
            ),
          if (_chatheadActive)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close chathead',
              onPressed: () {
                FloatyChatheads.closeChatHead();
                setState(() => _chatheadActive = false);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.green.shade50,
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.green.shade400,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _status,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (_useSimulation)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SIM',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 13,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.floaty.chatheads.example',
                ),
                // Live location blue dot
                if (_currentLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentLocation!,
                        width: 32,
                        height: 32,
                        child: const PulsingLocationMarker(),
                      ),
                    ],
                  ),
                // Dropped pin
                if (_pinnedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pinnedLocation!,
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _locationService.dispose();
    _router.dispose();
    _stateChannel.dispose();
    _proxyHost.dispose();
    _mapController.dispose();
    FloatyChatheads.dispose();
    super.dispose();
  }
}
