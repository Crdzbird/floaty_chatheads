import 'package:flutter/material.dart';

/// Title row of a sensor card: icon, title and a stream name tag.
final class SensorCardHeader extends StatelessWidget {
  /// Creates the header for the stream called [tag].
  const factory SensorCardHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String tag,
    required Color tagBackground,
    required Color tagColor,
    Key? key,
  }) = SensorCardHeader._;

  const SensorCardHeader._({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.tag,
    required this.tagBackground,
    required this.tagColor,
    super.key,
  });

  /// Leading icon.
  final IconData icon;

  /// Color of the leading icon.
  final Color iconColor;

  /// Card title.
  final String title;

  /// Proxy stream name shown in the tag.
  final String tag;

  /// Background color of the tag.
  final Color tagBackground;

  /// Text color of the tag.
  final Color tagColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: tagBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: tagColor,
            ),
          ),
        ),
      ],
    );
  }
}
