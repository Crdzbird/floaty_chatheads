import 'dart:async';
import 'dart:convert';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_actions.dart';
import '../utils.dart';
import 'todo_survival/todo_survival_actions.dart';
import 'todo_survival/todo_survival_body.dart';

part 'todo_survival/todo_survival_commands.dart';
part 'todo_survival/todo_survival_kit.dart';
part 'todo_survival/todo_survival_state.dart';
part 'todo_survival/todo_survival_store.dart';

/// Demonstrates overlay survival with a todo list instead of a counter.
///
/// The overlay shows a live connection banner, queues add, toggle and
/// remove actions while the app is dead, and falls back to placeholder
/// values for proxy calls when the main app is unavailable. Kill the app
/// from recents, manage tasks in the overlay, then re-open the app to see
/// the queued actions flush into the log.
final class TodoSurvivalExample extends StatefulWidget {
  /// Creates the todo survival example page.
  const factory TodoSurvivalExample({Key? key}) = TodoSurvivalExample._;

  const TodoSurvivalExample._({super.key});

  @override
  State<TodoSurvivalExample> createState() => _TodoSurvivalExampleState();
}
