import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Timer example: the stopwatch runs inside the overlay,
/// and the main app displays the synced elapsed time + remote controls.
class TimerExample extends StatefulWidget {
  const TimerExample({super.key});

  @override
  State<TimerExample> createState() => _TimerExampleState();
}

class _TimerExampleState extends State<TimerExample> {
  int _elapsedMs = 0;
  bool _isRunning = false;
  StreamSubscription<Object?>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FloatyChatheads.onData.listen((data) {
      if (data is Map && mounted) {
        setState(() {
          if (data['elapsed'] is int) _elapsedMs = data['elapsed'] as int;
          if (data['isRunning'] is bool) {
            _isRunning = data['isRunning'] as bool;
          }
        });
      }
    });
  }

  void _sendCommand(String command) {
    FloatyChatheads.shareData({'command': command});
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'timerOverlayMain',
      assets: const ChatHeadAssets.defaults(),
      notification: const NotificationConfig(title: 'Timer Active'),
      contentWidth: 200,
      contentHeight: 160,
    );
  }

  String _formatDuration(int ms) {
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer / Stopwatch')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _launch,
        icon: const Icon(Icons.timer),
        label: const Text('Launch Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Timer display (synced from overlay)
            Text(
              _formatDuration(_elapsedMs),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w300,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _isRunning
                    ? Colors.green.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isRunning ? Icons.play_arrow : Icons.pause,
                    size: 16,
                    color: _isRunning ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isRunning ? 'Running' : 'Stopped',
                    style: TextStyle(
                      color: _isRunning ? Colors.green : Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Remote controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () =>
                      _sendCommand(_isRunning ? 'pause' : 'start'),
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _sendCommand('reset'),
                  icon: const Icon(Icons.stop),
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'The timer runs inside the overlay.\n'
                'Use these buttons to control it remotely,\n'
                'or tap the chathead bubble to toggle.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    FloatyChatheads.closeChatHead();
    FloatyChatheads.dispose();
    super.dispose();
  }
}
