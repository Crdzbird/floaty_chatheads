import 'package:flutter/material.dart';

/// App bar button that launches the chathead, or closes it when active.
final class MessengerAppBarAction extends StatelessWidget {
  /// Creates the action for the current [active] state.
  const factory MessengerAppBarAction({
    required bool active,
    required VoidCallback onLaunch,
    required VoidCallback onClose,
    Key? key,
  }) = MessengerAppBarAction._;

  const MessengerAppBarAction._({
    required this.active,
    required this.onLaunch,
    required this.onClose,
    super.key,
  });

  /// Whether the chathead is currently shown.
  final bool active;

  /// Called when the launch button is pressed.
  final VoidCallback onLaunch;

  /// Called when the close button is pressed.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Close chathead',
        onPressed: onClose,
      );
    }
    return IconButton(
      icon: const Icon(Icons.chat_bubble),
      tooltip: 'Launch chathead',
      onPressed: onLaunch,
    );
  }
}
