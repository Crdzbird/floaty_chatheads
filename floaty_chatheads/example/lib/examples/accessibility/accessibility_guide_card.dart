import 'package:flutter/material.dart';

/// Blue card with step by step instructions for testing with TalkBack.
final class AccessibilityGuideCard extends StatelessWidget {
  /// Creates the guide card.
  const factory AccessibilityGuideCard({Key? key}) = AccessibilityGuideCard._;

  const AccessibilityGuideCard._({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TalkBack Testing Guide',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. Enable TalkBack in Settings > Accessibility\n'
              '2. Tap "Launch" to show the chathead\n'
              '3. Swipe to focus the chat bubble\n'
              '   - Should announce: "Chat bubble default, 2 new messages"\n'
              '4. Double-tap to expand\n'
              '   - Should announce: "Chat expanded"\n'
              '   - Focus moves to content panel\n'
              '5. Double-tap "Tap Me" button\n'
              '   - Counter updates as live region\n'
              '6. Drag bubble to close target\n'
              '   - Should announce: "Close target visible"\n'
              '7. Double-tap "Close" to dismiss\n'
              '   - Should announce: "Content panel hidden"',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
