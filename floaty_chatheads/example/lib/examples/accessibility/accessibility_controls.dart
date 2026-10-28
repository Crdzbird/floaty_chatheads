import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Expand, collapse and close buttons for the accessibility chathead.
final class AccessibilityControls extends StatelessWidget {
  /// Creates the control buttons.
  const factory AccessibilityControls({Key? key}) = AccessibilityControls._;

  const AccessibilityControls._({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => unawaited(FloatyChatheads.expandChatHead()),
                icon: const Icon(Icons.open_in_full),
                label: const Text('Expand'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => unawaited(FloatyChatheads.collapseChatHead()),
                icon: const Icon(Icons.close_fullscreen),
                label: const Text('Collapse'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => unawaited(FloatyChatheads.closeChatHead()),
          icon: const Icon(Icons.close),
          label: const Text('Close Chathead'),
        ),
      ],
    );
  }
}
