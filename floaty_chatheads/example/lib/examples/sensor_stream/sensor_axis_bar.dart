import 'package:flutter/material.dart';

/// Labelled bar showing the magnitude of one accelerometer axis.
final class SensorAxisBar extends StatelessWidget {
  /// Creates a bar for [value], scaled against [maxVal].
  const factory SensorAxisBar({
    required String label,
    required double value,
    required double maxVal,
    required Color color,
    Key? key,
  }) = SensorAxisBar._;

  const SensorAxisBar._({
    required this.label,
    required this.value,
    required this.maxVal,
    required this.color,
    super.key,
  });

  /// Axis label.
  final String label;

  /// Current axis value.
  final double value;

  /// Value that fills the bar completely.
  final double maxVal;

  /// Bar and label color.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final normalized = (value.abs() / maxVal).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 52,
          child: Text(
            value.toStringAsFixed(2),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
