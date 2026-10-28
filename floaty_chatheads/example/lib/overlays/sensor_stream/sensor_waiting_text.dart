import 'package:flutter/material.dart';

/// Grey "Waiting..." text shown until a sensor stream delivers data.
final class SensorWaitingText extends StatelessWidget {
  /// Creates the waiting text.
  const factory SensorWaitingText({Key? key}) = SensorWaitingText._;

  const SensorWaitingText._({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Waiting...',
      style: TextStyle(fontSize: 10, color: Colors.grey),
    );
  }
}
