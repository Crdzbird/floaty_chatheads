import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Indigo title bar of the messenger overlay with a close button.
final class MessengerOverlayHeader extends StatelessWidget {
  /// Creates the overlay header.
  const factory MessengerOverlayHeader({Key? key}) = MessengerOverlayHeader._;

  const MessengerOverlayHeader._({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.indigo,
      child: Row(
        children: [
          const Icon(Icons.chat, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Chat',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => unawaited(FloatyOverlay.closeOverlay()),
            child: const Icon(Icons.close, color: Colors.white70, size: 18),
          ),
        ],
      ),
    );
  }
}
