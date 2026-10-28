import 'package:flutter/material.dart';

/// Tappable icon in a faint grey circle.
final class FullscreenRoundIcon extends StatelessWidget {
  /// Creates a round icon button.
  const factory FullscreenRoundIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Key? key,
  }) = FullscreenRoundIcon._;

  const FullscreenRoundIcon._({
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });

  /// The icon to show.
  final IconData icon;

  /// Icon color.
  final Color color;

  /// Called when the icon is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
