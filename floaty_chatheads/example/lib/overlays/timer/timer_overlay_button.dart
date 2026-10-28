import 'package:flutter/material.dart';

/// Round translucent icon button used by the stopwatch overlay.
final class TimerOverlayButton extends StatelessWidget {
  /// Creates a button showing [icon] that calls [onTap].
  const factory TimerOverlayButton({
    required IconData icon,
    required VoidCallback onTap,
    Key? key,
  }) = TimerOverlayButton._;

  const TimerOverlayButton._({
    required this.icon,
    required this.onTap,
    super.key,
  });

  /// Icon shown in the button.
  final IconData icon;

  /// Called when the button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
