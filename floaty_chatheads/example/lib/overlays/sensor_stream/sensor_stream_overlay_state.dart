part of '../sensor_stream_overlay.dart';

final class _SensorStreamOverlayState extends State<SensorStreamOverlay> {
  late final FloatyProxyStream<AccelData> _accelStream;
  late final FloatyProxyStream<LightData> _lightStream;
  StreamSubscription<AccelData>? _accelSub;
  StreamSubscription<LightData>? _lightSub;

  AccelData? _accel;
  LightData? _light;
  int _accelCount = 0;
  int _lightCount = 0;

  @override
  void initState() {
    super.initState();

    _accelStream = FloatyProxyStream.overlay(AccelData.streamKey);
    _lightStream = FloatyProxyStream.overlay(LightData.streamKey);

    _accelSub = _accelStream.stream.listen((data) {
      if (!mounted) return;
      setState(() {
        _accel = data;
        _accelCount++;
      });
    });

    _lightSub = _lightStream.stream.listen((data) {
      if (!mounted) return;
      setState(() {
        _light = data;
        _lightCount++;
      });
    });
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
              const SensorOverlayHeader(),
              const SizedBox(height: 8),
              SensorOverlayAccelSection(data: _accel, count: _accelCount),
              const SizedBox(height: 6),
              SensorOverlayLightSection(data: _light, count: _lightCount),
              const SizedBox(height: 6),
              SensorOverlayFooter(totalUpdates: _accelCount + _lightCount),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_accelSub?.cancel());
    unawaited(_lightSub?.cancel());
    unawaited(_accelStream.dispose());
    unawaited(_lightStream.dispose());
    FloatyOverlay.dispose();
    super.dispose();
  }
}
