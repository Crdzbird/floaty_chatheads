import 'package:flutter/material.dart';

/// The "How to test" panel at the top of the todo survival example.
final class TodoSurvivalInstructions extends StatelessWidget {
  /// Creates the instructions panel.
  const factory TodoSurvivalInstructions({Key? key}) =
      TodoSurvivalInstructions._;

  const TodoSurvivalInstructions._({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.teal.shade50,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to test:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '1. Launch the overlay\n'
            '2. Add tasks from the overlay\n'
            '3. Force-stop this app from recents\n'
            '4. Add / toggle / remove tasks (queued)\n'
            '5. Re-open app: actions flush here',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
