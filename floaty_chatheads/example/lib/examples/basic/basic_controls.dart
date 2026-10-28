import 'package:flutter/material.dart';

/// The show, send and close buttons of the basic example.
final class BasicControls extends StatelessWidget {
  /// Creates the button block; [counter] labels the send button.
  const factory BasicControls({
    required int counter,
    required VoidCallback onShow,
    required VoidCallback onSend,
    required VoidCallback onClose,
    Key? key,
  }) = BasicControls._;

  const BasicControls._({
    required this.counter,
    required this.onShow,
    required this.onSend,
    required this.onClose,
    super.key,
  });

  /// Number shown on the send button.
  final int counter;

  /// Called when "Show Chathead" is pressed.
  final VoidCallback onShow;

  /// Called when the send button is pressed.
  final VoidCallback onSend;

  /// Called when "Close" is pressed.
  final VoidCallback onClose;

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
                  onPressed: onSend,
                  icon: const Icon(Icons.send),
                  label: Text('Send #$counter'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
