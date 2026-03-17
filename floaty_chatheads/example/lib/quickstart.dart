/// Minimal quickstart -- copy this file into your project to get started.
///
/// This shows the simplest possible integration with floaty_chatheads.
/// For the full 12-example gallery, see `main.dart`.
library;

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────────────────────
// 1. Overlay entry point (runs in a separate Flutter engine)
// ──────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
void overlayMain() => FloatyOverlayApp.run(
  const FloatyScope(child: QuickstartOverlay()),
);

// ──────────────────────────────────────────────────────────────────
// 2. Overlay widget -- your content inside the floating panel
// ──────────────────────────────────────────────────────────────────

class QuickstartOverlay extends StatelessWidget {
  const QuickstartOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = FloatyScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Overlay')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Last message: ${scope.lastMessage ?? "none"}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => FloatyOverlay.shareData('Hello from overlay!'),
              child: const Text('Send to app'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: FloatyOverlay.closeOverlay,
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// 3. Main app -- launch the chathead with one call
// ──────────────────────────────────────────────────────────────────

void main() => runApp(const QuickstartApp());

class QuickstartApp extends StatelessWidget {
  const QuickstartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FloatyPermissionGate(
        fallback: Center(
          child: ElevatedButton(
            onPressed: FloatyChatheads.requestPermission,
            child: const Text('Grant Overlay Permission'),
          ),
        ),
        child: const QuickstartHome(),
      ),
    );
  }
}

class QuickstartHome extends StatefulWidget {
  const QuickstartHome({super.key});

  @override
  State<QuickstartHome> createState() => _QuickstartHomeState();
}

class _QuickstartHomeState extends State<QuickstartHome> {
  String _status = 'Idle';

  @override
  void initState() {
    super.initState();
    FloatyChatheads.onData.listen((data) {
      setState(() => _status = 'Received: $data');
    });
  }

  Future<void> _launch() async {
    final shown = await FloatyLauncher.show(
      entryPoint: 'overlayMain',
      assets: const ChatHeadAssets.defaults(),
      notification: const NotificationConfig(title: 'Quickstart'),
      sizePreset: ContentSizePreset.card,
    );
    setState(() => _status = shown ? 'Chathead shown' : 'Permission denied');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quickstart')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_status),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _launch,
              child: const Text('Show Chathead'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await FloatyChatheads.shareData('Hello from app!');
                setState(() => _status = 'Sent message');
              },
              child: const Text('Send Data'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await FloatyChatheads.closeChatHead();
                setState(() => _status = 'Closed');
              },
              child: const Text('Close Chathead'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    FloatyChatheads.closeChatHead();
    super.dispose();
  }
}
