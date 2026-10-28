import 'package:flutter/material.dart';

/// Small white pill with a colored label, used for Clear and Close.
final class CounterPillButton extends StatelessWidget {
  /// Creates a pill labeled [label] in [color].
  const factory CounterPillButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
    Key? key,
  }) = CounterPillButton._;

  const CounterPillButton._({
    required this.label,
    required this.color,
    required this.onTap,
    super.key,
  });

  /// Text on the pill.
  final String label;

  /// Text color.
  final Color color;

  /// Called when the pill is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, color: color)),
      ),
    );
  }
}
