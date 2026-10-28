import 'dart:async';

import 'package:floaty_chatheads/advanced.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import '../../models/todo_actions.dart';
import 'todo_survival_overlay_banner.dart';
import 'todo_survival_overlay_close_row.dart';
import 'todo_survival_overlay_header.dart';
import 'todo_survival_overlay_queue_badge.dart';
import 'todo_survival_overlay_stats_button.dart';
import 'todo_survival_overlay_task_list.dart';

part 'todo_survival_overlay_content_state.dart';
part 'todo_survival_overlay_tasks.dart';

/// Card content of the todo survival overlay, driven by the overlay [kit],
/// the latest synced [state] and the [connected] flag.
final class TodoSurvivalOverlayContent extends StatefulWidget {
  /// Creates the overlay card content.
  const factory TodoSurvivalOverlayContent({
    required FloatyOverlayKit<TodoState> kit,
    required TodoState state,
    required bool connected,
    Key? key,
  }) = TodoSurvivalOverlayContent._;

  const TodoSurvivalOverlayContent._({
    required this.kit,
    required this.state,
    required this.connected,
    super.key,
  });

  /// Overlay kit used to dispatch actions and call services.
  final FloatyOverlayKit<TodoState> kit;

  /// Latest state pushed by the main app.
  final TodoState state;

  /// Whether the main app is currently connected.
  final bool connected;

  @override
  State<TodoSurvivalOverlayContent> createState() =>
      _TodoSurvivalOverlayContentState();
}
