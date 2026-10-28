import 'package:flutter/material.dart';

/// Show, add bubble and close all buttons of the multi-chathead example.
final class MultiChatheadControls extends StatelessWidget {
  /// Creates the button block.
  const factory MultiChatheadControls({
    required VoidCallback onShow,
    required VoidCallback onAdd,
    required VoidCallback onCloseAll,
    Key? key,
  }) = MultiChatheadControls._;

  const MultiChatheadControls._({
    required this.onShow,
    required this.onAdd,
    required this.onCloseAll,
    super.key,
  });

  /// Called when "Show Chathead" is pressed.
  final VoidCallback onShow;

  /// Called when "Add Bubble" is pressed.
  final VoidCallback onAdd;

  /// Called when "Close All" is pressed.
  final VoidCallback onCloseAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
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
                child: ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Bubble'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCloseAll,
                  icon: const Icon(Icons.close),
                  label: const Text('Close All'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
