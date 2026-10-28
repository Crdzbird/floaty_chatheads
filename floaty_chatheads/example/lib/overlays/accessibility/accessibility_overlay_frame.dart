import 'package:flutter/material.dart';

/// Centered white rounded card with a soft shadow that hosts the
/// accessibility overlay content.
final class AccessibilityOverlayFrame extends StatelessWidget {
  /// Creates the frame around [child].
  const factory AccessibilityOverlayFrame({required Widget child, Key? key}) =
      AccessibilityOverlayFrame._;

  const AccessibilityOverlayFrame._({required this.child, super.key});

  /// Content shown inside the card.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}
