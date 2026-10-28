import 'package:flutter/material.dart';

/// Hint shown while no quick action has been received yet.
final class QuickActionEmptyHint extends StatelessWidget {
  /// Creates the empty-state hint.
  const factory QuickActionEmptyHint({Key? key}) = QuickActionEmptyHint._;

  const QuickActionEmptyHint._({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Launch the chathead, tap to expand the bubbles, '
              'then tap the action buttons.\n\n'
              'Actions will be logged here in real-time.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
