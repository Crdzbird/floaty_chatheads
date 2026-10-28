import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'location/is_gps_available.dart';

/// Provides a unified [positionStream] that emits [LatLng] positions from
/// either real GPS or a circular simulation around a fixed center.
final class LocationService {
  /// Creates a service that starts in simulation mode when [useSimulation]
  /// is true (default false).
  factory LocationService({bool useSimulation}) = LocationService._;

  LocationService._({bool useSimulation = false})
      : _useSimulation = useSimulation;

  static const _center = LatLng(12.1364, -86.2514);
  static const _radius = 0.005;
  static const _stepsPerRevolution = 60;

  bool _useSimulation;

  /// Whether positions currently come from the simulation.
  bool get useSimulation => _useSimulation;

  final _controller = StreamController<LatLng>.broadcast();

  /// Unified output stream; subscribe once, regardless of source.
  Stream<LatLng> get positionStream => _controller.stream;

  StreamSubscription<Position>? _gpsSub;
  Timer? _simTimer;
  double _simAngle = 0;

  /// Start emitting positions from the currently selected source.
  Future<void> startTracking() async {
    if (_useSimulation) {
      _startSimulation();
      return;
    }
    await _startGps();
  }

  /// Stop emitting positions without disposing the service.
  void stopTracking() {
    unawaited(_gpsSub?.cancel());
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
    unawaited(_controller.close());
  }

  Future<void> _startGps() async {
    if (!await isGpsAvailable()) {
      _fallBackToSimulation();
      return;
    }
    _gpsSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(
      (pos) => _controller.add(LatLng(pos.latitude, pos.longitude)),
      onError: (Object _) => _fallBackToSimulation(),
    );
  }

  void _fallBackToSimulation() {
    _useSimulation = true;
    _startSimulation();
  }

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
