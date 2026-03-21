import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../examples/sensor_stream_example.dart';

/// Overlay that subscribes to **two independent** [FloatyProxyStream]
/// instances — accelerometer (`'accel'`) and light sensor (`'light'`).
///
/// Renders both sensor feeds as compact visual indicators, showing that
/// multiple proxy streams coexist on the same channel without collision.
class SensorStreamOverlay extends StatefulWidget {
  const SensorStreamOverlay({super.key});

  @override
  State<SensorStreamOverlay> createState() => _SensorStreamOverlayState();
}

class _SensorStreamOverlayState extends State<SensorStreamOverlay> {
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

    _accelStream = FloatyProxyStream<AccelData>.overlay(
      name: 'accel',
      fromJson: AccelData.fromJson,
    );

    _lightStream = FloatyProxyStream<LightData>.overlay(
      name: 'light',
      fromJson: LightData.fromJson,
    );

    _accelSub = _accelStream.stream.listen((data) {
      if (mounted) {
        setState(() {
          _accel = data;
          _accelCount++;
        });
      }
    });

    _lightSub = _lightStream.stream.listen((data) {
      if (mounted) {
        setState(() {
          _light = data;
          _lightCount++;
        });
      }
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
              // Header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: Colors.purple.shade700,
                child: Row(
                  children: [
                    const Icon(Icons.sensors, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Sensor Monitor',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: FloatyOverlay.closeOverlay,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Accelerometer section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.vibration,
                            size: 12,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Accelerometer',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$_accelCount',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.blue.shade400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (_accel == null)
                        const Text(
                          'Waiting...',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        )
                      else ...[
                        _MiniAxisBar(
                          label: 'X',
                          value: _accel!.x,
                          maxVal: 10,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 3),
                        _MiniAxisBar(
                          label: 'Y',
                          value: _accel!.y,
                          maxVal: 15,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 3),
                        _MiniAxisBar(
                          label: 'Z',
                          value: _accel!.z,
                          maxVal: 10,
                          color: Colors.blue,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Light section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.light_mode,
                            size: 12,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ambient Light',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$_lightCount',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.amber.shade400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (_light == null)
                        const Text(
                          'Waiting...',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: (_light!.lux / 1000).clamp(0, 1),
                                  minHeight: 12,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation(
                                    _light!.lux < 100
                                        ? Colors.grey.shade600
                                        : _light!.lux < 400
                                            ? Colors.amber
                                            : Colors.orange,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 62,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${_light!.lux.toStringAsFixed(0)} lux',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _light!.label,
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Stream info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '2 proxy streams  •  '
                    '${_accelCount + _lightCount} total updates',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _lightSub?.cancel();
    _accelStream.dispose();
    _lightStream.dispose();
    FloatyOverlay.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _MiniAxisBar extends StatelessWidget {
  const _MiniAxisBar({
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
          width: 12,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 9,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 38,
          child: Text(
            value.toStringAsFixed(1),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 9),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
