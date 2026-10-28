import 'package:flutter/material.dart';

/// Large blue "Tap Me" button with a semantic label for screen readers.
final class AccessibilityOverlayTapButton extends StatelessWidget {
  /// Creates the button that calls [onTap].
  const factory AccessibilityOverlayTapButton({
    required VoidCallback onTap,
    Key? key,
  }) = AccessibilityOverlayTapButton._;

  const AccessibilityOverlayTapButton._({required this.onTap, super.key});

  /// Called when the button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tap counter button',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Tap Me',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
