import 'package:flutter/material.dart';

/// Tinted box in the sensor overlay with an icon, a title, an update
/// count and the section [child] below.
final class SensorOverlaySection extends StatelessWidget {
  /// Creates a section tinted with [color].
  const factory SensorOverlaySection({
    required MaterialColor color,
    required IconData icon,
    required String title,
    required int count,
    required Widget child,
    Key? key,
  }) = SensorOverlaySection._;

  const SensorOverlaySection._({
    required this.color,
    required this.icon,
    required this.title,
    required this.count,
    required this.child,
    super.key,
  });

  /// Base color; shades 50, 400 and 700 are used.
  final MaterialColor color;

  /// Section icon.
  final IconData icon;

  /// Section title.
  final String title;

  /// Number of updates received for this stream.
  final int count;

  /// Content shown below the title row.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: color.shade700),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color.shade700,
                  ),
                ),
                const Spacer(),
                Text(
                  '$count',
                  style: TextStyle(fontSize: 8, color: color.shade400),
                ),
              ],
            ),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }
}
