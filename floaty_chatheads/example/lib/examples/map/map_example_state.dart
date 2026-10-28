part of '../map_example.dart';

final class _MapExampleState extends State<MapExample>
    with _MapExampleSetup, _MapExampleActions {
  @override
  void initState() {
    super.initState();
    _setUpRouter();
    _setUpStateChannel();
    _setUpProxy();
    _closeSub = FloatyChatheads.onClosed.listen((_) {
      if (mounted) setState(() => _chatheadActive = false);
    });
    _locationService = LocationService(useSimulation: _useSimulation);
    _locationSub = _locationService.positionStream.listen(_onLocationUpdate);
    unawaited(_locationService.startTracking());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Map'),
        actions: [
          IconButton(
            icon: Icon(_useSimulation ? Icons.route : Icons.my_location),
            tooltip: _useSimulation ? 'Using simulation' : 'Using GPS',
            onPressed: () => unawaited(_toggleSimulation()),
          ),
          if (!_chatheadActive)
            IconButton(
              icon: const Icon(Icons.map),
              tooltip: 'Launch map bubble',
              onPressed: () => unawaited(_launch()),
            ),
          if (_chatheadActive)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close chathead',
              onPressed: _closeChathead,
            ),
        ],
      ),
      body: Column(
        children: [
          MapExampleStatusBar(status: _status, simulated: _useSimulation),
          Expanded(
            child: MapExampleMapView(
              controller: _mapController,
              onTap: _onMapTap,
              currentLocation: _currentLocation,
              pinnedLocation: _pinnedLocation,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }
}
