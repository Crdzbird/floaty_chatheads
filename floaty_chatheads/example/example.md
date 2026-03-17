# Floaty Chatheads Example

## Basic chathead with bidirectional messaging

```dart
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: BasicExample()));

/// Overlay entry point — must be top-level for AOT discoverability.
@pragma('vm:entry-point')
void overlayMain() => FloatyOverlayApp.run(const OverlayContent());

class BasicExample extends StatefulWidget {
  const BasicExample({super.key});
  @override
  State<BasicExample> createState() => _BasicExampleState();
}

class _BasicExampleState extends State<BasicExample> {
  int _received = 0;

  @override
  void initState() {
    super.initState();
    FloatyChatheads.onData.listen((data) {
      if (mounted) setState(() => _received++);
    });
  }

  Future<void> _show() async {
    final hasPermission = await FloatyChatheads.requestPermission();
    if (!hasPermission) return;

    await FloatyChatheads.showChatHead(
      ChatHeadConfig(
        entryPoint: 'overlayMain',
        contentWidth: 300,
        contentHeight: 400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Chathead')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(onPressed: _show, child: const Text('Show')),
            Text('Received from overlay: $_received'),
            ElevatedButton(
              onPressed: () => FloatyChatheads.shareData('Hello overlay!'),
              child: const Text('Send to overlay'),
            ),
          ],
        ),
      ),
    );
  }
}

class OverlayContent extends StatelessWidget {
  const OverlayContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: ElevatedButton(
          onPressed: () => FloatyOverlay.shareData('Hello main app!'),
          child: const Text('Send to app'),
        ),
      ),
    );
  }
}
```

See the [full gallery app](https://github.com/crdzbird/floaty_chatheads/tree/main/floaty_chatheads/example)
for 14 runnable examples covering messenger chat, mini player, map sync,
notification counters, multi-chathead, survival after app death, and more.
