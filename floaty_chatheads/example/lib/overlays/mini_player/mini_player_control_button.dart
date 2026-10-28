import 'package:flutter/material.dart';

/// A white tappable transport icon in the mini player overlay.
final class MiniPlayerControlButton extends StatelessWidget {
  /// Creates a button showing [icon] at [size] that calls [onTap].
  const factory MiniPlayerControlButton({
    required IconData icon,
    required VoidCallback onTap,
    double size,
    Key? key,
  }) = MiniPlayerControlButton._;

  const MiniPlayerControlButton._({
    required this.icon,
    required this.onTap,
    this.size = 24,
    super.key,
  });

  /// The icon to show.
  final IconData icon;

  /// Called when the icon is tapped.
  final VoidCallback onTap;

  /// Icon size in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: size),
    );
  }
}
