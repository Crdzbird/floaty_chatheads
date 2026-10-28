part of '../sensor_stream_example.dart';

final class _SensorStreamExampleState extends State<SensorStreamExample>
    with _SensorSimulation {
  bool _chatheadActive = false;
  StreamSubscription<String>? _closeSub;

  @override
  void initState() {
    super.initState();
    _closeSub = FloatyChatheads.onClosed.listen((_) {
      if (!mounted) return;
      setState(() => _chatheadActive = false);
      _stopSimulation();
    });

    _accelStream = FloatyProxyStream(AccelData.streamKey);
    _lightStream = FloatyProxyStream(LightData.streamKey);
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'sensorStreamOverlayMain',
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(title: 'Sensor Monitor'),
      snap: const SnapConfig(edge: SnapEdge.both),
      contentWidth: 240,
      contentHeight: 260,
    );
    setState(() => _chatheadActive = true);
    _startSimulation();
  }

  void _close() {
    unawaited(FloatyChatheads.closeChatHead());
    _stopSimulation();
    setState(() => _chatheadActive = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Proxy Streams'),
        actions: [
          if (_chatheadActive)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close overlay',
              onPressed: _close,
            ),
        ],
      ),
      floatingActionButton: !_chatheadActive
          ? FloatingActionButton.extended(
              onPressed: () => unawaited(_launch()),
              icon: const Icon(Icons.sensors),
              label: const Text('Launch Sensors'),
            )
          : null,
      body: Column(
        children: [
          const SensorStreamIntro(),
          const SizedBox(height: 12),
          SensorStatusRow(streaming: _streaming, updateCount: _updateCount),
          const SizedBox(height: 16),
          SensorAccelCard(x: _ax, y: _ay, z: _az),
          const SizedBox(height: 8),
          SensorLightCard(lux: _lux),
          const Spacer(),
          if (!_chatheadActive)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Tap "Launch Sensors" to start streaming\n'
                'data to the overlay.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_closeSub?.cancel());
    _stopSimulation();
    unawaited(_accelStream.dispose());
    unawaited(_lightStream.dispose());
    super.dispose();
  }
}
