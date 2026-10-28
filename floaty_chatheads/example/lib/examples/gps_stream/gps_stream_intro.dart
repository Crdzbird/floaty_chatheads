import 'package:flutter/material.dart';

/// Banner explaining what the GPS proxy stream example does.
final class GpsStreamIntro extends StatelessWidget {
  /// Creates the explanation banner.
  const factory GpsStreamIntro({Key? key}) = GpsStreamIntro._;

  const GpsStreamIntro._({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.green.shade50,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FloatyProxyStream: GPS Example',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          SizedBox(height: 4),
          Text(
            'Main app pushes simulated GPS coordinates\n'
            'every second. The overlay receives them via\n'
            'a one-way FloatyProxyStream<GpsCoord>.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
