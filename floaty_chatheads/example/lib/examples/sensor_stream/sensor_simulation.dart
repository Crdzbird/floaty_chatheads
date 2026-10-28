part of '../sensor_stream_example.dart';

mixin _SensorSimulation on State<SensorStreamExample> {
  Timer? _sensorTimer;
  late final FloatyProxyStream<AccelData> _accelStream;
  late final FloatyProxyStream<LightData> _lightStream;

  double _ax = 0;
  double _ay = 9.8;
  double _az = 0;
  double _lux = 250;
  int _updateCount = 0;
  bool _streaming = false;

  void _startSimulation() {
    _sensorTimer?.cancel();
    _streaming = true;
    _sensorTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => _tick(),
    );
  }

  void _tick() {
    final r = Random();
    _ax = (r.nextDouble() - 0.5) * 4;
    _ay = 9.8 + (r.nextDouble() - 0.5) * 2;
    _az = (r.nextDouble() - 0.5) * 3;
    _lux = (_lux + (r.nextDouble() - 0.5) * 40).clamp(0, 1000);
    _updateCount++;

    unawaited(
      _accelStream.add(
        AccelData(
          x: double.parse(_ax.toStringAsFixed(2)),
          y: double.parse(_ay.toStringAsFixed(2)),
          z: double.parse(_az.toStringAsFixed(2)),
        ),
      ),
    );

    unawaited(
      _lightStream.add(
        LightData(
          lux: double.parse(_lux.toStringAsFixed(1)),
          label: _lux < 100
              ? 'Dark'
              : _lux < 400
                  ? 'Indoor'
                  : 'Bright',
        ),
      ),
    );

    if (mounted) setState(() {});
  }

  void _stopSimulation() {
    _sensorTimer?.cancel();
    _sensorTimer = null;
    _streaming = false;
  }
}
