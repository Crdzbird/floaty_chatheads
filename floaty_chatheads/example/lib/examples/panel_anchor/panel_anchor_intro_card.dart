import 'package:flutter/material.dart';

/// Pink card explaining what the panel anchor playground demonstrates.
final class PanelAnchorIntroCard extends StatelessWidget {
  /// Creates the intro card.
  const factory PanelAnchorIntroCard({Key? key}) = PanelAnchorIntroCard._;

  const PanelAnchorIntroCard._({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.pink.shade50,
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'New in 2.1.0: the expanded panel opens below the bubble by '
          'default. Try "above" (on Android the bubble row snaps to '
          'the bottom), or "auto" with the Tall panel and the bubble '
          'dragged near the bottom edge (iOS flips it above). The '
          'panel is always clamped to the screen.',
          style: TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}
