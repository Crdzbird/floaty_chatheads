import 'package:flutter/material.dart';

/// One labelled coordinate value, such as `LAT 12.136400`.
final class GpsCoordRow extends StatelessWidget {
  /// Creates a row showing [label] and [value].
  const factory GpsCoordRow({
    required String label,
    required double value,
    Key? key,
  }) = GpsCoordRow._;

  const GpsCoordRow._({required this.label, required this.value, super.key});

  /// Short axis label.
  final String label;

  /// Coordinate value in degrees.
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value.toStringAsFixed(6),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
