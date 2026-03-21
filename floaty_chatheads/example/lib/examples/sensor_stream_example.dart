import 'dart:async';
import 'dart:math';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Demonstrates **multiple** [FloatyProxyStream] instances running in
/// parallel — one for accelerometer data and one for light sensor data.
///
/// The main app simulates both sensor feeds on a timer and pushes them
/// independently. The overlay subscribes to both streams and renders
/// them side by side, showing that multiple proxy streams can coexist
/// without interference.
///
/// **Key concepts:**
///
/// - Multiple `FloatyProxyStream` instances with different `name`s
///   coexist on the same channel prefix.
/// - Each stream is independent — the overlay can subscribe to both
///   and they arrive separately.
/// - The `latest` getter provides synchronous access to the most
///   recent value.
class SensorStreamExample extends StatefulWidget {
  const SensorStreamExample({super.key});

  @override
  State<SensorStreamExample> createState() => _SensorStreamExampleState();
}

class _SensorStreamExampleState extends State<SensorStreamExample> {
  bool _chatheadActive = false;
  StreamSubscription<String>? _closeSub;
  Timer? _sensorTimer;

  late final FloatyProxyStream<AccelData> _accelStream;
  late final FloatyProxyStream<LightData> _lightStream;

  // Simulated sensor values.
  double _ax = 0;
  double _ay = 9.8;
  double _az = 0;
  double _lux = 250;
  int _updateCount = 0;
  bool _streaming = false;

  @override
  void initState() {
    super.initState();
    _closeSub = FloatyChatheads.onClosed.listen((_) {
      if (mounted) {
        setState(() => _chatheadActive = false);
        _stopSimulation();
      }
    });

    _accelStream = FloatyProxyStream<AccelData>(
      name: 'accel',
      toJson: (d) => d.toJson(),
    );

    _lightStream = FloatyProxyStream<LightData>(
      name: 'light',
      toJson: (d) => d.toJson(),
    );
  }

  void _startSimulation() {
    _sensorTimer?.cancel();
    _streaming = true;
    _sensorTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final r = Random();
      // Accelerometer — simulates slight movement around gravity.
      _ax = (r.nextDouble() - 0.5) * 4;
      _ay = 9.8 + (r.nextDouble() - 0.5) * 2;
      _az = (r.nextDouble() - 0.5) * 3;
      // Light — simulates ambient changes.
      _lux = (_lux + (r.nextDouble() - 0.5) * 40).clamp(0, 1000);
      _updateCount++;

      _accelStream.add(AccelData(
        x: double.parse(_ax.toStringAsFixed(2)),
        y: double.parse(_ay.toStringAsFixed(2)),
        z: double.parse(_az.toStringAsFixed(2)),
      ));

      _lightStream.add(LightData(
        lux: double.parse(_lux.toStringAsFixed(1)),
        label: _lux < 100
            ? 'Dark'
            : _lux < 400
                ? 'Indoor'
                : 'Bright',
      ));

      if (mounted) setState(() {});
    });
  }

  void _stopSimulation() {
    _sensorTimer?.cancel();
    _sensorTimer = null;
    _streaming = false;
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
    FloatyChatheads.closeChatHead();
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
              onPressed: _launch,
              icon: const Icon(Icons.sensors),
              label: const Text('Launch Sensors'),
            )
          : null,
      body: Column(
        children: [
          // Explanation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.purple.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multiple FloatyProxyStreams',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  'Two independent streams push data at 5 Hz:\n'
                  '• "accel" → simulated accelerometer (x, y, z)\n'
                  '• "light" → simulated ambient light (lux)\n'
                  'The overlay subscribes to both separately.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  _streaming ? Icons.sensors : Icons.sensors_off,
                  color: _streaming ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _streaming
                      ? 'Streaming ($_updateCount updates)'
                      : 'Not streaming',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _streaming ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Accelerometer card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.vibration, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Accelerometer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'accel',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _AxisBar(label: 'X', value: _ax, maxVal: 10, color: Colors.red),
                    const SizedBox(height: 6),
                    _AxisBar(
                      label: 'Y',
                      value: _ay,
                      maxVal: 15,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 6),
                    _AxisBar(
                      label: 'Z',
                      value: _az,
                      maxVal: 10,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Light sensor card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.light_mode, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Ambient Light',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'light',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (_lux / 1000).clamp(0, 1),
                              minHeight: 16,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(
                                _lux < 100
                                    ? Colors.grey.shade600
                                    : _lux < 400
                                        ? Colors.amber
                                        : Colors.orange,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 80,
                          child: Text(
                            '${_lux.toStringAsFixed(0)} lux',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

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
    _closeSub?.cancel();
    _stopSimulation();
    _accelStream.dispose();
    _lightStream.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

/// Simulated accelerometer reading.
class AccelData {
  const AccelData({required this.x, required this.y, required this.z});

  factory AccelData.fromJson(Map<String, dynamic> json) => AccelData(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        z: (json['z'] as num).toDouble(),
      );

  final double x;
  final double y;
  final double z;

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'z': z};
}

/// Simulated light sensor reading.
class LightData {
  const LightData({required this.lux, required this.label});

  factory LightData.fromJson(Map<String, dynamic> json) => LightData(
        lux: (json['lux'] as num).toDouble(),
        label: json['label'] as String,
      );

  final double lux;
  final String label;

  Map<String, dynamic> toJson() => {'lux': lux, 'label': label};
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _AxisBar extends StatelessWidget {
  const _AxisBar({
    required this.label,
    required this.value,
    required this.maxVal,
    required this.color,
  });

  final String label;
  final double value;
  final double maxVal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final normalized = (value.abs() / maxVal).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 52,
          child: Text(
            value.toStringAsFixed(2),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
