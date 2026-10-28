import 'package:flutter/material.dart';

/// Small labelled bar showing the magnitude of one accelerometer axis.
final class SensorMiniAxisBar extends StatelessWidget {
  /// Creates a bar for [value], scaled against [maxVal].
  const factory SensorMiniAxisBar({
    required String label,
    required double value,
    required double maxVal,
    required Color color,
    Key? key,
  }) = SensorMiniAxisBar._;

  const SensorMiniAxisBar._({
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
          width: 12,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 9,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 38,
          child: Text(
            value.toStringAsFixed(1),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 9),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
