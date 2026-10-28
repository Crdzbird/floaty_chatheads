import 'package:flutter/material.dart';

import 'sensor_card_header.dart';

/// Card showing the simulated ambient light level as a bar.
final class SensorLightCard extends StatelessWidget {
  /// Creates the card for [lux].
  const factory SensorLightCard({required double lux, Key? key}) =
      SensorLightCard._;

  const SensorLightCard._({required this.lux, super.key});

  /// Current illuminance in lux.
  final double lux;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SensorCardHeader(
                icon: Icons.light_mode,
                iconColor: Colors.amber.shade700,
                title: 'Ambient Light',
                tag: 'light',
                tagBackground: Colors.amber.shade50,
                tagColor: Colors.amber,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (lux / 1000).clamp(0, 1),
                        minHeight: 16,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          lux < 100
                              ? Colors.grey.shade600
                              : lux < 400
                                  ? Colors.amber
                                  : Colors.orange,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: Text(
                      '${lux.toStringAsFixed(0)} lux',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
