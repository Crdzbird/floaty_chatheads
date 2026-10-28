part of '../map_example.dart';

mixin _MapExampleSetup on State<MapExample> {
  final _mapController = MapController();
  LatLng? _pinnedLocation;
  bool _chatheadActive = false;
  String _status = 'Tap the map to drop a pin';

  late final LocationService _locationService;
  StreamSubscription<LatLng>? _locationSub;
  StreamSubscription<String>? _closeSub;
  LatLng? _currentLocation;
  bool _useSimulation = false;

  late final FloatyActionRouter _router;
  late final FloatyStateChannel<MapSyncState> _stateChannel;
  late final FloatyProxyHost _proxyHost;

  void _setUpRouter() {
    _router = FloatyActionRouter();
    _router.on(NavigateAction.key, _onNavigate);
    _router.on(PinAction.key, _onPin);
  }

  void _onNavigate(NavigateAction action) {
    if (!mounted) return;
    final target = LatLng(action.lat, action.lng);
    _mapController.move(target, _mapController.camera.zoom);
    setState(() {
      _status = 'Navigated to ${action.lat.toStringAsFixed(4)}, '
          '${action.lng.toStringAsFixed(4)}';
    });
  }

  void _onPin(PinAction action) {
    if (!mounted) return;
    final target = LatLng(action.lat, action.lng);
    setState(() {
      _pinnedLocation = target;
      _status = 'Pinned from overlay '
          '${action.lat.toStringAsFixed(4)}, '
          '${action.lng.toStringAsFixed(4)}';
    });
    _mapController.move(target, _mapController.camera.zoom);
  }

  void _setUpStateChannel() {
    _stateChannel = FloatyStateChannel<MapSyncState>(
      toJson: (s) => s.toJson(),
      fromJson: MapSyncState.fromJson,
      initialState: MapSyncState(),
    );
  }

  void _setUpProxy() {
    _proxyHost = FloatyProxyHost();
    _proxyHost.register('location', (method, params) async {
      final location = _currentLocation;
      if (method != 'getCurrentPosition' || location == null) return null;
      return {'lat': location.latitude, 'lng': location.longitude};
    });
  }

  void _disposeAll() {
    unawaited(_closeSub?.cancel());
    unawaited(_locationSub?.cancel());
    _locationService.dispose();
    unawaited(_router.dispose());
    unawaited(_stateChannel.dispose());
    _proxyHost.dispose();
    _mapController.dispose();
    unawaited(FloatyChatheads.closeChatHead());
    FloatyChatheads.dispose();
  }
}
