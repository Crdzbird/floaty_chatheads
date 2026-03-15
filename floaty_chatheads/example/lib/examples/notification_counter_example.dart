import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Counter badge example: main app changes a counter, overlay displays
/// it as a badge. Overlay can send 'clear' back to reset.
class NotificationCounterExample extends StatefulWidget {
  const NotificationCounterExample({super.key});

  @override
  State<NotificationCounterExample> createState() =>
      _NotificationCounterExampleState();
}

class _NotificationCounterExampleState
    extends State<NotificationCounterExample> {
  int _counter = 0;
  StreamSubscription<Object?>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FloatyChatheads.onData.listen((data) {
      if (data is Map && mounted) {
        final action = data['action'];
        if (action == 'clear') {
          setState(() => _counter = 0);
        } else if (action == 'requestState') {
          // Overlay just started — send current count.
          _pushCount();
        }
      }
    });
  }

  void _pushCount() {
    FloatyChatheads.shareData({'count': _counter});
  }

  void _updateCounter(int value) {
    setState(() => _counter = value);
    _pushCount();
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'counterOverlayMain',
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(title: 'Counter Badge Active'),
      contentWidth: 140,
      contentHeight: 140,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Counter')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _launch,
        icon: const Icon(Icons.notifications),
        label: const Text('Launch Badge'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Counter display
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _counter > 0 ? Colors.red : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$_counter',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _counter > 0 ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: () => _updateCounter(_counter - 1),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                FilledButton.tonal(
                  onPressed: () => _updateCounter(0),
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 16),
                FilledButton.tonal(
                  onPressed: () => _updateCounter(_counter + 1),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Change the counter and watch the overlay badge update!',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    FloatyChatheads.dispose();
    super.dispose();
  }
}
