import 'package:flutter/material.dart';

/// Card explaining how to test auto-launch and persistence.
final class AutoLaunchInstructions extends StatelessWidget {
  /// Creates the instructions card.
  const factory AutoLaunchInstructions({Key? key}) = AutoLaunchInstructions._;

  const AutoLaunchInstructions._({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How to test', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const Text(
              '1. Toggle the switches above and tap Enable.\n'
              '2. Press Home or switch to another app.\n'
              '3. The chathead appears automatically.\n'
              '4. Return to this app: chathead is dismissed.\n\n'
              'With "Persist on app close" ON:\n'
              '- Force-stop the app: chathead survives.\n\n'
              'With "Persist on app close" OFF:\n'
              '- Force-stop the app: chathead disappears.',
            ),
          ],
        ),
      ),
    );
  }
}
