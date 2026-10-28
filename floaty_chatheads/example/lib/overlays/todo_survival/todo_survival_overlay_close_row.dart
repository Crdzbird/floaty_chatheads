import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Right-aligned outlined "Close" pill that closes the overlay.
final class TodoSurvivalOverlayCloseRow extends StatelessWidget {
  /// Creates the close row.
  const factory TodoSurvivalOverlayCloseRow({Key? key}) =
      TodoSurvivalOverlayCloseRow._;

  const TodoSurvivalOverlayCloseRow._({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Spacer(),
          GestureDetector(
            onTap: () => unawaited(FloatyOverlay.closeOverlay()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
