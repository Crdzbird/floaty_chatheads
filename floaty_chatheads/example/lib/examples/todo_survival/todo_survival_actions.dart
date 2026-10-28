import 'package:flutter/material.dart';

/// Builds the app bar actions of the todo survival example: a launch
/// button while the chathead is hidden, otherwise add, clear done (only
/// when [hasDone]) and close buttons.
List<Widget> todoSurvivalActions({
  required bool chatheadActive,
  required bool hasDone,
  required VoidCallback onLaunch,
  required VoidCallback onAdd,
  required VoidCallback onClearDone,
  required VoidCallback onClose,
}) {
  return [
    if (!chatheadActive)
      IconButton(
        icon: const Icon(Icons.rocket_launch),
        tooltip: 'Launch overlay',
        onPressed: onLaunch,
      ),
    if (chatheadActive) ...[
      IconButton(
        icon: const Icon(Icons.add_task),
        tooltip: 'Add from main',
        onPressed: onAdd,
      ),
      if (hasDone)
        IconButton(
          icon: const Icon(Icons.cleaning_services),
          tooltip: 'Clear done',
          onPressed: onClearDone,
        ),
      IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Close overlay',
        onPressed: onClose,
      ),
    ],
  ];
}
