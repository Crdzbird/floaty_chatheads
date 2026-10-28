import 'package:flutter/material.dart';

import 'widget_icon_tile.dart';

/// The "Static Widget Icons" section of the widget icon example.
final class WidgetIconStaticSection extends StatelessWidget {
  /// Creates the section with one callback per tile.
  const factory WidgetIconStaticSection({
    required VoidCallback onTextAvatar,
    required VoidCallback onGradient,
    required VoidCallback onCustomClose,
    Key? key,
  }) = WidgetIconStaticSection._;

  const WidgetIconStaticSection._({
    required this.onTextAvatar,
    required this.onGradient,
    required this.onCustomClose,
    super.key,
  });

  /// Launches the text avatar variant.
  final VoidCallback onTextAvatar;

  /// Launches the gradient icon variant.
  final VoidCallback onGradient;

  /// Launches the custom close target variant.
  final VoidCallback onCustomClose;

  static Widget _gradientDot(List<Color> colors, IconData icon) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: colors),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Static Widget Icons',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        WidgetIconTile(
          icon: const CircleAvatar(
            backgroundColor: Colors.indigo,
            radius: 20,
            child: Text('JD', style: TextStyle(color: Colors.white)),
          ),
          title: 'Text Avatar',
          subtitle: 'CircleAvatar with initials, no image needed',
          onTap: onTextAvatar,
        ),
        const SizedBox(height: 8),
        WidgetIconTile(
          icon: _gradientDot(
            const [Colors.purple, Colors.deepOrange],
            Icons.phone,
          ),
          title: 'Gradient + Icon',
          subtitle: 'Container with gradient and Material Icon',
          onTap: onGradient,
        ),
        const SizedBox(height: 8),
        WidgetIconTile(
          icon: _gradientDot(
            [Colors.red.shade700, Colors.orange],
            Icons.delete_outline,
          ),
          title: 'Custom Close Target',
          subtitle: 'Widget-based close icon with gradient background',
          onTap: onCustomClose,
        ),
      ],
    );
  }
}
