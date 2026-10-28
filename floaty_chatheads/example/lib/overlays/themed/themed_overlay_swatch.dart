import 'package:flutter/material.dart';

/// A small labeled color circle; grey when [color] is null.
final class ThemedOverlaySwatch extends StatelessWidget {
  /// Creates a swatch for [color] labeled [label].
  const factory ThemedOverlaySwatch({
    required String label,
    required Color? color,
    Key? key,
  }) = ThemedOverlaySwatch._;

  const ThemedOverlaySwatch._({
    required this.label,
    required this.color,
    super.key,
  });

  /// Short label under the circle.
  final String label;

  /// Swatch color, or null for grey.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.grey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: c,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 8)),
      ],
    );
  }
}
