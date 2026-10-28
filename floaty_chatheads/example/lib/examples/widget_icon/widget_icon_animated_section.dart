import 'package:flutter/material.dart';

import 'widget_icon_tile.dart';

/// The "Animated Widget Icons" section of the widget icon example.
final class WidgetIconAnimatedSection extends StatelessWidget {
  /// Creates the section with one callback per tile.
  const factory WidgetIconAnimatedSection({
    required VoidCallback onSpinning,
    required VoidCallback onPulsing,
    Key? key,
  }) = WidgetIconAnimatedSection._;

  const WidgetIconAnimatedSection._({
    required this.onSpinning,
    required this.onPulsing,
    super.key,
  });

  /// Launches the spinning sync variant.
  final VoidCallback onSpinning;

  /// Launches the pulsing alert variant.
  final VoidCallback onPulsing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Animated Widget Icons',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        WidgetIconTile(
          icon: const CircleAvatar(
            backgroundColor: Colors.teal,
            radius: 20,
            child: Icon(Icons.sync, color: Colors.white),
          ),
          title: 'Spinning Sync',
          subtitle: 'Rotates continuously at 24 fps',
          onTap: onSpinning,
        ),
        const SizedBox(height: 8),
        WidgetIconTile(
          icon: CircleAvatar(
            backgroundColor: Colors.red.shade400,
            radius: 20,
            child: const Icon(Icons.priority_high, color: Colors.white),
          ),
          title: 'Pulsing Alert',
          subtitle: 'Scale + opacity pulse with glow shadow',
          onTap: onPulsing,
        ),
      ],
    );
  }
}
