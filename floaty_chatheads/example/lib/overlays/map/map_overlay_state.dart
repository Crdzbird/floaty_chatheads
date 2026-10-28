part of '../map_overlay.dart';

final class _MapOverlayState extends State<MapOverlay> with _MapOverlayLogic {
  late final StreamSubscription<Object?> _rawSub;
  late final StreamSubscription<MapSyncState> _stateSub;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();
    _router = FloatyActionRouter.overlay();
    _router.on(PinAction.key, _onPin);
    _stateChannel = FloatyStateChannel<MapSyncState>.overlay(
      toJson: (s) => s.toJson(),
      fromJson: MapSyncState.fromJson,
      initialState: MapSyncState(),
    );
    _stateSub = _stateChannel.onStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _tracking = state.tracking);
    });
    _proxyClient = FloatyProxyClient();
    _rawSub = FloatyOverlay.onData.listen(_onRawData);
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
              MapOverlayHeader(
                onLocate: () => unawaited(_requestLocation()),
                onClose: () => unawaited(FloatyOverlay.closeOverlay()),
              ),
              Expanded(
                child: MapOverlayMapView(
                  controller: _mapController,
                  onTap: _onMapTap,
                  onMarkerTap: _onMarkerTap,
                  liveLocation: _liveLocation,
                  pinLocation: _pinLocation,
                ),
              ),
              MapOverlayStatusBar(status: _status, tracking: _tracking),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_rawSub.cancel());
    unawaited(_stateSub.cancel());
    unawaited(_router.dispose());
    unawaited(_stateChannel.dispose());
    _proxyClient.dispose();
    _mapController.dispose();
    FloatyOverlay.dispose();
    super.dispose();
  }
}
