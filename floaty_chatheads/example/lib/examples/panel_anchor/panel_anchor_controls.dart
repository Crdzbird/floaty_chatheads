import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Show button plus expand, collapse and close buttons of the playground.
final class PanelAnchorControls extends StatelessWidget {
  /// Creates the controls; [onShow] launches the chathead.
  const factory PanelAnchorControls({required VoidCallback onShow, Key? key}) =
      PanelAnchorControls._;

  const PanelAnchorControls._({required this.onShow, super.key});

  /// Called when "Show Chathead" is pressed.
  final VoidCallback onShow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: onShow,
          icon: const Icon(Icons.bubble_chart),
          label: const Text('Show Chathead'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => unawaited(FloatyChatheads.expandChatHead()),
                icon: const Icon(Icons.open_in_full),
                label: const Text('Expand'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => unawaited(FloatyChatheads.collapseChatHead()),
                icon: const Icon(Icons.close_fullscreen),
                label: const Text('Collapse'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => unawaited(FloatyChatheads.closeChatHead()),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
