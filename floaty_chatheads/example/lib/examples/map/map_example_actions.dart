part of '../map_example.dart';

mixin _MapExampleActions on State<MapExample>, _MapExampleSetup {
  void _onLocationUpdate(LatLng latLng) {
    if (!mounted) return;
    setState(() => _currentLocation = latLng);
    unawaited(
      FloatyChatheads.shareData({
        'action': 'location',
        'lat': latLng.latitude,
        'lng': latLng.longitude,
      }),
    );
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'mapOverlayMain',
      assets: const ChatHeadAssets.defaults(),
      notification: const NotificationConfig(title: 'Map Overlay Active'),
      contentWidth: 220,
      contentHeight: 220,
      entranceAnimation: EntranceAnimation.pop,
      snap: const SnapConfig(edge: SnapEdge.both),
    );
    setState(() => _chatheadActive = true);
    await _stateChannel.setState(
      MapSyncState(
        centerLat: _mapController.camera.center.latitude,
        centerLng: _mapController.camera.center.longitude,
        zoom: _mapController.camera.zoom,
        tracking: _useSimulation,
      ),
    );
    final pinned = _pinnedLocation;
    if (pinned != null) {
      await _router.dispatch(
        PinAction(lat: pinned.latitude, lng: pinned.longitude),
      );
    }
    final current = _currentLocation;
    if (current == null) return;
    await FloatyChatheads.shareData({
      'action': 'location',
      'lat': current.latitude,
      'lng': current.longitude,
    });
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _pinnedLocation = point;
      _status =
          'Pinned at ${point.latitude.toStringAsFixed(4)}, '
          '${point.longitude.toStringAsFixed(4)}';
    });
    unawaited(
      _router.dispatch(PinAction(lat: point.latitude, lng: point.longitude)),
    );
  }

  Future<void> _toggleSimulation() async {
    final next = !_useSimulation;
    await _locationService.setSimulation(enabled: next);
    if (!mounted) return;
    setState(() => _useSimulation = _locationService.useSimulation);
    unawaited(_stateChannel.updateState({'tracking': _useSimulation}));
  }

  void _closeChathead() {
    unawaited(FloatyChatheads.closeChatHead());
    setState(() => _chatheadActive = false);
  }
}
