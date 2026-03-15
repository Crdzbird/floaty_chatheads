import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Provides a unified [positionStream] that emits [LatLng] positions from
/// either real GPS or a circular simulation around [_center].
class LocationService {
  LocationService({bool useSimulation = false})
      : _useSimulation = useSimulation;

  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------

  static const _center = LatLng(12.1364, -86.2514);
  static const _radius = 0.005; // ~500 m
  static const _stepsPerRevolution = 60; // full circle in 60 s

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _useSimulation;
  bool get useSimulation => _useSimulation;

  final _controller = StreamController<LatLng>.broadcast();

  /// Unified output stream — subscribe once, regardless of source.
  Stream<LatLng> get positionStream => _controller.stream;

  StreamSubscription<Position>? _gpsSub;
  Timer? _simTimer;
  double _simAngle = 0;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Start emitting positions from the currently selected source.
  Future<void> startTracking() async {
    if (_useSimulation) {
      _startSimulation();
    } else {
      await _startGps();
    }
  }

  /// Stop emitting positions without disposing the service.
  void stopTracking() {
    _gpsSub?.cancel();
    _gpsSub = null;
    _simTimer?.cancel();
    _simTimer = null;
  }

  /// Switch between real GPS and simulation. Restarts tracking automatically.
  Future<void> setSimulation({required bool enabled}) async {
    if (enabled == _useSimulation) return;
    _useSimulation = enabled;
    stopTracking();
    await startTracking();
  }

  /// Release all resources.
  void dispose() {
    stopTracking();
    _controller.close();
  }

  // ---------------------------------------------------------------------------
  // GPS
  // ---------------------------------------------------------------------------

  Future<void> _startGps() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Fall back to simulation when location services are off.
      _useSimulation = true;
      _startSimulation();
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Fall back to simulation when user denies permission.
      _useSimulation = true;
      _startSimulation();
      return;
    }

    _gpsSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(
      (pos) => _controller.add(LatLng(pos.latitude, pos.longitude)),
      onError: (_) {
        // On GPS error, switch to simulation.
        _useSimulation = true;
        _startSimulation();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Simulation
  // ---------------------------------------------------------------------------

  void _startSimulation() {
    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _simAngle += (2 * pi) / _stepsPerRevolution;
      final lat = _center.latitude + _radius * cos(_simAngle);
      final lng = _center.longitude + _radius * sin(_simAngle);
      _controller.add(LatLng(lat, lng));
    });
  }
}
