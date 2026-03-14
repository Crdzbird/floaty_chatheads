import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Stopwatch overlay with start/pause/reset controls.
///
/// Streams elapsed time to the main app once per second (not 100ms).
/// Tapping the chathead toggles start/pause.
class TimerOverlay extends StatefulWidget {
  const TimerOverlay({super.key});

  @override
  State<TimerOverlay> createState() => _TimerOverlayState();
}

class _TimerOverlayState extends State<TimerOverlay> {
  final _stopwatch = Stopwatch();
  Timer? _ticker;
  final _laps = <Duration>[];
  late final StreamSubscription<Object?> _dataSub;
  late final StreamSubscription<String> _tapSub;

  @override
  void initState() {
    super.initState();
    FloatyOverlay.setUp();

    _dataSub = FloatyOverlay.onData.listen((data) {
      if (data is Map && mounted) {
        switch (data['command']) {
          case 'start':
            _start();
          case 'pause':
            _pause();
          case 'reset':
            _reset();
        }
      }
    });

    _tapSub = FloatyOverlay.onTapped.listen((id) {
      _stopwatch.isRunning ? _pause() : _start();
    });
  }

  void _start() {
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
      _pushState();
    });
    _pushState();
  }

  void _pause() {
    _stopwatch.stop();
    _ticker?.cancel();
    if (mounted) setState(() {});
    _pushState();
  }

  void _reset() {
    _stopwatch
      ..stop()
      ..reset();
    _ticker?.cancel();
    _laps.clear();
    if (mounted) setState(() {});
    _pushState();
  }

  void _lap() {
    if (_stopwatch.isRunning) {
      setState(() => _laps.add(_stopwatch.elapsed));
    }
  }

  void _pushState() {
    FloatyOverlay.shareData({
      'elapsed': _stopwatch.elapsedMilliseconds,
      'isRunning': _stopwatch.isRunning,
    });
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _stopwatch.elapsed;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(6),
          color: Colors.blueGrey.shade800,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _fmt(elapsed),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Btn(
                      icon: _stopwatch.isRunning
                          ? Icons.pause
                          : Icons.play_arrow,
                      onTap: _stopwatch.isRunning ? _pause : _start,
                    ),
                    const SizedBox(width: 8),
                    _Btn(icon: Icons.stop, onTap: _reset),
                    const SizedBox(width: 8),
                    _Btn(icon: Icons.flag, onTap: _lap),
                  ],
                ),
                if (_laps.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 2),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 40),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _laps.length,
                      itemBuilder: (_, i) => Text(
                        'Lap ${i + 1}: ${_fmt(_laps[i])}',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: FloatyOverlay.closeOverlay,
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _dataSub.cancel();
    _tapSub.cancel();
    FloatyOverlay.dispose();
    super.dispose();
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
