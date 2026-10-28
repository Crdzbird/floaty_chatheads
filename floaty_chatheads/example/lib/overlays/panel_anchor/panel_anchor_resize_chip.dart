import 'package:flutter/material.dart';

/// Small chip that resizes the anchor playground panel when tapped.
final class PanelAnchorResizeChip extends StatelessWidget {
  /// Creates a chip labeled [label] that calls [onTap].
  const factory PanelAnchorResizeChip({
    required String label,
    required VoidCallback onTap,
    Key? key,
  }) = PanelAnchorResizeChip._;

  const PanelAnchorResizeChip._({
    required this.label,
    required this.onTap,
    super.key,
  });

  /// Text shown on the chip.
  final String label;

  /// Called when the chip is pressed.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.white.withValues(alpha: 0.9),
    );
  }
}
