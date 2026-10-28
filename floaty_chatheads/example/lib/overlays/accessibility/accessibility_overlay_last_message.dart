import 'package:flutter/material.dart';

/// Labeled grey text showing the last message from the main app.
final class AccessibilityOverlayLastMessage extends StatelessWidget {
  /// Creates the line showing [message].
  const factory AccessibilityOverlayLastMessage({
    required String message,
    Key? key,
  }) = AccessibilityOverlayLastMessage._;

  const AccessibilityOverlayLastMessage._({required this.message, super.key});

  /// The last message received from the main app.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        Semantics(
          label: 'Last message from main app',
          child: Text(
            message,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
