import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../models/todo_actions.dart';
import 'todo_survival/todo_survival_overlay_content.dart';

/// Overlay that demonstrates survival with a todo list.
///
/// Shows a connection banner (green when connected, red when the main app
/// is killed), dispatches add, toggle and remove actions through the kit
/// (queued while disconnected, with a queued count badge), calls a stats
/// proxy service that falls back instead of timing out, and receives the
/// full task list from the main app.
final class TodoSurvivalOverlay extends StatelessWidget {
  /// Creates the todo survival overlay.
  const factory TodoSurvivalOverlay({Key? key}) = TodoSurvivalOverlay._;

  const TodoSurvivalOverlay._({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatyOverlayScope<TodoState>(
      stateToJson: (s) => s.toJson(),
      stateFromJson: TodoState.fromJson,
      initialState: TodoState(),
      builder: (context, kit, state, connected) {
        return TodoSurvivalOverlayContent(
          kit: kit,
          state: state,
          connected: connected,
        );
      },
    );
  }
}
