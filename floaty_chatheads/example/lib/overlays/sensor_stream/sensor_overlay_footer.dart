import 'package:flutter/material.dart';

/// Grey footer summarizing the number of streams and total updates.
final class SensorOverlayFooter extends StatelessWidget {
  /// Creates the footer for [totalUpdates] received values.
  const factory SensorOverlayFooter({required int totalUpdates, Key? key}) =
      SensorOverlayFooter._;

  const SensorOverlayFooter._({required this.totalUpdates, super.key});

  /// Updates received across both streams.
  final int totalUpdates;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '2 proxy streams  |  $totalUpdates total updates',
          style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
