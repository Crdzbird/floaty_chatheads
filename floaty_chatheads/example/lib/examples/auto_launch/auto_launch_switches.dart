import 'package:flutter/material.dart';

/// Card with the auto-launch and persist switches; a null callback disables
/// the matching switch.
final class AutoLaunchSwitches extends StatelessWidget {
  /// Creates the switch card.
  const factory AutoLaunchSwitches({
    required bool autoLaunch,
    required bool persist,
    required ValueChanged<bool>? onAutoLaunchChanged,
    required ValueChanged<bool>? onPersistChanged,
    Key? key,
  }) = AutoLaunchSwitches._;

  const AutoLaunchSwitches._({
    required this.autoLaunch,
    required this.persist,
    required this.onAutoLaunchChanged,
    required this.onPersistChanged,
    super.key,
  });

  /// Whether auto-launch on background is on.
  final bool autoLaunch;

  /// Whether persist on app close is on.
  final bool persist;

  /// Called when the auto-launch switch changes.
  final ValueChanged<bool>? onAutoLaunchChanged;

  /// Called when the persist switch changes.
  final ValueChanged<bool>? onPersistChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile.adaptive(
              title: const Text('Auto-launch on background'),
              subtitle: const Text(
                'Show chathead when the app is backgrounded, '
                'dismiss when foregrounded.',
              ),
              value: autoLaunch,
              onChanged: onAutoLaunchChanged,
            ),
            const Divider(height: 1),
            SwitchListTile.adaptive(
              title: const Text('Persist on app close'),
              subtitle: const Text(
                'Keep the chathead alive even after the main '
                'app process is killed.',
              ),
              value: persist,
              onChanged: onPersistChanged,
            ),
          ],
        ),
      ),
    );
  }
}
