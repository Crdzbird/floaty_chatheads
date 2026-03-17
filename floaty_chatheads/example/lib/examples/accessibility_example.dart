import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// Accessibility example: demonstrates TalkBack support.
///
/// Instructions for testing with TalkBack are shown on-screen. The overlay
/// uses large touch targets and semantic labels.
class AccessibilityExample extends StatefulWidget {
  const AccessibilityExample({super.key});

  @override
  State<AccessibilityExample> createState() => _AccessibilityExampleState();
}

class _AccessibilityExampleState extends State<AccessibilityExample> {
  final _events = <String>[];
  StreamSubscription<Object?>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FloatyChatheads.onData.listen((data) {
      if (mounted) {
        setState(() {
          _events.insert(0, '$data');
          if (_events.length > 30) _events.removeLast();
        });
      }
    });
  }

  Future<void> _launch() async {
    if (!await ensureOverlayPermission()) return;
    await FloatyChatheads.showChatHead(
      entryPoint: 'accessibilityOverlayMain',
      assets: const ChatHeadAssets(
        icon: IconSource.asset('assets/showcase_bubble.png'),
        closeIcon: IconSource.asset('assets/showcase_close.png'),
        closeBackground: IconSource.asset('assets/showcase_close_bg.png'),
      ),
      notification: const NotificationConfig(title: 'Accessibility Test'),
      contentWidth: 200,
      contentHeight: 240,
    );
    // Set a badge so TalkBack announces "N new messages".
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await FloatyChatheads.updateBadge(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility / TalkBack')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _launch,
        icon: const Icon(Icons.accessibility_new),
        label: const Text('Launch'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'TalkBack Testing Guide',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Enable TalkBack in Settings > Accessibility\n'
                      '2. Tap "Launch" to show the chathead\n'
                      '3. Swipe to focus the chat bubble\n'
                      '   - Should announce: "Chat bubble default, 2 new messages"\n'
                      '4. Double-tap to expand\n'
                      '   - Should announce: "Chat expanded"\n'
                      '   - Focus moves to content panel\n'
                      '5. Double-tap "Tap Me" button\n'
                      '   - Counter updates as live region\n'
                      '6. Drag bubble to close target\n'
                      '   - Should announce: "Close target visible"\n'
                      '7. Double-tap "Close" to dismiss\n'
                      '   - Should announce: "Content panel hidden"',
                      style: TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => FloatyChatheads.expandChatHead(),
                    icon: const Icon(Icons.open_in_full),
                    label: const Text('Expand'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => FloatyChatheads.collapseChatHead(),
                    icon: const Icon(Icons.close_fullscreen),
                    label: const Text('Collapse'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => FloatyChatheads.closeChatHead(),
              icon: const Icon(Icons.close),
              label: const Text('Close Chathead'),
            ),
            const SizedBox(height: 16),
            Text(
              'Overlay events (${_events.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (_events.isEmpty)
              const Text(
                'Events from the overlay will appear here.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              )
            else
              ..._events.take(15).map(
                (e) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(e, style: const TextStyle(fontSize: 12)),
                  ),
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
    super.dispose();
  }
}
