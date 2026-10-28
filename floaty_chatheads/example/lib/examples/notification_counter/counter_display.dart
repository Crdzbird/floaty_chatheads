import 'package:flutter/material.dart';

/// Large circle showing the current counter value; red when above zero.
final class CounterDisplay extends StatelessWidget {
  /// Creates the display for [count].
  const factory CounterDisplay({required int count, Key? key}) =
      CounterDisplay._;

  const CounterDisplay._({required this.count, super.key});

  /// The value to show.
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: count > 0 ? Colors.red : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$count',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: count > 0 ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}
