# Floaty Chatheads Android Example

This package is the Android implementation of
[floaty_chatheads](https://pub.dev/packages/floaty_chatheads).
It is not intended for direct use — add `floaty_chatheads` to your
`pubspec.yaml` instead.

```dart
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: BasicExample()));

@pragma('vm:entry-point')
void overlayMain() => FloatyOverlayApp.run(const OverlayContent());

class BasicExample extends StatelessWidget {
  const BasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await FloatyChatheads.requestPermission();
            await FloatyChatheads.showChatHead(
              ChatHeadConfig(
                entryPoint: 'overlayMain',
                contentWidth: 300,
                contentHeight: 400,
              ),
            );
          },
          child: const Text('Show Chathead'),
        ),
      ),
    );
  }
}

class OverlayContent extends StatelessWidget {
  const OverlayContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(child: Center(child: Text('Hello from overlay!')));
  }
}
```

See the [full gallery app](https://github.com/crdzbird/floaty_chatheads/tree/main/floaty_chatheads/example)
for complete examples.
