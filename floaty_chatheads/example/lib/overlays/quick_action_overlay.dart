import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'quick_action/quick_action_strip.dart';

/// Vertical strip of quick-action FABs that collapse and expand on
/// chathead tap.
///
/// Sends the action name back to the main app when tapped. Uses
/// [FloatyOverlayBuilder] for the overlay lifecycle.
final class QuickActionOverlay extends StatelessWidget {
  /// Creates the quick-action overlay.
  const factory QuickActionOverlay({Key? key}) = QuickActionOverlay._;

  const QuickActionOverlay._({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatyOverlayBuilder<bool>(
      initialState: true,
      onData: (expanded, _) => expanded,
      onTapped: (expanded, _) {
        final next = !expanded;
        unawaited(
          next
              ? FloatyOverlay.resizeContent(200, 300)
              : FloatyOverlay.resizeContent(60, 60),
        );
        return next;
      },
      builder: (context, expanded) =>
          expanded ? const QuickActionStrip() : const SizedBox.shrink(),
    );
  }
}
