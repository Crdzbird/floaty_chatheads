import 'package:flutter/material.dart';

/// Placeholder shown in the GPS overlay until the first fix arrives.
final class GpsWaitingView extends StatelessWidget {
  /// Creates the waiting placeholder.
  const factory GpsWaitingView({Key? key}) = GpsWaitingView._;

  const GpsWaitingView._({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.gps_off, size: 28, color: Colors.grey),
          SizedBox(height: 6),
          Text(
            'Waiting for GPS data...',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
