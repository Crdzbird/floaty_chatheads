import 'package:flutter/material.dart';

/// Banner with the steps for testing overlay survival.
final class SurvivalInstructions extends StatelessWidget {
  /// Creates the instructions banner.
  const factory SurvivalInstructions({Key? key}) = SurvivalInstructions._;

  const SurvivalInstructions._({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.deepOrange.shade50,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to test:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          SizedBox(height: 4),
          Text(
            '1. Launch the overlay\n'
            '2. Force-stop this app from recents\n'
            '3. Overlay stays, banner turns red\n'
            '4. Tap +1 in overlay (actions queue)\n'
            '5. Re-open app, actions flush here',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
