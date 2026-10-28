import 'package:flutter/material.dart';

/// A card that launches one widget icon variant when tapped.
final class WidgetIconTile extends StatelessWidget {
  /// Creates a tile with a preview [icon], [title] and [subtitle].
  const factory WidgetIconTile({
    required Widget icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Key? key,
  }) = WidgetIconTile._;

  const WidgetIconTile._({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  /// Preview of the chathead icon.
  final Widget icon;

  /// Variant name.
  final String title;

  /// Short description of the variant.
  final String subtitle;

  /// Called when the tile is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: icon,
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.launch),
        onTap: onTap,
      ),
    );
  }
}
