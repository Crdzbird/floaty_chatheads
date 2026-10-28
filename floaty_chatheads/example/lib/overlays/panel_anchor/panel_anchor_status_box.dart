import 'package:flutter/material.dart';

/// Translucent box showing the panel state and the window origin.
final class PanelAnchorStatusBox extends StatelessWidget {
  /// Creates the box for [state] at window origin [position].
  const factory PanelAnchorStatusBox({
    required String state,
    required String position,
    Key? key,
  }) = PanelAnchorStatusBox._;

  const PanelAnchorStatusBox._({
    required this.state,
    required this.position,
    super.key,
  });

  /// Either "expanded" or "collapsed".
  final String state;

  /// The window origin as reported by the native side.
  final String position;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'State: $state\nWindow origin: $position',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
