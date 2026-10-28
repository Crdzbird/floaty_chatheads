import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Green or red banner showing whether the main app is connected.
final class SurvivalConnectionBanner extends StatelessWidget {
  /// Creates the banner for the given [connected] state.
  const factory SurvivalConnectionBanner({
    required bool connected,
    Key? key,
  }) = SurvivalConnectionBanner._;

  const SurvivalConnectionBanner._({required this.connected, super.key});

  /// Whether the main app is currently connected.
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      color: connected ? Colors.green : Colors.red.shade700,
      child: Row(
        children: [
          Icon(
            connected ? Icons.link : Icons.link_off,
            color: Colors.white,
            size: 13,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              connected ? 'Connected' : 'Disconnected',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          if (!connected)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'OFFLINE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (connected)
            GestureDetector(
              onTap: () => unawaited(FloatyOverlay.closeOverlay()),
              child: const Icon(
                Icons.close,
                color: Colors.white70,
                size: 13,
              ),
            ),
        ],
      ),
    );
  }
}
