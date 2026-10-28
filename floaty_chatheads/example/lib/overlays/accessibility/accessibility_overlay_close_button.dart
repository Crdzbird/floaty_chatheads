import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

/// Large grey "Close" button that closes the accessibility overlay.
final class AccessibilityOverlayCloseButton extends StatelessWidget {
  /// Creates the close button.
  const factory AccessibilityOverlayCloseButton({Key? key}) =
      AccessibilityOverlayCloseButton._;

  const AccessibilityOverlayCloseButton._({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close overlay',
      child: GestureDetector(
        onTap: () => unawaited(FloatyOverlay.closeOverlay()),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Close',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
