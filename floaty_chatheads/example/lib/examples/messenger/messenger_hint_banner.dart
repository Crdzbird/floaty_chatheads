import 'package:flutter/material.dart';

/// Banner telling the user how to launch the messenger chathead.
final class MessengerHintBanner extends StatelessWidget {
  /// Creates the hint banner.
  const factory MessengerHintBanner({Key? key}) = MessengerHintBanner._;

  const MessengerHintBanner._({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.indigo.shade50,
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.indigo.shade400,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Tap the chat icon in the app bar to launch the chathead',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
