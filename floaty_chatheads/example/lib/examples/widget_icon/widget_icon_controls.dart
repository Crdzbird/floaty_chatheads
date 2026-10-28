import 'package:flutter/material.dart';

/// The "Animation Controls" section: pause or resume, and close.
final class WidgetIconControls extends StatelessWidget {
  /// Creates the controls; [animating] picks the toggle button label.
  const factory WidgetIconControls({
    required bool animating,
    required VoidCallback onToggle,
    required VoidCallback onClose,
    Key? key,
  }) = WidgetIconControls._;

  const WidgetIconControls._({
    required this.animating,
    required this.onToggle,
    required this.onClose,
    super.key,
  });

  /// Whether the chathead icon animation is running.
  final bool animating;

  /// Called when the pause or resume button is pressed.
  final VoidCallback onToggle;

  /// Called when "Close" is pressed.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Animation Controls',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onToggle,
                icon: Icon(animating ? Icons.pause : Icons.play_arrow),
                label: Text(animating ? 'Pause Animation' : 'Resume'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                label: const Text('Close'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
