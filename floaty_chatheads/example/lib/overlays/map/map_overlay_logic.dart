part of '../map_overlay.dart';

mixin _MapOverlayLogic on State<MapOverlay> {
  final _mapController = MapController();
  LatLng? _pinLocation;
  LatLng? _liveLocation;
  String _status = 'Tap map to drop a pin';
  bool _tracking = false;

  late final FloatyActionRouter _router;
  late final FloatyStateChannel<MapSyncState> _stateChannel;
  late final FloatyProxyClient _proxyClient;

  void _onPin(PinAction action) {
    if (!mounted) return;
    final target = LatLng(action.lat, action.lng);
    setState(() {
      _pinLocation = target;
      _status =
          'Pin ${action.lat.toStringAsFixed(4)}, '
          '${action.lng.toStringAsFixed(4)}';
    });
    _mapController.move(target, _mapController.camera.zoom);
  }

  void _onRawData(Object? data) {
    if (data is! Map || !mounted) return;
    if (data['action'] != 'location') return;
    final lat = data['lat'] as double?;
    final lng = data['lng'] as double?;
    if (lat == null || lng == null) return;
    setState(() => _liveLocation = LatLng(lat, lng));
  }

  void _onMarkerTap() {
    final pin = _pinLocation;
    if (pin == null) return;
    unawaited(
      _router.dispatch(NavigateAction(lat: pin.latitude, lng: pin.longitude)),
    );
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _pinLocation = point;
      _status =
          'Pin ${point.latitude.toStringAsFixed(4)}, '
          '${point.longitude.toStringAsFixed(4)}';
    });
    unawaited(
      _router.dispatch(PinAction(lat: point.latitude, lng: point.longitude)),
    );
  }

  Future<void> _requestLocation() async {
    try {
      final result = await _proxyClient.call('location', 'getCurrentPosition');
      if (result is! Map || !mounted) return;
      final lat = result['lat'] as double?;
      final lng = result['lng'] as double?;
      if (lat == null || lng == null) return;
      final target = LatLng(lat, lng);
      setState(() {
        _liveLocation = target;
        _status =
            'GPS ${lat.toStringAsFixed(4)}, '
            '${lng.toStringAsFixed(4)}';
      });
      _mapController.move(target, _mapController.camera.zoom);
    } on FloatyProxyException {
      return;
    }
  }
}
