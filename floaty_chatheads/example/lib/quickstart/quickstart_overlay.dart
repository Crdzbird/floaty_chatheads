import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// The quickstart overlay: shows the last message from the app and offers
/// send and close buttons.
final class QuickstartOverlay extends StatelessWidget {
  /// Creates the quickstart overlay content.
  const factory QuickstartOverlay({Key? key}) = QuickstartOverlay._;

  const QuickstartOverlay._({super.key});

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
              onPressed: () =>
                  unawaited(FloatyOverlay.shareData('Hello from overlay!')),
              child: const Text('Send to app'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => unawaited(FloatyOverlay.closeOverlay()),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
