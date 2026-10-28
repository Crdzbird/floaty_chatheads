import 'package:flutter/material.dart';

/// White rounded "Close" pill shown in the widget icon overlay.
final class WidgetIconClosePill extends StatelessWidget {
  /// Creates the pill that calls [onTap] when tapped.
  const factory WidgetIconClosePill({required VoidCallback onTap, Key? key}) =
      WidgetIconClosePill._;

  const WidgetIconClosePill._({required this.onTap, super.key});

  /// Called when the pill is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Close',
          style: TextStyle(
            color: Colors.indigo,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
