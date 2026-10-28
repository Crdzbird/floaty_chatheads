part of '../gps_stream_example.dart';

mixin _GpsSimulation on State<GpsStreamExample> {
  Timer? _gpsTimer;
  late final FloatyProxyStream<GpsCoord> _gpsStream;
  double _lat = 12.1364;
  double _lng = -86.2514;
  double _heading = 0;
  int _updateCount = 0;
  final _log = <String>[];

  void _startSimulation() {
    _gpsTimer?.cancel();
    _gpsTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final random = Random();
    _lat += (random.nextDouble() - 0.5) * 0.001;
    _lng += (random.nextDouble() - 0.5) * 0.001;
    _heading = (_heading + random.nextDouble() * 30 - 10) % 360;
    _updateCount++;

    final coord = GpsCoord(
      lat: double.parse(_lat.toStringAsFixed(6)),
      lng: double.parse(_lng.toStringAsFixed(6)),
      heading: double.parse(_heading.toStringAsFixed(1)),
      speed: double.parse((random.nextDouble() * 60).toStringAsFixed(1)),
    );

    unawaited(_gpsStream.add(coord));

    if (!mounted) return;
    setState(() {
      _log.insert(
        0,
        '#$_updateCount  ${coord.lat}, ${coord.lng}  '
        '${coord.heading}°  ${coord.speed} km/h',
      );
      if (_log.length > 50) _log.removeLast();
    });
  }

  void _stopSimulation() {
    _gpsTimer?.cancel();
    _gpsTimer = null;
  }
}
