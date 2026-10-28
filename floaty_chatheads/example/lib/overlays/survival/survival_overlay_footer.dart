import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Bottom row of the survival overlay: "Send Message" and "Close".
final class SurvivalOverlayFooter extends StatelessWidget {
  /// Creates the footer; [onSendMessage] runs on "Send Message".
  const factory SurvivalOverlayFooter({
    required VoidCallback onSendMessage,
    Key? key,
  }) = SurvivalOverlayFooter._;

  const SurvivalOverlayFooter._({required this.onSendMessage, super.key});

  /// Called when "Send Message" is tapped.
  final VoidCallback onSendMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onSendMessage,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Send Message',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => unawaited(FloatyOverlay.closeOverlay()),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
