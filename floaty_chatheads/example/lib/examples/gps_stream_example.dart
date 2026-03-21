import 'dart:async';
import 'dart:math';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Demonstrates [FloatyProxyStream] with a simulated GPS feed.
///
/// The main app generates fake GPS coordinates on a 1-second timer
/// and pushes them to the overlay via a single proxy stream. The
/// overlay displays the live coordinates and a visual direction
/// indicator — no polling, no request/response, just a continuous
/// one-way push from main → overlay.
///
/// **Key concepts:**
///
/// - `FloatyProxyStream<T>` (main app side) — serializes and pushes
///   values to the overlay.
/// - `FloatyProxyStream<T>.overlay()` — deserializes and emits values
///   as a `Stream<T>`.
/// - Unidirectional: the overlay is a passive consumer.
class GpsStreamExample extends StatefulWidget {
  const GpsStreamExample({super.key});

  @override
  State<GpsStreamExample> createState() => _GpsStreamExampleState();
}

class _GpsStreamExampleState extends State<GpsStreamExample> {
  bool _chatheadActive = false;
  StreamSubscription<String>? _closeSub;
  Timer? _gpsTimer;
  late FloatyProxyStream<GpsCoord> _gpsStream;

  // Simulated position — drifts randomly.
  double _lat = 12.1364;
  double _lng = -86.2514;
  double _heading = 0;
  int _updateCount = 0;
  final _log = <String>[];

  @override
  void initState() {
    super.initState();
    _closeSub = FloatyChatheads.onClosed.listen((_) {
      if (mounted) {
        setState(() => _chatheadActive = false);
        _stopSimulation();
      }
    });

    _gpsStream = FloatyProxyStream<GpsCoord>(
      name: 'gps',
      toJson: (c) => c.toJson(),
    );
  }

  void _startSimulation() {
    _gpsTimer?.cancel();
    _gpsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final random = Random();
      // Small random drift.
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

      _gpsStream.add(coord);

      if (mounted) {
        setState(() {
          _log.insert(
            0,
            '#$_updateCount  ${coord.lat}, ${coord.lng}  '
            '${coord.heading}°  ${coord.speed} km/h',
          );
          if (_log.length > 50) _log.removeLast();
        });
      }
    });
  }

  void _stopSimulation() {
    _gpsTimer?.cancel();
    _gpsTimer = null;
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'gpsStreamOverlayMain',
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(title: 'GPS Stream'),
      snap: const SnapConfig(edge: SnapEdge.both),
      contentWidth: 240,
      contentHeight: 220,
    );
    setState(() => _chatheadActive = true);
    _startSimulation();
  }

  void _close() {
    FloatyChatheads.closeChatHead();
    _stopSimulation();
    setState(() {
      _chatheadActive = false;
      _log.insert(0, '[closed]');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Proxy Stream'),
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
              icon: const Icon(Icons.gps_fixed),
              label: const Text('Launch GPS'),
            )
          : null,
      body: Column(
        children: [
          // Explanation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FloatyProxyStream — GPS Example',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  'Main app pushes simulated GPS coordinates\n'
                  'every second. The overlay receives them via\n'
                  'a one-way FloatyProxyStream<GpsCoord>.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          // Current position
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.gps_fixed,
                  color: _chatheadActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_lat.toStringAsFixed(6)}, '
                        '${_lng.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _chatheadActive
                            ? 'Streaming ($_updateCount updates)'
                            : 'Tap Launch to start',
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              _chatheadActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Log header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  'Push Log (${_log.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                if (_log.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(_log.clear),
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),

          // Log list
          Expanded(
            child: _log.isEmpty
                ? const Center(
                    child: Text(
                      'GPS updates will appear here\n'
                      'once the overlay is launched.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _log.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        _log[i],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
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
    _gpsStream.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// Simulated GPS coordinate with heading and speed.
class GpsCoord {
  const GpsCoord({
    required this.lat,
    required this.lng,
    required this.heading,
    required this.speed,
  });

  factory GpsCoord.fromJson(Map<String, dynamic> json) => GpsCoord(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        heading: (json['heading'] as num).toDouble(),
        speed: (json['speed'] as num).toDouble(),
      );

  final double lat;
  final double lng;
  final double heading;
  final double speed;

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'heading': heading,
        'speed': speed,
      };
}
