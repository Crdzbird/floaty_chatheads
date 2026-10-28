import 'package:flutter/material.dart';

/// Row of decrement, reset and increment buttons for the counter.
final class CounterControls extends StatelessWidget {
  /// Creates the counter buttons.
  const factory CounterControls({
    required VoidCallback onDecrement,
    required VoidCallback onReset,
    required VoidCallback onIncrement,
    Key? key,
  }) = CounterControls._;

  const CounterControls._({
    required this.onDecrement,
    required this.onReset,
    required this.onIncrement,
    super.key,
  });

  /// Called when the minus button is pressed.
  final VoidCallback onDecrement;

  /// Called when "Reset" is pressed.
  final VoidCallback onReset;

  /// Called when the plus button is pressed.
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton.tonal(
          onPressed: onDecrement,
          child: const Icon(Icons.remove),
        ),
        const SizedBox(width: 16),
        FilledButton.tonal(onPressed: onReset, child: const Text('Reset')),
        const SizedBox(width: 16),
        FilledButton.tonal(
          onPressed: onIncrement,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}
