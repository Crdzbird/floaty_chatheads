import 'package:flutter/material.dart';

/// Small teal "Add" pill button of the todo survival overlay.
final class TodoSurvivalOverlayAddButton extends StatelessWidget {
  /// Creates the add button that calls [onTap].
  const factory TodoSurvivalOverlayAddButton({
    required VoidCallback onTap,
    Key? key,
  }) = TodoSurvivalOverlayAddButton._;

  const TodoSurvivalOverlayAddButton._({required this.onTap, super.key});

  /// Called when the button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 12, color: Colors.white),
            SizedBox(width: 2),
            Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
