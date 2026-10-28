import 'package:flutter/material.dart';

/// Intro text plus the purple, green and close buttons of the themed
/// example.
final class ThemedLaunchPanel extends StatelessWidget {
  /// Creates the panel with one callback per button.
  const factory ThemedLaunchPanel({
    required VoidCallback onPurple,
    required VoidCallback onGreen,
    required VoidCallback onClose,
    Key? key,
  }) = ThemedLaunchPanel._;

  const ThemedLaunchPanel._({
    required this.onPurple,
    required this.onGreen,
    required this.onClose,
    super.key,
  });

  /// Called when "Purple Theme" is pressed.
  final VoidCallback onPurple;

  /// Called when "Green Theme" is pressed.
  final VoidCallback onGreen;

  /// Called when "Close" is pressed.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Launch a chathead with custom theme colors.\n'
            'Badge, border, close tint, and overlay palette are all '
            'customizable.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onPurple,
            icon: const Icon(Icons.palette),
            label: const Text('Purple Theme'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onGreen,
            icon: const Icon(Icons.eco),
            label: const Text('Green Theme'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            label: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
