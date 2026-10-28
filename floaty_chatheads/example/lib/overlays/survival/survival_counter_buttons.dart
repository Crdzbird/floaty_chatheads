import 'package:flutter/material.dart';

import 'survival_action_button.dart';

/// The +1, +5 and +10 buttons of the survival overlay.
final class SurvivalCounterButtons extends StatelessWidget {
  /// Creates the button row; [onIncrement] receives the tapped amount.
  const factory SurvivalCounterButtons({
    required ValueChanged<int> onIncrement,
    Key? key,
  }) = SurvivalCounterButtons._;

  const SurvivalCounterButtons._({required this.onIncrement, super.key});

  /// Called with the amount of the tapped button.
  final ValueChanged<int> onIncrement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Row(
        children: [
          SurvivalActionButton(
            label: '+1',
            onTap: () => onIncrement(1),
            color: Colors.deepOrange,
          ),
          const SizedBox(width: 6),
          SurvivalActionButton(
            label: '+5',
            onTap: () => onIncrement(5),
            color: Colors.orange,
          ),
          const SizedBox(width: 6),
          SurvivalActionButton(
            label: '+10',
            onTap: () => onIncrement(10),
            color: Colors.amber.shade700,
          ),
        ],
      ),
    );
  }
}
